import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notesheet.dart';

class NotesheetCard extends StatelessWidget {
  final Notesheet notesheet;
  final VoidCallback? onTap;
  final bool showReviewActions;

  const NotesheetCard({
    Key? key,
    required this.notesheet,
    this.onTap,
    this.showReviewActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor().withOpacity(0.1),
          child: Icon(_getStatusIcon(), color: _getStatusColor()),
        ),
        title: Text(
          notesheet.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notesheet.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  DateFormat('MMM dd, yyyy').format(notesheet.createdAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    notesheet.statusString,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: showReviewActions
            ? PopupMenuButton<String>(
                onSelected: (value) {
                  // Handle review actions
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'approve',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Approve'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Reject'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'revision',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Needs Revision'),
                      ],
                    ),
                  ),
                ],
              )
            : const Icon(Icons.arrow_forward_ios),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }

  Color _getStatusColor() {
    switch (notesheet.status) {
      case NotesheetStatus.draft:
        return Colors.grey;
      case NotesheetStatus.submitted:
        return Colors.blue;
      case NotesheetStatus.underReview:
        return Colors.orange;
      case NotesheetStatus.needsRevision:
        return Colors.red;
      case NotesheetStatus.approved:
        return Colors.green;
      case NotesheetStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon() {
    switch (notesheet.status) {
      case NotesheetStatus.draft:
        return Icons.edit_note;
      case NotesheetStatus.submitted:
        return Icons.send;
      case NotesheetStatus.underReview:
        return Icons.rate_review;
      case NotesheetStatus.needsRevision:
        return Icons.edit;
      case NotesheetStatus.approved:
        return Icons.check_circle;
      case NotesheetStatus.rejected:
        return Icons.cancel;
    }
  }
}
