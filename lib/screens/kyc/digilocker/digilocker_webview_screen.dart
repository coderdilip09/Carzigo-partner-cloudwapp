import 'dart:async';
import 'dart:convert';

import 'package:carzigo_partner/theme/app_colors.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens Digilocker Via Link URL or Digiboost Web SDK (token).
/// Pops with [client_id] only after a real success signal; null on cancel.
class DigilockerWebViewScreen extends StatefulWidget {
  const DigilockerWebViewScreen({
    super.key,
    required this.clientId,
    this.url,
    this.token,
    this.gateway = 'sandbox',
  });

  final String clientId;
  final String? url;
  final String? token;
  final String gateway;

  @override
  State<DigilockerWebViewScreen> createState() =>
      _DigilockerWebViewScreenState();
}

class _DigilockerWebViewScreenState extends State<DigilockerWebViewScreen> {
  late final WebViewController _controller;
  var _loading = true;
  var _closing = false;
  Timer? _successPoll;

  bool get _hasClientId =>
      widget.clientId.isNotEmpty && widget.clientId != 'pending';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) async {
            if (mounted) setState(() => _loading = false);
            await _injectBottomPadding();
            await _injectSuccessWatcher();
            await _scanPageForSuccess();
          },
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri != null && _isSuccessRedirect(uri)) {
              final id =
                  _clientIdFromUri(uri) ??
                  (_hasClientId ? widget.clientId : null);
              _finishSuccess(id);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            final url = change.url;
            if (url == null) return;
            final uri = Uri.tryParse(url);
            if (uri != null && _isSuccessRedirect(uri)) {
              final id =
                  _clientIdFromUri(uri) ??
                  (_hasClientId ? widget.clientId : null);
              _finishSuccess(id);
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'DigilockerChannel',
        onMessageReceived: (message) {
          try {
            final decoded = jsonDecode(message.message);
            if (decoded is Map) {
              final status = (decoded['status'] ?? decoded['event'] ?? '')
                  .toString()
                  .toLowerCase();
              if (status == 'failure' ||
                  status == 'failed' ||
                  status == 'cancel' ||
                  status == 'cancelled') {
                return;
              }
              final id = (decoded['client_id'] ?? decoded['clientId'] ?? '')
                  .toString()
                  .trim();
              _finishSuccess(
                id.isNotEmpty ? id : (_hasClientId ? widget.clientId : null),
              );
            }
          } catch (_) {
            // Ignore non-JSON channel noise.
          }
        },
      );

    final link = widget.url?.trim();
    final token = widget.token?.trim();
    // Prefer Digiboost SDK (onSuccess) over Via Link URL.
    if (token != null && token.isNotEmpty) {
      _controller.loadHtmlString(_digiboostHtml(token, widget.gateway));
    } else if (link != null && link.isNotEmpty) {
      _controller.loadRequest(Uri.parse(link));
    } else {
      // No Digilocker URL/token — close so caller can show an error (do not hang).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
      return;
    }

    // DigiLocker often shows "Document shared successfully" without calling
    // SDK onSuccess — poll DOM text as a fallback.
    _successPoll = Timer.periodic(const Duration(seconds: 1), (_) {
      _scanPageForSuccess();
    });
  }

  @override
  void dispose() {
    _successPoll?.cancel();
    super.dispose();
  }

  Future<void> _injectBottomPadding() async {
    try {
      await _controller.runJavaScript('''
(function() {
  var styleId = 'carzigo-digilocker-bottom-pad';
  if (document.getElementById(styleId)) return;
  var s = document.createElement('style');
  s.id = styleId;
  s.textContent = [
    'html, body {',
    '  padding-bottom: calc(28px + env(safe-area-inset-bottom, 0px)) !important;',
    '  box-sizing: border-box !important;',
    '}',
    'button, [role="button"], .btn, .button,',
    '[class*="allow"], [class*="Allow"], [id*="allow"], [id*="Allow"] {',
    '  margin-bottom: 8px !important;',
    '}',
    'footer, .footer, .actions, .action-bar, .button-container,',
    '[class*="footer"], [class*="action"], [class*="consent"] {',
    '  padding-bottom: calc(20px + env(safe-area-inset-bottom, 0px)) !important;',
    '}'
  ].join('\\n');
  (document.head || document.documentElement).appendChild(s);
})();
''');
    } catch (_) {}
  }

  Future<void> _injectSuccessWatcher() async {
    try {
      await _controller.runJavaScript('''
(function() {
  if (window.__carzigoDigilockerWatch) return;
  window.__carzigoDigilockerWatch = true;
  function looksSuccessful(text) {
    if (!text) return false;
    var t = String(text).toLowerCase();
    return t.indexOf('document shared successfully') !== -1
      || t.indexOf('shared successfully') !== -1
      || t.indexOf('documents shared') !== -1
      || t.indexOf('verification successful') !== -1
      || t.indexOf('successfully shared') !== -1
      || t.indexOf('aadhaar fetched') !== -1
      || t.indexOf('verification completed') !== -1
      || t.indexOf('completed successfully') !== -1;
  }
  function check() {
    try {
      var text = (document.body && document.body.innerText) || '';
      if (looksSuccessful(text) && window.DigilockerChannel) {
        DigilockerChannel.postMessage(JSON.stringify({
          status: 'success',
          client_id: '',
          source: 'dom_text'
        }));
      }
    } catch (e) {}
  }
  check();
  try {
    var obs = new MutationObserver(function() { check(); });
    obs.observe(document.documentElement || document.body, {
      childList: true,
      subtree: true,
      characterData: true
    });
  } catch (e) {}
})();
''');
    } catch (_) {}
  }

  Future<void> _scanPageForSuccess() async {
    if (_closing || !mounted) return;
    try {
      final raw = await _controller.runJavaScriptReturningResult('''
(function() {
  try {
    var text = ((document.body && document.body.innerText) || '').toLowerCase();
    var ok = text.indexOf('document shared successfully') !== -1
      || text.indexOf('shared successfully') !== -1
      || text.indexOf('documents shared') !== -1
      || text.indexOf('verification successful') !== -1
      || text.indexOf('successfully shared') !== -1
      || text.indexOf('aadhaar fetched') !== -1
      || text.indexOf('verification completed') !== -1
      || text.indexOf('completed successfully') !== -1;
    return ok ? '1' : '0';
  } catch (e) { return '0'; }
})();
''');
      final value = raw.toString().replaceAll('"', '').trim();
      if (value == '1' && _hasClientId) {
        _finishSuccess(widget.clientId);
      }
    } catch (_) {}
  }

  bool _isSuccessRedirect(Uri uri) {
    if (uri.scheme == 'carzigo' &&
        (uri.host == 'digilocker' || uri.path.contains('digilocker'))) {
      return true;
    }
    final status =
        (uri.queryParameters['status'] ??
                uri.queryParameters['state'] ??
                uri.queryParameters['result'] ??
                '')
            .toLowerCase();
    if (status == 'success' ||
        status == 'completed' ||
        status == 'complete' ||
        status == 'ok') {
      return true;
    }
    final hasClientId = _clientIdFromUri(uri) != null;
    final failed =
        status == 'failure' ||
        status == 'failed' ||
        status == 'cancel' ||
        status == 'cancelled' ||
        status == 'error';
    if (hasClientId &&
        !failed &&
        (uri.scheme == 'carzigo' ||
            uri.path.contains('digilocker') ||
            uri.queryParameters.containsKey('success'))) {
      return true;
    }
    return false;
  }

  String? _clientIdFromUri(Uri uri) {
    final id =
        uri.queryParameters['client_id'] ??
        uri.queryParameters['clientId'] ??
        uri.queryParameters['client-id'];
    if (id == null || id.trim().isEmpty) return null;
    return id.trim();
  }

  void _finishSuccess(String? clientId) {
    if (_closing || !mounted) return;
    final id = clientId?.trim();
    if (id == null || id.isEmpty || id == 'pending') return;
    _closing = true;
    _successPoll?.cancel();
    Navigator.pop(context, id);
  }

  String _digiboostHtml(String token, String gateway) {
    final safeToken = const JsonEncoder().convert(token);
    final safeGateway = const JsonEncoder().convert(gateway);
    final fallbackId = const JsonEncoder().convert(
      _hasClientId ? widget.clientId : '',
    );
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Digilocker</title>
  <style>
    body {
      font-family: sans-serif;
      margin: 24px;
      padding-bottom: calc(40px + env(safe-area-inset-bottom, 0px));
      background: #FCF8F7;
      color: #1A1A1A;
      box-sizing: border-box;
    }
    #status { margin-top: 16px; font-size: 14px; color: #757575; }
    #digilocker-button {
      margin-top: 24px;
      margin-bottom: calc(24px + env(safe-area-inset-bottom, 0px));
      padding-bottom: 16px;
    }
  </style>
</head>
<body>
  <h3>Verify with DigiLocker</h3>
  <p>Complete DigiLocker verification to continue KYC.</p>
  <div id="digilocker-button"></div>
  <div id="status">Loading DigiLocker…</div>
  <script src="https://cdn.jsdelivr.net/gh/surepassio/surepass-digiboost-web-sdk@latest/index.min.js"></script>
  <script>
    function postSuccess(payload) {
      try {
        var id = (payload && (payload.client_id || payload.clientId)) || $fallbackId;
        DigilockerChannel.postMessage(JSON.stringify({
          status: 'success',
          client_id: id || '',
          raw: payload || null
        }));
      } catch (e) {}
    }
    function boot() {
      if (typeof window.DigiboostSdk !== 'function') {
        document.getElementById('status').innerText = 'Unable to load DigiLocker SDK';
        return;
      }
      window.DigiboostSdk({
        gateway: $safeGateway,
        token: $safeToken,
        selector: '#digilocker-button',
        onSuccess: function(data) {
          document.getElementById('status').innerText = 'Verification successful';
          postSuccess(data);
        },
        onFailure: function() {
          document.getElementById('status').innerText = 'Verification cancelled or failed';
          DigilockerChannel.postMessage(JSON.stringify({ status: 'failure' }));
        }
      });
      document.getElementById('status').innerText = 'Tap the DigiLocker button to continue';
    }
    boot();
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          AppStrings.verifyWithDigilocker.tr(),
          style: AppTextStyles.style(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_hasClientId && false)
            TextButton(
              onPressed: () => _finishSuccess(widget.clientId),
              child: Text(
                AppStrings.digilockerContinue.tr(),
                style: AppTextStyles.style(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (_loading)
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
