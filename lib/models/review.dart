import 'user.dart';
import 'notesheet.dart';

enum ReviewStatus { pending, approved, rejected, needsRevision }

class Review {
  final String id;
  final String notesheetId;
  final Notesheet? notesheet;
  final String reviewerId;
  final User? reviewer;
  final ReviewStatus status;
  final String? comments;
  final DateTime createdAt;
  final DateTime updatedAt;

  Review({
    required this.id,
    required this.notesheetId,
    this.notesheet,
    required this.reviewerId,
    this.reviewer,
    required this.status,
    this.comments,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      notesheetId: json['notesheet_id'],
      notesheet: json['notesheet'] != null
          ? Notesheet.fromJson(json['notesheet'])
          : null,
      reviewerId: json['reviewer_id'],
      reviewer: json['reviewer'] != null
          ? User.fromJson(json['reviewer'])
          : null,
      status: ReviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReviewStatus.pending,
      ),
      comments: json['comments'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notesheet_id': notesheetId,
      'reviewer_id': reviewerId,
      'status': status.name,
      'comments': comments,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusString {
    switch (status) {
      case ReviewStatus.pending:
        return 'Pending';
      case ReviewStatus.approved:
        return 'Approved';
      case ReviewStatus.rejected:
        return 'Rejected';
      case ReviewStatus.needsRevision:
        return 'Needs Revision';
    }
  }
}
