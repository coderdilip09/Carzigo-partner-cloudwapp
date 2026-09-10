import 'dart:convert';

import 'package:carzigo_partner/models/user_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();

  static final PrefsService _instance = PrefsService._();

  factory PrefsService() => _instance;

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';

  SharedPreferences? _prefs;

  Future<SharedPreferences> _sp() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> init() async {
    await _sp();
  }

  Future<void> saveToken(String token) async {
    final sp = await _sp();
    await sp.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final sp = await _sp();
    return sp.getString(_tokenKey);
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
      debugPrint('PrefsService.getUser failed: $e\n$st');
    }
    return null;
  }

  Future<void> saveAuth(AuthDataModel auth) async {
    if (auth.token != null && auth.token!.isNotEmpty) {
      await saveToken(auth.token!);
    }
    if (auth.user != null) {
      final complete = auth.needsProfile == true
          ? false
          : (auth.user!.isProfileComplete ?? false);
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
    final sp = await _sp();
    await sp.remove(_tokenKey);
    await sp.remove(_userKey);
  }
}
