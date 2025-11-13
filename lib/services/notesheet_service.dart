import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../models/notesheet.dart';
import '../models/user.dart' as AppUser;
import '../utils/supabase_config.dart';

class NotesheetService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Create a new notesheet
  static Future<Notesheet> createNotesheet({
    required String title,
    required String description,
    required List<String> reviewerIds,
    String? notes,
  }) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final now = DateTime.now();
      final notesheetData = {
        'title': title,
        'description': description,
        'status': NotesheetStatus.draft.name,
        'created_by_id': user.id,
        'reviewer_ids': reviewerIds,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'notes': notes,
      };

      final response = await _client
          .from('notesheets')
          .insert(notesheetData)
          .select()
          .single();

      return Notesheet.fromJson(response);
    } catch (e) {
      print('Create notesheet error: $e');
      throw Exception('Failed to create notesheet: ${e.toString()}');
    }
  }

  // Upload PDF file
  static Future<String> uploadPdf(String notesheetId, File pdfFile) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          '${notesheetId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = 'notesheets/$fileName';

      await _client.storage
          .from('documents')
          .upload(
            filePath,
            pdfFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final publicUrl = _client.storage
          .from('documents')
          .getPublicUrl(filePath);

      // Update notesheet with PDF URL
      await _client
          .from('notesheets')
          .update({
            'pdf_url': publicUrl,
            'pdf_path': filePath,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notesheetId);

      return publicUrl;
    } catch (e) {
      print('Upload PDF error: $e');
      throw Exception('Failed to upload PDF: ${e.toString()}');
    }
  }

  // Get all notesheets for current user
  static Future<List<Notesheet>> getUserNotesheets() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('notesheets')
          .select('''
            *,
            created_by:users!created_by_id(*),
            reviewers:users!reviewer_ids(*)
          ''')
          .eq('created_by_id', user.id)
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Notesheet.fromJson(data))
          .toList();
    } catch (e) {
      print('Get user notesheets error: $e');
      throw Exception('Failed to get notesheets: ${e.toString()}');
    }
  }

  // Get notesheets for review (for reviewers)
  static Future<List<Notesheet>> getNotesheetsForReview() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('notesheets')
          .select('''
            *,
            created_by:users!created_by_id(*),
            reviewers:users!reviewer_ids(*)
          ''')
          .contains('reviewer_ids', [user.id])
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Notesheet.fromJson(data))
          .toList();
    } catch (e) {
      print('Get notesheets for review error: $e');
      throw Exception('Failed to get notesheets for review: ${e.toString()}');
    }
  }

  // Get all notesheets (for admin)
  static Future<List<Notesheet>> getAllNotesheets() async {
    try {
      final response = await _client
          .from('notesheets')
          .select('''
            *,
            created_by:users!created_by_id(*),
            reviewers:users!reviewer_ids(*)
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((data) => Notesheet.fromJson(data))
          .toList();
    } catch (e) {
      print('Get all notesheets error: $e');
      throw Exception('Failed to get all notesheets: ${e.toString()}');
    }
  }

  // Get notesheet by ID
  static Future<Notesheet> getNotesheet(String id) async {
    try {
      final response = await _client
          .from('notesheets')
          .select('''
            *,
            created_by:users!created_by_id(*),
            reviewers:users!reviewer_ids(*)
          ''')
          .eq('id', id)
          .single();

      return Notesheet.fromJson(response);
    } catch (e) {
      print('Get notesheet error: $e');
      throw Exception('Failed to get notesheet: ${e.toString()}');
    }
  }

  // Update notesheet
  static Future<Notesheet> updateNotesheet(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      final response = await _client
          .from('notesheets')
          .update(updates)
          .eq('id', id)
          .select('''
            *,
            created_by:users!created_by_id(*),
            reviewers:users!reviewer_ids(*)
          ''')
          .single();

      return Notesheet.fromJson(response);
    } catch (e) {
      print('Update notesheet error: $e');
      throw Exception('Failed to update notesheet: ${e.toString()}');
    }
  }

  // Submit notesheet for review
  static Future<Notesheet> submitForReview(String id) async {
    try {
      final updates = {
        'status': NotesheetStatus.submitted.name,
        'submitted_at': DateTime.now().toIso8601String(),
      };

      return await updateNotesheet(id, updates);
    } catch (e) {
      print('Submit for review error: $e');
      throw Exception('Failed to submit for review: ${e.toString()}');
    }
  }

  // Delete notesheet
  static Future<void> deleteNotesheet(String id) async {
    try {
      // First, get the notesheet to get the PDF path
      final notesheet = await getNotesheet(id);

      // Delete PDF file if exists
      if (notesheet.pdfPath != null) {
        await _client.storage.from('documents').remove([notesheet.pdfPath!]);
      }

      // Delete the notesheet record
      await _client.from('notesheets').delete().eq('id', id);
    } catch (e) {
      print('Delete notesheet error: $e');
      throw Exception('Failed to delete notesheet: ${e.toString()}');
    }
  }

  // Get reviewers (users with reviewer role)
  static Future<List<AppUser.User>> getReviewers() async {
    try {
      final response = await _client
          .from('users')
          .select()
          .or('role.eq.reviewer,role.eq.admin')
          .order('first_name');

      return (response as List)
          .map((data) => AppUser.User.fromJson(data))
          .toList();
    } catch (e) {
      print('Get reviewers error: $e');
      throw Exception('Failed to get reviewers: ${e.toString()}');
    }
  }
}
