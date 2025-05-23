import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/tag_controller.dart';
import '../controllers/note_controller.dart';
import '../models/tag_model.dart';
import '../models/note_model.dart';

class TagsView extends StatelessWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context) {
    final tagController = Get.find<TagController>();

    return Obx(() {
      if (tagController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final tags = tagController.tags;
      
      if (tags.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.label_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No tags yet'),
              SizedBox(height: 8),
              Text('Create tags to categorize your notes', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: tags.length,
        itemBuilder: (context, index) {
          return TagListItem(tag: tags[index]);
        },
      );
    });
  }
}

class TagListItem extends StatelessWidget {
  final Tag tag;

  const TagListItem({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    final noteController = Get.find<NoteController>();
    final tagController = Get.find<TagController>();
    
    final notes = noteController.getNotesByTag(tag.id);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: tag.color,
        child: const Icon(Icons.label, color: Colors.white),
      ),
      title: Text(tag.name),
      subtitle: Text('${notes.length} notes'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'rename',
            child: ListTile(
              leading: Icon(Icons.edit),
              title: Text('Rename'),
            ),
          ),
          const PopupMenuItem(
            value: 'color',
            child: ListTile(
              leading: Icon(Icons.color_lens),
              title: Text('Change Color'),
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
            ),
          ),
        ],
      ),
      onTap: () {
        // Show notes with this tag
        _showNotesWithTag(context);
      },
    );
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'color':
        _showColorPickerDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showNotesWithTag(BuildContext context) {
    final noteController = Get.find<NoteController>();
    final notes = noteController.getNotesByTag(tag.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: tag.color,
              radius: 12,
              child: const Icon(Icons.label, color: Colors.white, size: 12),
            ),
            const SizedBox(width: 8),
            Text('Notes with tag "${tag.name}"'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: notes.isEmpty
              ? const Center(child: Text('No notes with this tag'))
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return _buildNoteListItem(context, note);
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteListItem(BuildContext context, Note note) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        'Last updated: ${_formatDate(note.updatedAt)}',
        style: const TextStyle(fontSize: 12),
      ),
      onTap: () {
        // Navigate to note
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening note "${note.title}"'),
            duration: const Duration(seconds: 1),
          ),
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    final tagController = Get.find<TagController>();
    final nameController = TextEditingController(text: tag.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Tag'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Tag Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                tagController.renameTag(tag.id, nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showColorPickerDialog(BuildContext context) {
    final tagController = Get.find<TagController>();
    Color selectedColor = tag.color;
    
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Tag Color'),
          content: Container(
            width: 300,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: selectedColor == color
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                      boxShadow: selectedColor == color
                          ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                tagController.changeTagColor(tag.id, selectedColor);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final tagController = Get.find<TagController>();
    final noteController = Get.find<NoteController>();
    final notes = noteController.getNotesByTag(tag.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Tag'),
        content: Text(
          'Are you sure you want to delete tag "${tag.name}"?\n\n' +
          'The tag will be removed from ${notes.length} notes, but the notes will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              tagController.deleteTag(tag.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 