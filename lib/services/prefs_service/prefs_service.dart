import 'dart:convert';

import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();

  static final PrefsService _instance = PrefsService._();

  factory PrefsService() => _instance;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _deviceIdKey = 'device_id';
  static const String _localAddressKey = 'kyc_local_address';
  /// SharedPreferences is wiped on uninstall; Keychain is not. Used to detect reinstall.
  static const String _hasLaunchedKey = 'has_launched';

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool _tokenMigrated = false;
  bool _checkedReinstall = false;

  Future<SharedPreferences> _sp() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    await _sp();
    await _wipeAuthIfReinstalled();
    await _migrateTokenIfNeeded();
  }

  /// iOS Keychain (and Android backup) can keep the auth token after uninstall.
  /// SharedPreferences is cleared on uninstall, so a missing launch marker
  /// with no local prefs means this is a fresh install — drop leftover session.
  Future<void> _wipeAuthIfReinstalled() async {
    if (_checkedReinstall) return;
    _checkedReinstall = true;

    final sp = await _sp();
    if (sp.getBool(_hasLaunchedKey) == true) return;

    final hadLocalState =
        sp.containsKey(_userKey) ||
        sp.containsKey(_fcmTokenKey) ||
        sp.containsKey(_deviceIdKey) ||
        sp.containsKey(_localAddressKey) ||
        sp.containsKey(_tokenKey);

    if (!hadLocalState) {
      await _secure.delete(key: _tokenKey);
    }
    await sp.setBool(_hasLaunchedKey, true);
  }

  /// Moves legacy SharedPreferences token into secure storage once.
  Future<void> _migrateTokenIfNeeded() async {
    if (_tokenMigrated) return;
    _tokenMigrated = true;
    await _wipeAuthIfReinstalled();

    try {
      final existing = await _secure.read(key: _tokenKey);
      if (existing != null && existing.isNotEmpty) {
        final sp = await _sp();
        if (sp.containsKey(_tokenKey)) {
          await sp.remove(_tokenKey);
        }
        return;
      }

      final sp = await _sp();
      final legacy = sp.getString(_tokenKey);
      if (legacy == null || legacy.isEmpty) return;

      await _secure.write(key: _tokenKey, value: legacy);
      await sp.remove(_tokenKey);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('PrefsService token migrate failed: $e\n$st');
      }
    }
  }

  Future<void> saveToken(String token) async {
    await _migrateTokenIfNeeded();
    await _secure.write(key: _tokenKey, value: token);
    final sp = await _sp();
    if (sp.containsKey(_tokenKey)) {
      await sp.remove(_tokenKey);
    }
  }

  Future<String?> getToken() async {
    await _migrateTokenIfNeeded();
    return _secure.read(key: _tokenKey);
  }

  Future<bool> get isLoggedIn async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveUser(UserDataModel user) async {
    final sp = await _sp();
    await sp.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserDataModel?> getUser() async {
    final sp = await _sp();
    final raw = sp.getString(_userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return UserDataModel.fromJson(map);
      }
      if (map is Map) {
        return UserDataModel.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('PrefsService.getUser failed: $e\n$st');
      }
    }
    return null;
  }

  Future<void> saveAuth(AuthDataModel auth) async {
    if (auth.token != null && auth.token!.isNotEmpty) {
      await saveToken(auth.token!);
    }
    if (auth.user != null) {
      final complete = auth.needsProfile == true ? false : (auth.user!.isProfileComplete ?? false);
      await saveUser(auth.user!.copyWith(isProfileComplete: complete));
      return;
    }
    await saveUser(UserDataModel(isProfileComplete: auth.needsProfile != true));
  }

  Future<void> saveFcmToken(String token) async {
    final sp = await _sp();
    await sp.setString(_fcmTokenKey, token);
  }

  Future<String?> getFcmToken() async {
    final sp = await _sp();
    return sp.getString(_fcmTokenKey);
  }

  /// Stable install id (created once per app install).
  Future<String> getOrCreateDeviceId(String Function() create) async {
    final sp = await _sp();
    final existing = sp.getString(_deviceIdKey)?.trim();
    if (existing != null && existing.isNotEmpty) return existing;
    final created = create().trim();
    await sp.setString(_deviceIdKey, created);
    return created;
  }

  Future<String?> getDeviceId() async {
    final sp = await _sp();
    return sp.getString(_deviceIdKey);
  }

  Future<void> saveLocalAddress(LocalAddressData address) async {
    final sp = await _sp();
    await sp.setString(_localAddressKey, jsonEncode(address.toJson()));
  }

  Future<void> clearLocalAddress() async {
    final sp = await _sp();
    await sp.remove(_localAddressKey);
  }

  Future<LocalAddressData?> getLocalAddress() async {
    final sp = await _sp();
    final raw = sp.getString(_localAddressKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw);
      if (map is Map<String, dynamic>) {
        return LocalAddressData.fromJson(map);
      }
      if (map is Map) {
        return LocalAddressData.fromJson(Map<String, dynamic>.from(map));
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('PrefsService.getLocalAddress failed: $e\n$st');
      }
    }
    return null;
  }

  Future<bool> hasLocalAddress() async {
    final saved = await getLocalAddress();
    return saved?.isComplete == true;
  }

  Future<void> clear() async {
    await _secure.delete(key: _tokenKey);
    final sp = await _sp();
    await sp.remove(_tokenKey);
    await sp.remove(_userKey);
    await sp.remove(_localAddressKey);
  }
}

class LocalAddressData {
  LocalAddressData({
    required this.line,
    this.landmark,
    required this.city,
    required this.state,
    required this.pincode,
  });

  final String line;
  final String? landmark;
  final String city;
  final String state;
  final String pincode;

  bool get isComplete =>
      line.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty &&
      RegExp(r'^\d{6}$').hasMatch(pincode.trim());

  String get displayLine =>
      [
        line,
        if ((landmark ?? '').trim().isNotEmpty) landmark!.trim(),
        city,
        state,
        pincode,
      ].where((e) => e.trim().isNotEmpty).join(', ');

  factory LocalAddressData.fromJson(Map<String, dynamic> json) {
    return LocalAddressData(
      line: (json['line'] ?? json['address_line'] ?? '').toString(),
      landmark: json['landmark']?.toString(),
      city: (json['city'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
      pincode: (json['pincode'] ?? json['pin_code'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'line': line,
      if ((landmark ?? '').trim().isNotEmpty) 'landmark': landmark!.trim(),
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
