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

  SharedPreferences? _prefs;
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  bool _tokenMigrated = false;

  Future<SharedPreferences> _sp() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    await _sp();
    await _migrateTokenIfNeeded();
  }

  /// Moves legacy SharedPreferences token into secure storage once.
  Future<void> _migrateTokenIfNeeded() async {
    if (_tokenMigrated) return;
    _tokenMigrated = true;

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

  Future<void> clear() async {
    await _secure.delete(key: _tokenKey);
    final sp = await _sp();
    await sp.remove(_tokenKey);
    await sp.remove(_userKey);
  }
}
