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

class DocumentChangeSectionModel {
  DocumentChangeSectionModel({
    required this.section,
    required this.status,
    required this.hasDraft,
    required this.draftReady,
    this.permissionRejectReason,
    this.docsRejectReason,
  });

  final String section;
  final String status;
  final bool hasDraft;
  final bool draftReady;
  final String? permissionRejectReason;
  final String? docsRejectReason;

  factory DocumentChangeSectionModel.fromJson(Map<String, dynamic> json) {
    return DocumentChangeSectionModel(
      section: (json['section'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      hasDraft: json['has_draft'] == true,
      draftReady: json['draft_ready'] == true,
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
