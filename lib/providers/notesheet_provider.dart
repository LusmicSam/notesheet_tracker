import 'package:flutter/material.dart';
import 'dart:io';
import '../models/notesheet.dart';
import '../models/user.dart' as AppUser;
import '../services/notesheet_service.dart';

class NotesheetProvider extends ChangeNotifier {
  List<Notesheet> _notesheets = [];
  List<Notesheet> _reviewNotesheets = [];
  List<AppUser.User> _reviewers = [];
  bool _isLoading = false;
  String? _error;

  List<Notesheet> get notesheets => _notesheets;
  List<Notesheet> get reviewNotesheets => _reviewNotesheets;
  List<AppUser.User> get reviewers => _reviewers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserNotesheets() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notesheets = await NotesheetService.getUserNotesheets();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotesheetsForReview() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviewNotesheets = await NotesheetService.getNotesheetsForReview();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadReviewers() async {
    try {
      _reviewers = await NotesheetService.getReviewers();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Notesheet?> createNotesheet({
    required String title,
    required String description,
    required List<String> reviewerIds,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notesheet = await NotesheetService.createNotesheet(
        title: title,
        description: description,
        reviewerIds: reviewerIds,
        notes: notes,
      );

      _notesheets.insert(0, notesheet);
      _error = null;
      notifyListeners();
      return notesheet;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> uploadPdf(String notesheetId, File pdfFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pdfUrl = await NotesheetService.uploadPdf(notesheetId, pdfFile);

      // Update the notesheet in the list
      final index = _notesheets.indexWhere((n) => n.id == notesheetId);
      if (index != -1) {
        _notesheets[index] = _notesheets[index].copyWith(pdfUrl: pdfUrl);
      }

      _error = null;
      notifyListeners();
      return pdfUrl;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitForReview(String notesheetId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNotesheet = await NotesheetService.submitForReview(
        notesheetId,
      );

      // Update the notesheet in the list
      final index = _notesheets.indexWhere((n) => n.id == notesheetId);
      if (index != -1) {
        _notesheets[index] = updatedNotesheet;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNotesheet(String id, Map<String, dynamic> updates) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNotesheet = await NotesheetService.updateNotesheet(
        id,
        updates,
      );

      // Update the notesheet in the list
      final index = _notesheets.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notesheets[index] = updatedNotesheet;
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNotesheet(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await NotesheetService.deleteNotesheet(id);
      _notesheets.removeWhere((n) => n.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
