import 'dart:io';
import 'dart:math';

import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';

class DeviceInfo {
  const DeviceInfo({required this.type, required this.id});

  final String type;
  final String id;
}

/// Stable install id + platform for signup/signin / FCM registration.
class DeviceService {
  DeviceService._();

  static final DeviceService _instance = DeviceService._();

  factory DeviceService() => _instance;

  Future<DeviceInfo> getInfo() async {
    final type = Platform.isIOS
        ? 'ios'
        : Platform.isAndroid
            ? 'android'
            : Platform.operatingSystem;
    final id = await PrefsService().getOrCreateDeviceId(_newDeviceId);
    return DeviceInfo(type: type, id: id);
  }

  String _newDeviceId() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-'
        '${h.substring(16, 20)}-${h.substring(20)}';
  }
}
