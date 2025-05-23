import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../models/note_model.dart';
import 'note_editor_view.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final noteController = Get.find<NoteController>();

    return Obx(() {
      if (noteController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final notes = noteController.notes;
      
      if (notes.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No notes yet'),
              SizedBox(height: 8),
              Text('Create a new note to get started', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteListItem(note: note);
        },
      );
    });
  }
}

class NoteListItem extends StatelessWidget {
  final Note note;

  const NoteListItem({
    super.key,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(
          _formatDate(note.updatedAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // For now, just display a snackbar since we haven't built the editor yet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Note "${note.title}" selected'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 