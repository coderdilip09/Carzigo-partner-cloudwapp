import 'dart:convert';

import 'package:carzigo_partner/screens/kyc/digilocker/digilocker_webview_screen.dart';
import 'package:carzigo_partner/screens/kyc/kyc_status.dart';
import 'package:carzigo_partner/screens/kyc/local_address/local_address_screen.dart';
import 'package:carzigo_partner/services/api_service/api.dart';
import 'package:carzigo_partner/services/navigation_service/navigation_service.dart';
import 'package:carzigo_partner/utils/app_strings.dart';
import 'package:carzigo_partner/utils/app_toast.dart';
import 'package:carzigo_partner/utils/base_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// #region agent log
void _agentLog(
  String hypothesisId,
  String location,
  String message,
  Map<String, Object?> data,
) {
  final payload = <String, Object?>{
    'sessionId': 'b88589',
    'runId': 'post-fix',
    'hypothesisId': hypothesisId,
    'location': location,
    'message': message,
    'data': data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  };
  debugPrint('AGENT_DEBUG ${jsonEncode(payload)}');
  () async {
    for (final host in ['127.0.0.1', '10.0.2.2']) {
      try {
        await http
            .post(
              Uri.parse(
                'http://$host:7426/ingest/4d3f57d5-768b-4846-bc82-2ebe7b5d8f28',
              ),
              headers: {
                'Content-Type': 'application/json',
                'X-Debug-Session-Id': 'b88589',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(milliseconds: 800));
        break;
      } catch (_) {}
    }
  }();
}
// #endregion

/// Digilocker-based Identity + Address Proof.
class IdentityProofProvider extends BaseProvider {
  IdentityProofProvider({
    this.loadSaved = false,
    this.editOnly = false,
    this.forDocumentChange = false,
  }) {
    if (loadSaved) loadSavedData();
  }

  final bool loadSaved;
  final bool editOnly;
  final bool forDocumentChange;

  bool isLoading = false;
  bool isFetching = false;
  bool isVerified = false;
  String? verifiedName;
  String? maskedAadhaar;
  bool localAddressDone = false;

  Future<void> loadSavedData() async {
    if (!loadSaved) return;
    isFetching = true;
    safeNotifyListeners();

    try {
      // Document-change must not treat live KYC as "already done" — that made
      // Continue just pop back without creating a change draft.
      if (forDocumentChange) {
        final changeRes = await Api.getDocumentChangeCurrent();
        final identitySection = changeRes.data?.sectionOf('identity');
        final hasChangeDraft = identitySection != null &&
            (identitySection.draftReady || identitySection.hasDraft);
        if (hasChangeDraft) {
          isVerified = true;
          final draftNumber = identitySection.draft?.docNumber?.trim();
          if (draftNumber != null && draftNumber.isNotEmpty) {
            maskedAadhaar = draftNumber;
          }
          final draftName =
              identitySection.draft?.digilockerFullName?.trim();
          verifiedName =
              (draftName != null && draftName.isNotEmpty) ? draftName : null;
        } else {
          isVerified = false;
          verifiedName = null;
          maskedAadhaar = null;
        }
        // #region agent log
        _agentLog('B', 'identity_proof_provider.dart:loadSavedData', 'loaded document-change identity', {
          'forDocumentChange': forDocumentChange,
          'editOnly': editOnly,
          'isVerified': isVerified,
          'identityStatus': identitySection?.status,
          'hasDraft': identitySection?.hasDraft,
          'draftReady': identitySection?.draftReady,
        });
        // #endregion
        return;
      }

      final res = await Api.getKycReview();
      if (!res.isSuccess) {
        AppToast.error(res.message ?? AppStrings.requestFailed.tr());
        return;
      }
      final identity = res.data?.identity;
      localAddressDone = res.data?.localAddress?.isDone == true;
      isVerified = identity?.isDone == true;
      verifiedName = identity?.fullName;
      maskedAadhaar = identity?.maskedNumber;
      // #region agent log
      _agentLog('B', 'identity_proof_provider.dart:loadSavedData', 'loaded live KYC identity', {
        'forDocumentChange': forDocumentChange,
        'editOnly': editOnly,
        'isVerified': isVerified,
        'hasName': (verifiedName ?? '').isNotEmpty,
        'verifiedVia': identity?.verifiedVia,
      });
      // #endregion
    } catch (e, st) {
      debugPrint('Load Digilocker KYC failed: $e\n$st');
      AppToast.error(AppStrings.requestFailed.tr());
    } finally {
      isFetching = false;
      safeNotifyListeners();
    }
  }

  Future<void> tapOnVerifyDigilocker(BuildContext context) async {
    if (isLoading || isFetching) return;
    isLoading = true;
    safeNotifyListeners();

    try {
      final start = await Api.startDigilocker();
      if (!start.isSuccess || start.data == null) {
        AppToast.error(start.message ?? AppStrings.digilockerFailed.tr());
        return;
      }

      final session = start.data!;
      final clientId = session.clientId?.trim() ?? '';
      final url = session.url?.trim() ?? '';
      final token = session.token?.trim() ?? '';
      final hasLink = url.isNotEmpty || token.isNotEmpty;

      if (clientId.isEmpty && !hasLink) {
        AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
        return;
      }

      // Mock Digilocker: never open empty WebView — complete immediately.
      final isMockSession =
          session.isMock || clientId.startsWith('mock_digilocker_');
      String id;

      if (isMockSession) {
        if (clientId.isEmpty) {
          AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
          return;
        }
        debugPrint(
          'Digilocker mock path — skipping WebView, client_id=$clientId',
        );
        id = clientId;
      } else if (!hasLink) {
        AppToast.error(AppStrings.digilockerSessionIncomplete.tr());
        return;
      } else {
        if (!context.mounted) {
          AppToast.error(AppStrings.digilockerFailed.tr());
          return;
        }
        final completedClientId = await Navigator.of(context).push<String>(
          MaterialPageRoute(
            builder: (_) => DigilockerWebViewScreen(
              clientId: clientId.isNotEmpty ? clientId : 'pending',
              url: url.isNotEmpty ? url : null,
              token: token.isNotEmpty ? token : null,
              gateway: session.gateway ?? 'sandbox',
            ),
          ),
        );

        id = completedClientId?.trim() ?? '';
        if (id.isEmpty || id == 'pending') {
          AppToast.error(AppStrings.digilockerCancelled.tr());
          return;
        }
      }

      final complete = await Api.completeDigilocker(clientId: id);
      // #region agent log
      _agentLog('C', 'identity_proof_provider.dart:completeDigilocker', 'digilocker complete result', {
        'forDocumentChange': forDocumentChange,
        'editOnly': editOnly,
        'isSuccess': complete.isSuccess,
        'message': complete.message,
        'identityDone': complete.data?.identity?.isDone,
      });
      // #endregion
      if (!complete.isSuccess) {
        AppToast.error(complete.message ?? AppStrings.digilockerFailed.tr());
        return;
      }

      final identity = complete.data?.identity;
      isVerified = true;
      final name = identity?.fullName?.trim();
      final masked = identity?.maskedNumber?.trim();
      if (name != null && name.isNotEmpty) verifiedName = name;
      if (masked != null && masked.isNotEmpty) maskedAadhaar = masked;
      localAddressDone = complete.data?.localAddress?.isDone == true;
      // Live KYC is untouched in document-change mode (drafts only).
      if (!forDocumentChange) {
        KycStatus.markIdentityDone();
        KycStatus.markAddressDone();
      }
      AppToast.success(
        complete.message ?? AppStrings.digilockerVerified.tr(),
      );
      safeNotifyListeners();

      if (editOnly || forDocumentChange) {
        // #region agent log
        _agentLog('C', 'identity_proof_provider.dart:afterDigilocker', 'auto-back after digilocker', {
          'forDocumentChange': forDocumentChange,
          'editOnly': editOnly,
          'localAddressDone': localAddressDone,
        });
        // #endregion
        AppNavigation.back();
        return;
      }
      _goNext();
    } catch (e, st) {
      debugPrint('Digilocker flow failed: $e\n$st');
      AppToast.error(AppStrings.digilockerFailed.tr());
    } finally {
      isLoading = false;
      safeNotifyListeners();
    }
  }

  void tapOnContinue() {
    // #region agent log
    _agentLog('A', 'identity_proof_provider.dart:tapOnContinue', 'continue tapped', {
      'forDocumentChange': forDocumentChange,
      'editOnly': editOnly,
      'isVerified': isVerified,
      'localAddressDone': localAddressDone,
      'branch': !isVerified
          ? 'toast_incomplete'
          : ((editOnly || forDocumentChange) ? 'back_edit_or_change' : 'goNext'),
    });
    // #endregion
    if (!isVerified) {
      AppToast.error(AppStrings.completeIdentityFirst.tr());
      return;
    }
    if (editOnly || forDocumentChange) {
      AppNavigation.back();
      return;
    }
    _goNext();
  }

  void _goNext() {
    AppNavigation.to(
      LocalAddressScreen(editOnly: false),
    );
  }
}
