class DocumentChangeRequestModel {
  DocumentChangeRequestModel({
    required this.id,
    required this.reason,
    required this.status,
    required this.sections,
    required this.canSubmitChanges,
  });

  final String id;
  final String reason;
  final String status;
  final List<DocumentChangeSectionModel> sections;
  final bool canSubmitChanges;

  factory DocumentChangeRequestModel.fromJson(Map<String, dynamic> json) {
    final rawSections = json['sections'];
    final sections = <DocumentChangeSectionModel>[];
    if (rawSections is List) {
      for (final item in rawSections) {
        if (item is Map<String, dynamic>) {
          sections.add(DocumentChangeSectionModel.fromJson(item));
        } else if (item is Map) {
          sections.add(
            DocumentChangeSectionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      }
    }
    return DocumentChangeRequestModel(
      id: (json['id'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      sections: sections,
      canSubmitChanges: json['can_submit_changes'] == true,
    );
  }

  DocumentChangeSectionModel? sectionOf(String key) {
    for (final s in sections) {
      if (s.section == key) return s;
    }
    return null;
  }

  bool get isOpen => status == 'open';
}

class DocumentChangeDraftModel {
  DocumentChangeDraftModel({
    this.docType,
    this.docNumber,
    this.frontUrl,
    this.backUrl,
    this.docUrl,
    this.addressLine,
    this.bankName,
    this.accountNumber,
    this.chequeUrl,
  });

  final String? docType;
  final String? docNumber;
  final String? frontUrl;
  final String? backUrl;
  final String? docUrl;
  final String? addressLine;
  final String? bankName;
  final String? accountNumber;
  final String? chequeUrl;

  factory DocumentChangeDraftModel.fromJson(Map<String, dynamic> json) {
    return DocumentChangeDraftModel(
      docType: _asNonEmpty(json['doc_type'] ?? json['docType']),
      docNumber: _asNonEmpty(json['doc_number'] ?? json['docNumber']),
      frontUrl: _asNonEmpty(json['front_url'] ?? json['frontUrl']),
      backUrl: _asNonEmpty(json['back_url'] ?? json['backUrl']),
      docUrl: _asNonEmpty(json['doc_url'] ?? json['docUrl']),
      addressLine: _asNonEmpty(json['address_line'] ?? json['addressLine']),
      bankName: _asNonEmpty(json['bank_name'] ?? json['bankName']),
      accountNumber: _asNonEmpty(
        json['account_number'] ?? json['accountNumber'],
      ),
      chequeUrl: _asNonEmpty(json['cheque_url'] ?? json['chequeUrl']),
    );
  }

  List<String> get documentUrls {
    final urls = <String>[];
    void add(String? value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return;
      if (!urls.contains(trimmed)) urls.add(trimmed);
    }

    add(frontUrl);
    add(backUrl);
    add(docUrl);
    add(chequeUrl);
    return urls;
  }
}

String? _asNonEmpty(dynamic value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

class DocumentChangeSectionModel {
  DocumentChangeSectionModel({
    required this.section,
    required this.status,
    required this.hasDraft,
    required this.draftReady,
    this.draft,
    this.permissionRejectReason,
    this.docsRejectReason,
  });

  final String section;
  final String status;
  final bool hasDraft;
  final bool draftReady;
  final DocumentChangeDraftModel? draft;
  final String? permissionRejectReason;
  final String? docsRejectReason;

  factory DocumentChangeSectionModel.fromJson(Map<String, dynamic> json) {
    final rawDraft = json['draft'];
    Map<String, dynamic>? draftMap;
    if (rawDraft is Map<String, dynamic>) {
      draftMap = rawDraft;
    } else if (rawDraft is Map) {
      draftMap = Map<String, dynamic>.from(rawDraft);
    }

    return DocumentChangeSectionModel(
      section: (json['section'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      hasDraft: json['has_draft'] == true || draftMap != null,
      draftReady: json['draft_ready'] == true || draftMap?['ready'] == true,
      draft: draftMap == null
          ? null
          : DocumentChangeDraftModel.fromJson(draftMap),
      permissionRejectReason: json['permission_reject_reason']?.toString(),
      docsRejectReason: json['docs_reject_reason']?.toString(),
    );
  }

  bool get canUpdate =>
      status == 'unlocked' || status == 'rejected_docs';

  bool get isRequested => status == 'requested';
  bool get isPendingReview => status == 'pending_review';
  bool get isApproved => status == 'approved';
  bool get isPermissionRejected => status == 'rejected_permission';
}
