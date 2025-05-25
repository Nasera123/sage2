import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/book_controller.dart';
import '../controllers/note_controller.dart';
import '../models/book_model.dart';
import '../models/note_model.dart';
import 'note_editor_view.dart';

class BookEditorView extends StatefulWidget {
  final String? bookId;
  
  const BookEditorView({Key? key, this.bookId}) : super(key: key);

  @override
  State<BookEditorView> createState() => _BookEditorViewState();
}

class _BookEditorViewState extends State<BookEditorView> {
  final BookController _bookController = Get.find<BookController>();
  final NoteController _noteController = Get.find<NoteController>();
  final TextEditingController _titleController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  bool _isSaved = false;
  Book? _book;
  File? _coverImageFile;
  List<Note> _bookPages = [];
  
  @override
  void initState() {
    super.initState();
    _loadBook();
  }
  
  Future<void> _loadBook() async {
    if (widget.bookId != null) {
      setState(() => _isLoading = true);
      try {
        final book = await _bookController.getBook(widget.bookId!);
        if (book != null) {
          _book = book;
          _titleController.text = book.title;
          _refreshPages();
          _isSaved = true;
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _refreshPages() async {
    if (_book != null) {
      setState(() => _isLoading = true);
      
      try {
        // First reload the book to get the latest noteIds
        final updatedBook = await _bookController.getBook(_book!.id);
        if (updatedBook != null) {
          _book = updatedBook;
        }
        
        // Reload each note to get the latest version
        List<Note> updatedPages = [];
        for (var noteId in _book!.noteIds) {
          final note = await _noteController.getNote(noteId);
          if (note != null) {
            updatedPages.add(note);
          }
        }
        
        // Sort pages by page number
        updatedPages.sort((a, b) {
          final aPage = a.bookPageNumber ?? 9999;
          final bPage = b.bookPageNumber ?? 9999;
          return aPage.compareTo(bPage);
        });
        
        setState(() {
          _bookPages = updatedPages;
        });
        
        // Show feedback to the user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pages refreshed successfully'),
            duration: Duration(seconds: 1),
          ),
        );
      } catch (e) {
        // Show error message if refresh fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing pages: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImageFile = File(image.path);
      });
    }
  }
  
  Future<void> _takePhoto() async {
    final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _coverImageFile = File(photo.path);
      });
    }
  }
  
  Future<void> _saveBook() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a book title')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      if (_book == null) {
        // Create new book
        final book = await _bookController.createBook(_titleController.text.trim());
        
        if (_coverImageFile != null) {
          await _bookController.setCoverImage(book.id, _coverImageFile!);
        }
        
        setState(() {
          _book = book;
          _isSaved = true;
        });
      } else {
        // Update existing book
        await _bookController.renameBook(_book!.id, _titleController.text.trim());
        
        if (_coverImageFile != null) {
          await _bookController.setCoverImage(_book!.id, _coverImageFile!);
        }
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deleteBook() async {
    if (_book == null) return;
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Book', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${_book!.title}"? All pages in this book will also be deleted.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      
      try {
        // First show feedback to user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleting book...')),
        );
        
        // Delete all notes in the book first
        for (var noteId in _book!.noteIds) {
          await _noteController.deleteNote(noteId);
        }
        
        // Then delete the book
        await _bookController.deleteBook(_book!.id);
        
        // Return to previous screen
        Get.back(result: true);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }
  
  Future<void> _addNewPage() async {
    if (_book == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please save the book first')),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final pageNumber = _bookPages.length + 1;
      final note = await _noteController.createNote(
        title: 'Page $pageNumber',
        content: '',
        bookId: _book!.id,
        bookPageNumber: pageNumber,
      );
      
      await _bookController.addNoteToBook(_book!.id, note.id, pageNumber: pageNumber);
      
      // Add to local list immediately for real-time update
      setState(() {
        _bookPages.add(note);
      });
      
      // Then refresh for consistency
      await _refreshPages();
      
      // Navigate to note editor
      await _navigateToNoteEditor(note.id);
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _deletePage(Note page) async {
    if (_book == null) return;
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Delete Page', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${page.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      setState(() => _isLoading = true);
      
      try {
        // Remove the note from the book
        await _bookController.removeNoteFromBook(_book!.id, page.id);
        
        // Remove from local list immediately for real-time update
        setState(() {
          _bookPages.removeWhere((p) => p.id == page.id);
        });
        
        // Renumber the remaining pages
        await _reorderBookPages();
        
        // Refresh the list for consistency
        await _refreshPages();
        
        // Show confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Page deleted')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _reorderBookPages() async {
    if (_book == null) return;
    
    // Get all notes in the book
    final notes = _bookController.getSortedBookNotes(_book!.id);
    
    // Update page numbers
    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      if (note.bookPageNumber != i + 1) {
        // Update page number
        final updatedNote = note.copyWith(
          bookPageNumber: i + 1,
        );
        await _noteController.updateNote(updatedNote);
      }
    }
  }
  
  Future<void> _editPage(Note page) async {
    await _navigateToNoteEditor(page.id);
  }
  
  // Navigate to note editor with proper navigation handling
  Future<void> _navigateToNoteEditor(String noteId) async {
    try {
      final result = await Get.to(() => NoteEditorView(noteId: noteId), preventDuplicates: false);
      if (result == true) {
        await _refreshPages();
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      // Fallback refresh in case of navigation issues
      await _refreshPages();
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Text(
          _titleController.text.isEmpty ? 'New Book' : _titleController.text,
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(result: true),
        ),
        actions: [
          if (_book != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteBook,
              tooltip: 'Delete Book',
            ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _refreshPages,
            tooltip: 'Refresh Pages',
          ),
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveBook,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _refreshPages,
            color: const Color(0xFF3D5AFE),
            backgroundColor: const Color(0xFF1A1A1A),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: 200,
                              height: 300,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A3A),
                                borderRadius: BorderRadius.circular(8),
                                image: _coverImageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_coverImageFile!),
                                        fit: BoxFit.cover,
                                      )
                                    : _book?.coverImagePath != null
                                        ? DecorationImage(
                                            image: FileImage(File(_book!.coverImagePath!)),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: _coverImageFile == null && _book?.coverImagePath == null
                                  ? Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(
                                          Icons.add_photo_alternate,
                                          size: 48,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Add Cover',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, color: Colors.white),
                              onPressed: _takePhoto,
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.grey.shade700.withOpacity(0.7),
                                shape: const CircleBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Book Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter book title',
                        hintStyle: const TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF1A1A1A),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => _titleController.clear(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Pages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _isSaved
                        ? _bookPages.isEmpty
                            ? const Center(
                                child: Text(
                                  'No pages yet',
                                  style: TextStyle(color: Colors.grey, fontSize: 16),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _bookPages.length,
                                itemBuilder: (context, index) {
                                  final page = _bookPages[index];
                                  return _buildPageItem(page, index);
                                },
                              )
                        : const Center(
                            child: Text(
                              'Save the book first to add pages',
                              style: TextStyle(color: Colors.grey, fontSize: 16),
                            ),
                          ),
                    const SizedBox(height: 24),
                    if (_isSaved)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _addNewPage,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Page'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A1A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBook,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A1A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: _isSaved
          ? FloatingActionButton(
              onPressed: _addNewPage,
              backgroundColor: const Color(0xFF3D5AFE),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
  
  Widget _buildPageItem(Note page, int index) {
    return Dismissible(
      key: Key(page.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        await _deletePage(page);
        return false; // don't dismiss automatically, we'll refresh the list
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF3D5AFE),
          child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(
          page.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Last edited: ${_formatDate(page.updatedAt)}',
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deletePage(page),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
        onTap: () => _editPage(page),
        tileColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 