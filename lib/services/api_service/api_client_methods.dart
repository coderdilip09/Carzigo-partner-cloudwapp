import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:carzigo_partner/screens/auth/login/login_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/services/api_service/api_urls.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/services/prefs_service/prefs_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClientMethods {
  ApiClientMethods._();

  static const Duration _timeout = Duration(seconds: 30);

  /// Prevents multiple parallel 401s from stacking login navigations.
  static bool _handlingUnauthorized = false;

  static Future<Map<String, String>> _headers({bool jsonBody = true}) async {
    final headers = <String, String>{
      HttpHeaders.acceptHeader: '*/*',
      ApiUrls.appKeyHeader: ApiUrls.appKey,
    };
    if (jsonBody) {
      headers[HttpHeaders.contentTypeHeader] = 'application/json';
    }
    final token = await PrefsService().getToken();
    if (token != null && token.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> getMethod({
    required String url,
    Map<String, String>? query,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      var uri = Uri.parse(url);
      if (query != null && query.isNotEmpty) {
        uri = uri.replace(queryParameters: query);
      }
      final headers = await _headers();
      _logRequest(method: 'GET', url: uri.toString(), headers: headers);
      final response = await http.get(uri, headers: headers).timeout(_timeout);
      return _decode(
        response,
        method: 'GET',
        url: uri.toString(),
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('GET $url failed: $e\n$st');
      return _error(e);
    }
  }

  static Future<Map<String, dynamic>> postMethod({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      final headers = await _headers();
      final encoded = jsonEncode(body ?? {});
      _logRequest(method: 'POST', url: url, headers: headers, body: encoded);
      final response = await http
          .post(Uri.parse(url), headers: headers, body: encoded)
          .timeout(_timeout);
      return _decode(
        response,
        method: 'POST',
        url: url,
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('POST $url failed: $e\n$st');
      return _error(e);
    }
  }

  static Future<Map<String, dynamic>> patchMethod({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      final headers = await _headers();
      final encoded = jsonEncode(body ?? {});
      _logRequest(method: 'PATCH', url: url, headers: headers, body: encoded);
      final response = await http
          .patch(Uri.parse(url), headers: headers, body: encoded)
          .timeout(_timeout);
      return _decode(
        response,
        method: 'PATCH',
        url: url,
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('PATCH $url failed: $e\n$st');
      return _error(e);
    }
  }

  static Future<Map<String, dynamic>> putMethod({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      final headers = await _headers();
      final encoded = jsonEncode(body ?? {});
      _logRequest(method: 'PUT', url: url, headers: headers, body: encoded);
      final response = await http
          .put(Uri.parse(url), headers: headers, body: encoded)
          .timeout(_timeout);
      return _decode(
        response,
        method: 'PUT',
        url: url,
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('PUT $url failed: $e\n$st');
      return _error(e);
    }
  }

  static Future<Map<String, dynamic>> deleteMethod({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      final headers = await _headers();
      final encoded = body == null ? null : jsonEncode(body);
      _logRequest(method: 'DELETE', url: url, headers: headers, body: encoded);
      final request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll(headers);
      if (encoded != null) {
        request.body = encoded;
      }
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(
        response,
        method: 'DELETE',
        url: url,
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('DELETE $url failed: $e\n$st');
      return _error(e);
    }
  }

  static Future<Map<String, dynamic>> postMultipart({
    required String url,
    Map<String, String>? fields,
    Map<String, File>? files,
  }) async {
    if (_isMissingUrl(url)) return _missingUrl();
    try {
      final headers = await _headers(jsonBody: false);
      final fileNames = files?.map((key, value) => MapEntry(key, value.path)) ?? {};
      _logRequest(
        method: 'MULTIPART POST',
        url: url,
        headers: headers,
        body: 'fields=$fields files=$fileNames',
      );
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);
      if (fields != null) {
        request.fields.addAll(fields);
      }
      if (files != null) {
        for (final entry in files.entries) {
          request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value.path));
        }
      }
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(
        response,
        method: 'MULTIPART POST',
        url: url,
        hadAuth: headers.containsKey(HttpHeaders.authorizationHeader),
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('MULTIPART POST $url failed: $e\n$st');
      return _error(e);
    }
  }

  static bool _isMissingUrl(String url) => url.trim().isEmpty;

  static Map<String, dynamic> _missingUrl() {
    if (kDebugMode) {
      debugPrint('ERROR: API base URL is not configured');
    }
    return {'status': false, 'code': 0, 'message': 'API base URL is not configured', 'data': null};
  }

  static Map<String, dynamic> _error(Object error) {
    if (kDebugMode) {
      debugPrint('error===>$error');
    }
    return {'status': false, 'code': 0, 'message': error.toString(), 'data': null};
  }

  static void _logRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    String? body,
  }) {
    if (!kDebugMode) return;

    Map<String, String>? safeHeaders;
    if (headers != null) {
      safeHeaders = Map<String, String>.from(headers);
      if (safeHeaders.containsKey(HttpHeaders.authorizationHeader)) {
        safeHeaders[HttpHeaders.authorizationHeader] = 'Bearer ***';
      }
    }

    debugPrint('======== API REQUEST ========');
    debugPrint('<<<<<METHOD<<<<<$method>>>>URL=> $url>>>>>>>>>');
    if (safeHeaders != null) debugPrint('HEADERS: $safeHeaders');
    debugPrint('BODY: ${body ?? '-'}');
  }

  static Future<Map<String, dynamic>> _decode(
    http.Response response, {
    required String method,
    required String url,
    required bool hadAuth,
  }) async {
    if (hadAuth && response.statusCode == 401) {
      unawaited(_handleUnauthorized());
    }

    try {
      final raw = utf8.decode(response.bodyBytes);
      if (kDebugMode) {
        debugPrint('<<<<<<<<<METHOD: $method>>>>>>>>URL: $url>>>>>');
        debugPrint('STATUS: ${response.statusCode}');
        debugPrint('BODY: $raw');
      }
      if (raw.isEmpty) {
        return {
          'status': response.statusCode >= 200 && response.statusCode < 300,
          'code': response.statusCode,
          'message': response.reasonPhrase,
          'data': null,
        };
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        decoded.putIfAbsent('code', () => response.statusCode);
        return decoded;
      }
      if (decoded is Map) {
        final map = Map<String, dynamic>.from(decoded);
        map.putIfAbsent('code', () => response.statusCode);
        return map;
      }
      return {
        'status': response.statusCode >= 200 && response.statusCode < 300,
        'code': response.statusCode,
        'message': response.reasonPhrase,
        'data': decoded,
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('API decode failed: $e\n$st');
      return {
        'status': false,
        'code': response.statusCode,
        'message': 'Invalid server response',
        'data': null,
      };
    }
  }

  static Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      KycStatus.resetForNewNumber();
      await PrefsService().clear();
      AppToast.error(AppStrings.sessionExpired.tr());
      if (AppNavigation.isReady) {
        await AppNavigation.offAll(const LoginScreen());
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('API unauthorized handler failed: $e\n$st');
      }
    } finally {
      // Ignore late 401s from requests that were already in flight.
      Future<void>.delayed(const Duration(seconds: 2), () {
        _handlingUnauthorized = false;
      });
    }
  }
}
