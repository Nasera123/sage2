import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/folder_controller.dart';
import '../controllers/note_controller.dart';
import '../models/folder_model.dart';

class FoldersView extends StatelessWidget {
  const FoldersView({super.key});

  @override
  Widget build(BuildContext context) {
    final folderController = Get.find<FolderController>();
    final noteController = Get.find<NoteController>();

    return Obx(() {
      if (folderController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final rootFolders = folderController.getRootFolders();
      
      if (rootFolders.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No folders yet'),
              SizedBox(height: 8),
              Text('Create a folder to organize your notes', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: rootFolders.length,
        itemBuilder: (context, index) {
          return FolderListItem(
            folder: rootFolders[index],
            folderController: folderController,
            noteController: noteController,
          );
        },
      );
    });
  }
}

class FolderListItem extends StatelessWidget {
  final Folder folder;
  final FolderController folderController;
  final NoteController noteController;

  const FolderListItem({
    super.key,
    required this.folder,
    required this.folderController,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    final notes = noteController.getNotesByFolder(folder.id);
    final hasChildFolders = folderController.hasChildFolders(folder.id);

    return ExpansionTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.name),
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
            value: 'add_subfolder',
            child: ListTile(
              leading: Icon(Icons.create_new_folder),
              title: Text('Add Subfolder'),
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
      children: [
        if (hasChildFolders) ..._buildSubfolders(),
        if (notes.isNotEmpty) ..._buildNotes(context),
        if (notes.isEmpty && !hasChildFolders)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('This folder is empty', style: TextStyle(fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }

  List<Widget> _buildSubfolders() {
    final childFolders = folderController.getChildFolders(folder.id);
    return childFolders.map((childFolder) {
      return Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: FolderListItem(
          folder: childFolder,
          folderController: folderController,
          noteController: noteController,
        ),
      );
    }).toList();
  }

  List<Widget> _buildNotes(BuildContext context) {
    final notes = noteController.getNotesByFolder(folder.id);
    return notes.map((note) {
      return ListTile(
        leading: const Icon(Icons.note),
        title: Text(note.title),
        subtitle: Text(
          _formatDate(note.updatedAt),
          style: const TextStyle(fontSize: 12),
        ),
        onTap: () {
          // Navigate to note editor
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Opening note "${note.title}"'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      );
    }).toList();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'rename':
        _showRenameDialog(context);
        break;
      case 'add_subfolder':
        _showAddSubfolderDialog(context);
        break;
      case 'delete':
        _showDeleteConfirmation(context);
        break;
    }
  }

  void _showRenameDialog(BuildContext context) {
    final nameController = TextEditingController(text: folder.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Folder Name',
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
                folderController.renameFolder(folder.id, nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddSubfolderDialog(BuildContext context) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Subfolder to "${folder.name}"'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Subfolder Name',
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
                folderController.createFolder(nameController.text, parentId: folder.id);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final notes = noteController.getNotesByFolder(folder.id);
    final hasChildFolders = folderController.hasChildFolders(folder.id);
    
    String warningMessage = 'Are you sure you want to delete this folder?';
    if (notes.isNotEmpty) {
      warningMessage += '\n\nAll ${notes.length} notes in this folder will be moved to trash.';
    }
    if (hasChildFolders) {
      warningMessage += '\n\nAll subfolders will also be deleted.';
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(warningMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              folderController.deleteFolder(folder.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 