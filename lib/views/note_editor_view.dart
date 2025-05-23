import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/note_controller.dart';
import '../controllers/tag_controller.dart';
import '../models/note_model.dart';

class NoteEditorView extends StatefulWidget {
  final String noteId;
  
  const NoteEditorView({super.key, required this.noteId});

  @override
  State<NoteEditorView> createState() => _NoteEditorViewState();
}

class _NoteEditorViewState extends State<NoteEditorView> {
  late final NoteController _noteController;
  late final TagController _tagController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  Note? _note;
  bool _isLoading = true;
  bool _isDirty = false;
  bool _showToolbar = false;
  Timer? _typingTimer;
  Timer? _autoSaveTimer;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _editorFocus = FocusNode();
  
  @override
  void initState() {
    super.initState();
    _noteController = Get.find<NoteController>();
    _tagController = Get.find<TagController>();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadNote();
    
    // Setup auto-save timer
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isDirty && mounted) {
        _saveChanges();
      }
    });
  }
  
  @override
  void dispose() {
    _saveChanges();
    _titleController.dispose();
    _contentController.dispose();
    _titleFocus.dispose();
    _editorFocus.dispose();
    _typingTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }
  
  Future<void> _loadNote() async {
    setState(() {
      _isLoading = true;
    });
    
    final note = await _noteController.getNote(widget.noteId);
    if (note != null) {
      _note = note;
      _titleController.text = note.title;
      _contentController.text = note.content;
      
      // Listen for changes to mark as dirty and trigger auto-save
      _titleController.addListener(() {
        _markDirty();
        // Update the app bar title immediately
        if (_note != null && mounted) {
          setState(() {
            // We don't immediately save the title, it'll be saved on the next auto-save
          });
        }
      });
      
      _contentController.addListener(() {
        _markDirty();
        _resetTypingTimer();
      });
    }
    
    setState(() {
      _isLoading = false;
      _isDirty = false;
    });
  }
  
  void _resetTypingTimer() {
    setState(() {
      _showToolbar = false;
    });
    
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showToolbar = true;
        });
      }
    });
  }
  
  void _markDirty() {
    if (!_isDirty && mounted) {
      setState(() {
        _isDirty = true;
      });
    }
  }
  
  Future<void> _saveChanges() async {
    if (_isDirty && _note != null) {
      // Update note
      final updatedNote = _note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        updatedAt: DateTime.now(),
      );
      
      await _noteController.updateNote(updatedNote);
      _note = updatedNote;
      
      if (mounted) {
        setState(() {
          _isDirty = false;
        });
      }
    }
  }
  
  Future<void> _insertImage() async {
    if (kIsWeb) {
      // Simple alert for web platform where we can't access file system
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: const Text('Image Upload', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Image upload is not supported in web version.', 
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.blue)),
            )
          ],
        ),
      );
      return;
    }
    
    final ImagePicker picker = ImagePicker();
    
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final imagePath = await _noteController.addImageToNote(file);
      
      // Insert image reference in text
      final imageTag = '\n[Image: $imagePath]\n';
      final currentPosition = _contentController.selection.baseOffset;
      
      if (currentPosition >= 0) {
        final newText = _contentController.text.substring(0, currentPosition) + 
                       imageTag + 
                       _contentController.text.substring(currentPosition);
        _contentController.text = newText;
        _contentController.selection = TextSelection.collapsed(
          offset: currentPosition + imageTag.length
        );
      } else {
        _contentController.text += imageTag;
      }
      
      _markDirty();
    }
  }
  
  String _formatDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.hour}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}';
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    
    if (_note == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121212),
          title: const Text('Error', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Note not found', style: TextStyle(color: Colors.white))),
      );
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            _saveChanges();
            Navigator.pop(context);
          },
        ),
        title: Text(
          _titleController.text.isEmpty ? 'New Note' : _titleController.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              _noteController.moveNoteToTrash(_note!.id);
              Navigator.pop(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.tag, color: Colors.white),
            onPressed: () {
              // Add tag functionality could be added here
            },
          ),
          IconButton(
            icon: const Icon(Icons.music_note, color: Colors.white),
            onPressed: () {
              // Music note functionality could be added here
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_alt, color: Colors.white),
            onPressed: () {
              // Export functionality could be added here
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Title field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _titleController,
              focusNode: _titleFocus,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'New Note',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) {
                _editorFocus.requestFocus();
              },
            ),
          ),
          
          // Divider
          const Divider(height: 1, color: Color(0xFF333333)),
          
          // Content field
          Expanded(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: _contentController,
                    focusNode: _editorFocus,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Start typing...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                
                // Floating toolbar that shows after 5 seconds of inactivity
                if (_showToolbar)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.format_bold, color: Colors.white),
                            onPressed: () => _insertFormatting('**', '**'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_italic, color: Colors.white),
                            onPressed: () => _insertFormatting('_', '_'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
                            onPressed: () => _insertFormatting('\n- ', ''),
                          ),
                          IconButton(
                            icon: const Icon(Icons.format_list_numbered, color: Colors.white),
                            onPressed: () => _insertFormatting('\n1. ', ''),
                          ),
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.white),
                            onPressed: _insertImage,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Save button and status
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5AFE),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _saveChanges,
                  child: const Text('Simpan Perubahan'),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isDirty ? Icons.edit : Icons.check,
                      size: 14,
                      color: _isDirty ? Colors.amber : Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isDirty 
                          ? 'Unsaved changes'
                          : 'All changes saved',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isDirty ? Colors.amber : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_note != null)
                      Text(
                        'Last updated: ${_formatDateTime(_note!.updatedAt)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  void _insertFormatting(String prefix, String suffix) {
    final currentText = _contentController.text;
    final selection = _contentController.selection;
    
    if (selection.isValid) {
      final selectedText = currentText.substring(selection.start, selection.end);
      final newText = prefix + selectedText + suffix;
      
      final newTextWithReplacement = currentText.replaceRange(
        selection.start, 
        selection.end, 
        newText
      );
      
      _contentController.text = newTextWithReplacement;
      _contentController.selection = TextSelection(
        baseOffset: selection.start + prefix.length,
        extentOffset: selection.end + prefix.length,
      );
    } else {
      final currentPosition = selection.baseOffset;
      final newText = currentText.substring(0, currentPosition) + 
                     prefix + suffix + 
                     currentText.substring(currentPosition);
      
      _contentController.text = newText;
      _contentController.selection = TextSelection.collapsed(
        offset: currentPosition + prefix.length,
      );
    }
    
    _resetTypingTimer();
  }
} 