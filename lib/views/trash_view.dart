import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../models/note_model.dart';

class TrashView extends StatelessWidget {
  const TrashView({super.key});

  @override
  Widget build(BuildContext context) {
    final noteController = Get.find<NoteController>();

    return Obx(() {
      if (noteController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final trashedNotes = noteController.trashedNotes;

      if (trashedNotes.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Trash is empty'),
              SizedBox(height: 8),
              Text(
                'Deleted notes will appear here',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: trashedNotes.length,
        itemBuilder: (context, index) {
          final note = trashedNotes[index];
          return _buildTrashedNoteItem(context, note, noteController);
        },
      );
    });
  }

  Widget _buildTrashedNoteItem(
    BuildContext context, 
    Note note, 
    NoteController noteController
  ) {
    return Dismissible(
      key: Key(note.id),
      background: Container(
        color: Colors.green,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.restore,
          color: Colors.white,
        ),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_forever,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Delete permanently
          return await _showDeleteConfirmation(context);
        } else {
          // Restore note
          await noteController.restoreNoteFromTrash(note.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note "${note.title}" restored'),
              duration: const Duration(seconds: 2),
            ),
          );
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          noteController.deleteNotePermanently(note.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Note permanently deleted'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: ListTile(
        title: Text(
          note.title,
          style: const TextStyle(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          'Deleted on: ${_formatDate(note.updatedAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () {
                noteController.restoreNoteFromTrash(note.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Note "${note.title}" restored'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever),
              onPressed: () => _confirmDelete(context, note, noteController),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently'),
        content: const Text(
          'Are you sure you want to permanently delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _confirmDelete(
    BuildContext context, 
    Note note, 
    NoteController noteController
  ) async {
    final delete = await _showDeleteConfirmation(context);
    if (delete) {
      noteController.deleteNotePermanently(note.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note permanently deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 