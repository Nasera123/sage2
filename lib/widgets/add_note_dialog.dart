import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../controllers/folder_controller.dart';
import '../views/note_editor_view.dart';

class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({super.key});

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  String? _selectedFolderId;
  
  final NoteController _noteController = Get.find<NoteController>();
  final FolderController _folderController = Get.find<FolderController>();
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Create New Note',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFF333333)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Title',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter note title',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    autofocus: true,
                    onSubmitted: (_) => _createNoteAndNavigate(),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Folder',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF2A2A2A),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'No folder',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    value: _selectedFolderId,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('No folder', style: TextStyle(color: Colors.white)),
                      ),
                      ...(_folderController.folders)
                          .map((folder) => DropdownMenuItem<String>(
                                value: folder.id,
                                child: Text(folder.name, style: TextStyle(color: Colors.white)),
                              ))
                          .toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFolderId = value;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _createNoteAndNavigate,
                      child: const Text('Create', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _createNoteAndNavigate() async {
    if (_titleController.text.isNotEmpty) {
      // Close the dialog first
      Navigator.pop(context);
      
      // Create a new note
      final note = await _noteController.createNote(
        title: _titleController.text,
        content: "",
        folderId: _selectedFolderId,
      );
      
      if (context.mounted) {
        // Navigate to the note editor
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteEditorView(noteId: note.id),
          ),
        );
      }
    }
  }
} 