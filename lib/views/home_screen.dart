import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../controllers/folder_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/tag_controller.dart';
import '../controllers/preferences_controller.dart';
import '../controllers/navigation_controller.dart';
import '../models/note_model.dart';
import 'notes_view.dart';
import 'folders_view.dart';
import 'books_view.dart';
import 'tags_view.dart';
import 'settings_view.dart';
import 'trash_view.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/app_drawer.dart';
import '../widgets/add_folder_dialog.dart';
import '../widgets/add_book_dialog.dart';
import 'note_editor_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _noteController = Get.find<NoteController>();
  final _folderController = Get.find<FolderController>();
  final _bookController = Get.find<BookController>();
  final _tagController = Get.find<TagController>();
  final _preferencesController = Get.find<PreferencesController>();
  final _navigationController = Get.find<NavigationController>();
  
  final List<String> _viewTitles = [
    'All Notes',
    'Folders',
    'Books',
    'Tags',
    'Settings',
    'Trash'
  ];
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = _navigationController.currentIndex;
      
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          elevation: 0,
          title: const Text('SAGE', 
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              )),
          leadingWidth: 40,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _showSearch();
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () {
                _navigationController.setCurrentIndex(4); // Settings view
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: currentIndex == 0 
            ? _buildNotesHomeView() 
            : _buildBody(currentIndex),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF3D5AFE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onPressed: () => _createAndNavigateToNewNote(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      );
    });
  }
  
  Widget _buildNotesHomeView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Profile Section
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Obx(() {
                    final avatarPath = _preferencesController.preferences.avatarPath;
                    return CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: avatarPath != null
                          ? FileImage(File(avatarPath))
                          : null,
                      child: avatarPath == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white70)
                          : null,
                    );
                  }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(color: const Color(0xFF1E1E1E), width: 2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      _preferencesController.preferences.displayName ?? 'Theodore Lunette',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    )),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Tap to edit profile',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  // Edit profile
                },
              ),
            ],
          ),
        ),
        
        // All Notes Header
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'All Notes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        
        // Notes List
        Expanded(
          child: _buildNotesList(),
        ),
      ],
    );
  }
  
  Widget _buildNotesList() {
    return Obx(() {
      final notes = _noteController.notes;
      
      if (notes.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No notes yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Tap + to create a new note',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return _buildNoteCard(note);
        },
      );
    });
  }
  
  Widget _buildNoteCard(Note note) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NoteEditorView(noteId: note.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  note.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _formatDate(note.updatedAt),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getContentPreview(note.content),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
  
  String _getContentPreview(String content) {
    // Clean up any markdown or formatting for preview
    return content.replaceAll(RegExp(r'\*\*|\*|__|\n'), ' ');
  }
  
  Widget _buildBody(int index) {
    switch (index) {
      case 0:
        return const NotesView();
      case 1:
        return const FoldersView();
      case 2:
        return const BooksView();
      case 3:
        return const TagsView();
      case 4:
        return const SettingsView();
      case 5:
        return const TrashView();
      default:
        return const Center(child: Text('Page not found'));
    }
  }
  
  void _handleAddAction() {
    int index = _navigationController.currentIndex;
    switch (index) {
      case 0: // All Notes
        _showAddNoteDialog();
        break;
      case 1: // Folders
        _showAddFolderDialog();
        break;
      case 2: // Books
        _showAddBookDialog();
        break;
      case 3: // Tags
        _showAddTagDialog();
        break;
    }
  }
  
  void _createAndNavigateToNewNote() async {
    // Create a new note with defaults
    final note = await _noteController.createNote(
      title: 'New Note',
      content: '',
    );
    
    // Navigate directly to the editor
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => NoteEditorView(noteId: note.id),
        ),
      );
    }
  }
  
  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddNoteDialog(),
    );
  }
  
  void _showAddFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddFolderDialog(),
    );
  }
  
  void _showAddBookDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddBookDialog(),
    );
  }
  
  void _showAddTagDialog() {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
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
                _tagController.createTag(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
  
  void _showSearch() {
    final searchController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Search Notes', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            labelText: 'Search',
            labelStyle: TextStyle(color: Colors.grey),
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo),
            ),
          ),
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              final searchResults = _noteController.searchNotes(value);
              Navigator.pop(context);
              _showSearchResults(searchResults, value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              if (searchController.text.isNotEmpty) {
                final searchResults = _noteController.searchNotes(searchController.text);
                Navigator.pop(context);
                _showSearchResults(searchResults, searchController.text);
              }
            },
            child: const Text('Search', style: TextStyle(color: Colors.indigo)),
          ),
        ],
      ),
    );
  }
  
  void _showSearchResults(List<Note> results, String query) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text('Results for "$query"', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: results.isEmpty
              ? const Center(child: Text('No results found', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(results[index].title, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(
                        'Last updated: ${_formatDate(results[index].updatedAt)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NoteEditorView(noteId: results[index].id),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
  
  void _confirmEmptyTrash() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Empty Trash', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to permanently delete all notes in the trash? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _noteController.emptyTrash();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Trash emptied'),
                  backgroundColor: Colors.indigo,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Empty Trash'),
          ),
        ],
      ),
    );
  }
} 