import 'user.dart';

enum NotesheetStatus {
  draft,
  submitted,
  underReview,
  needsRevision,
  approved,
  rejected,
}

class Notesheet {
  final String id;
  final String title;
  final String description;
  final String? pdfUrl;
  final String? pdfPath;
  final NotesheetStatus status;
  final String createdById;
  final User? createdBy;
  final List<String> reviewerIds;
  final List<User> reviewers;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final String? notes;

  Notesheet({
    required this.id,
    required this.title,
    required this.description,
    this.pdfUrl,
    this.pdfPath,
    required this.status,
    required this.createdById,
    this.createdBy,
    required this.reviewerIds,
    this.reviewers = const [],
    required this.createdAt,
    required this.updatedAt,
    this.submittedAt,
    this.reviewedAt,
    this.notes,
  });

  factory Notesheet.fromJson(Map<String, dynamic> json) {
    return Notesheet(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      pdfUrl: json['pdf_url'],
      pdfPath: json['pdf_path'],
      status: NotesheetStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => NotesheetStatus.draft,
      ),
      createdById: json['created_by_id'],
      createdBy: json['created_by'] != null
          ? User.fromJson(json['created_by'])
          : null,
      reviewerIds: List<String>.from(json['reviewer_ids'] ?? []),
      reviewers:
          (json['reviewers'] as List<dynamic>?)
              ?.map((r) => User.fromJson(r))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'])
          : null,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pdf_url': pdfUrl,
      'pdf_path': pdfPath,
      'status': status.name,
      'created_by_id': createdById,
      'reviewer_ids': reviewerIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'submitted_at': submittedAt?.toIso8601String(),
      'reviewed_at': reviewedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  String get statusString {
    switch (status) {
      case NotesheetStatus.draft:
        return 'Draft';
      case NotesheetStatus.submitted:
        return 'Submitted';
      case NotesheetStatus.underReview:
        return 'Under Review';
      case NotesheetStatus.needsRevision:
        return 'Needs Revision';
      case NotesheetStatus.approved:
        return 'Approved';
      case NotesheetStatus.rejected:
        return 'Rejected';
    }
  }

  Notesheet copyWith({
    String? id,
    String? title,
    String? description,
    String? pdfUrl,
    String? pdfPath,
    NotesheetStatus? status,
    String? createdById,
    User? createdBy,
    List<String>? reviewerIds,
    List<User>? reviewers,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    String? notes,
  }) {
    return Notesheet(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      pdfPath: pdfPath ?? this.pdfPath,
      status: status ?? this.status,
      createdById: createdById ?? this.createdById,
      createdBy: createdBy ?? this.createdBy,
      reviewerIds: reviewerIds ?? this.reviewerIds,
      reviewers: reviewers ?? this.reviewers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      notes: notes ?? this.notes,
    );
  }
}
