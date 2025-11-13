import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../providers/notesheet_provider.dart';
import '../models/user.dart' as AppUser;

class CreateNotesheetScreen extends StatefulWidget {
  const CreateNotesheetScreen({Key? key}) : super(key: key);

  @override
  State<CreateNotesheetScreen> createState() => _CreateNotesheetScreenState();
}

class _CreateNotesheetScreenState extends State<CreateNotesheetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  List<String> _selectedReviewerIds = [];
  File? _selectedPdfFile;
  String? _selectedPdfFileName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notesheetProvider = Provider.of<NotesheetProvider>(
        context,
        listen: false,
      );
      notesheetProvider.loadReviewers();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedPdfFile = File(result.files.single.path!);
        _selectedPdfFileName = result.files.single.name;
      });
    }
  }

  Future<void> _createNotesheet() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedReviewerIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one reviewer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notesheetProvider = Provider.of<NotesheetProvider>(
        context,
        listen: false,
      );

      final notesheet = await notesheetProvider.createNotesheet(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        reviewerIds: _selectedReviewerIds,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (notesheet != null && _selectedPdfFile != null) {
        await notesheetProvider.uploadPdf(notesheet.id, _selectedPdfFile!);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notesheet created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notesheet'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createNotesheet,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter notesheet title',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Enter notesheet description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // PDF Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PDF Document',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              size: 48,
                              color: _selectedPdfFile != null
                                  ? Colors.red
                                  : Colors.grey,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedPdfFileName ?? 'No PDF selected',
                              style: TextStyle(
                                color: _selectedPdfFile != null
                                    ? Colors.black
                                    : Colors.grey,
                                fontWeight: _selectedPdfFile != null
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _pickPdfFile,
                              icon: const Icon(Icons.upload_file),
                              label: Text(
                                _selectedPdfFile != null
                                    ? 'Change PDF'
                                    : 'Select PDF',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reviewers Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Reviewers',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Consumer<NotesheetProvider>(
                        builder: (context, notesheetProvider, child) {
                          final reviewers = notesheetProvider.reviewers;

                          if (reviewers.isEmpty) {
                            return const Center(
                              child: Text('No reviewers available'),
                            );
                          }

                          return Column(
                            children: reviewers.map((reviewer) {
                              final isSelected = _selectedReviewerIds.contains(
                                reviewer.id,
                              );
                              return CheckboxListTile(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedReviewerIds.add(reviewer.id);
                                    } else {
                                      _selectedReviewerIds.remove(reviewer.id);
                                    }
                                  });
                                },
                                title: Text(reviewer.fullName),
                                subtitle: Text(reviewer.email),
                                secondary: CircleAvatar(
                                  child: Text(
                                    reviewer.firstName?.substring(0, 1) ?? 'U',
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'Enter any additional notes or instructions',
                ),
              ),
              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createNotesheet,
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 8),
                            Text('Creating...'),
                          ],
                        )
                      : const Text('Create Notesheet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
