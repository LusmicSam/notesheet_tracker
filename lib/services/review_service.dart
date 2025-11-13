import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review.dart';
import '../models/notesheet.dart';
import '../utils/supabase_config.dart';

class ReviewService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Create a new review
  static Future<Review> createReview({
    required String notesheetId,
    required ReviewStatus status,
    String? comments,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final reviewData = {
        'notesheet_id': notesheetId,
        'reviewer_id': user.id,
        'status': status.name,
        'comments': comments,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final response = await _client.from('reviews').insert(reviewData).select(
        '''
            *,
            reviewer:users!reviewer_id(*),
            notesheet:notesheets!notesheet_id(*)
          ''',
      ).single();

      // Update notesheet status based on review
      await _updateNotesheetStatus(notesheetId, status);

      return Review.fromJson(response);
    } catch (e) {
      print('Create review error: $e');
      throw Exception('Failed to create review: ${e.toString()}');
    }
  }

  // Get reviews for a notesheet
  static Future<List<Review>> getNotesheetReviews(String notesheetId) async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviewer_id(*),
            notesheet:notesheets!notesheet_id(*)
          ''')
          .eq('notesheet_id', notesheetId)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      print('Get notesheet reviews error: $e');
      throw Exception('Failed to get reviews: ${e.toString()}');
    }
  }

  // Get reviews by reviewer
  static Future<List<Review>> getReviewsByReviewer() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviewer_id(*),
            notesheet:notesheets!notesheet_id(*)
          ''')
          .eq('reviewer_id', user.id)
          .order('created_at', ascending: false);

      return (response as List).map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      print('Get reviews by reviewer error: $e');
      throw Exception('Failed to get reviews: ${e.toString()}');
    }
  }

  // Update review
  static Future<Review> updateReview(
    String reviewId,
    ReviewStatus status,
    String? comments,
  ) async {
    try {
      final updates = {
        'status': status.name,
        'comments': comments,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('reviews')
          .update(updates)
          .eq('id', reviewId)
          .select('''
            *,
            reviewer:users!reviewer_id(*),
            notesheet:notesheets!notesheet_id(*)
          ''')
          .single();

      // Update notesheet status based on review
      final review = Review.fromJson(response);
      await _updateNotesheetStatus(review.notesheetId, status);

      return review;
    } catch (e) {
      print('Update review error: $e');
      throw Exception('Failed to update review: ${e.toString()}');
    }
  }

  // Delete review
  static Future<void> deleteReview(String reviewId) async {
    try {
      await _client.from('reviews').delete().eq('id', reviewId);
    } catch (e) {
      print('Delete review error: $e');
      throw Exception('Failed to delete review: ${e.toString()}');
    }
  }

  // Get all reviews (for admin)
  static Future<List<Review>> getAllReviews() async {
    try {
      final response = await _client
          .from('reviews')
          .select('''
            *,
            reviewer:users!reviewer_id(*),
            notesheet:notesheets!notesheet_id(*)
          ''')
          .order('created_at', ascending: false);

      return (response as List).map((data) => Review.fromJson(data)).toList();
    } catch (e) {
      print('Get all reviews error: $e');
      throw Exception('Failed to get all reviews: ${e.toString()}');
    }
  }

  // Private method to update notesheet status based on review
  static Future<void> _updateNotesheetStatus(
    String notesheetId,
    ReviewStatus reviewStatus,
  ) async {
    try {
      NotesheetStatus newStatus;
      DateTime? reviewedAt;

      switch (reviewStatus) {
        case ReviewStatus.pending:
          newStatus = NotesheetStatus.underReview;
          break;
        case ReviewStatus.approved:
          newStatus = NotesheetStatus.approved;
          reviewedAt = DateTime.now();
          break;
        case ReviewStatus.rejected:
          newStatus = NotesheetStatus.rejected;
          reviewedAt = DateTime.now();
          break;
        case ReviewStatus.needsRevision:
          newStatus = NotesheetStatus.needsRevision;
          reviewedAt = DateTime.now();
          break;
      }

      final updates = {
        'status': newStatus.name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (reviewedAt != null) {
        updates['reviewed_at'] = reviewedAt.toIso8601String();
      }

      await _client.from('notesheets').update(updates).eq('id', notesheetId);
    } catch (e) {
      print('Update notesheet status error: $e');
      // Don't throw here to avoid breaking the review creation
    }
  }
}
