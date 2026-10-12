/// Public S3 origin for uploaded photos and documents.
const String imageBaseUrl = 'https://carzigo-storage.s3.ap-south-1.amazonaws.com';

/// Turns a stored object key into a URL the app can load.
/// Full http(s) URLs, asset paths, and on-device files are left unchanged.
String resolveMediaUrl(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('assets/') || raw.startsWith('file://')) return raw;
  if (_isDevicePath(raw)) return raw;
  final key = raw.replaceFirst(RegExp(r'^/+'), '');
  if (key.isEmpty) return '';
  return '$imageBaseUrl/$key';
}

bool isRemoteMediaUrl(String value) {
  return value.startsWith('http://') || value.startsWith('https://');
}

bool _isDevicePath(String raw) {
  return raw.startsWith('/data/') ||
      raw.startsWith('/storage/') ||
      raw.startsWith('/sdcard/') ||
      raw.startsWith('/var/') ||
      raw.startsWith('/private/') ||
      raw.startsWith('/Users/');
}
