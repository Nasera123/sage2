import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
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
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _editorFocus = FocusNode();
  final GlobalKey _editorKey = GlobalKey();
  
  Note? _note;
  bool _isLoading = true;
  bool _isDirty = false;
  bool _showToolbar = false;
  bool _hasTextSelection = false;
  Timer? _typingTimer;
  Timer? _autoSaveTimer;
  
  // Simple formatting tracking
  int _boldStart = -1;
  int _boldEnd = -1;
  int _italicStart = -1;
  int _italicEnd = -1;
  
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
        if (_note != null && mounted) {
          setState(() {});
        }
      });
      
      _contentController.addListener(() {
        _markDirty();
        _resetTypingTimer();
        _checkTextSelection();
      });
    }
    
    setState(() {
      _isLoading = false;
      _isDirty = false;
    });
  }
  
  void _checkTextSelection() {
    final selection = _contentController.selection;
    final hasSelection = selection.isValid && selection.start != selection.end;
    
    if (hasSelection != _hasTextSelection) {
      setState(() {
        _hasTextSelection = hasSelection;
        _showToolbar = hasSelection ? true : _showToolbar;
      });
    }
  }
  
  void _resetTypingTimer() {
    if (!_hasTextSelection) {
      setState(() {
        _showToolbar = false;
      });
    }
    
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
      // Update note with current content
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
  
  // Handle back navigation with proper result
  void _handleBackPress() async {
    await _saveChanges();
    Get.back(result: true);
  }
  
  // Handle delete and navigation
  void _handleDeletePress() async {
    await _noteController.moveNoteToTrash(_note!.id);
    Get.back(result: true);
  }
  
  void _insertFormatting(String prefix, String suffix) {
    final currentText = _contentController.text;
    final selection = _contentController.selection;
    
    if (selection.isValid) {
      // Get the selected text
      final selectedText = currentText.substring(selection.start, selection.end);
      
      // Check if the selected text already has this formatting
      bool alreadyHasFormatting = false;
      
      if (prefix == '**' && suffix == '**') {
        alreadyHasFormatting = selectedText.startsWith('**') && selectedText.endsWith('**');
      } else if (prefix == '_' && suffix == '_') {
        alreadyHasFormatting = selectedText.startsWith('_') && selectedText.endsWith('_');
      } else if (prefix == '~~' && suffix == '~~') {
        alreadyHasFormatting = selectedText.startsWith('~~') && selectedText.endsWith('~~');
      }
      
      String newText;
      int newStart, newEnd;
      
      if (alreadyHasFormatting) {
        // If already formatted, remove the formatting
        newText = selectedText.substring(prefix.length, selectedText.length - suffix.length);
        newStart = selection.start;
        newEnd = selection.start + newText.length;
      } else {
        // Add the formatting
        newText = prefix + selectedText + suffix;
        newStart = selection.start + prefix.length;
        newEnd = selection.end + prefix.length;
      }
      
      final newTextWithReplacement = currentText.replaceRange(
        selection.start, 
        selection.end, 
        newText
      );
      
      _contentController.value = TextEditingValue(
        text: newTextWithReplacement,
        selection: TextSelection(
          baseOffset: newStart,
          extentOffset: newEnd,
        ),
      );
    } else if (selection.baseOffset >= 0) {
      // No selection, just insert at cursor
      final currentPosition = selection.baseOffset;
      final newText = currentText.substring(0, currentPosition) + 
                     prefix + suffix + 
                     currentText.substring(currentPosition);
      
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: currentPosition + prefix.length,
        ),
      );
    }
    
    // Focus back on the editor and mark as dirty
    _editorFocus.requestFocus();
    _markDirty();
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
          onPressed: _handleBackPress,
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
            onPressed: _handleDeletePress,
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
                    key: _editorKey,
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
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _checkTextSelection();
                      });
                    },
                    onChanged: (_) {
                      _checkTextSelection();
                      // Add another delayed check to catch selection after keyboard actions
                      Future.delayed(const Duration(milliseconds: 200), () {
                        if (mounted) _checkTextSelection();
                      });
                    },
                  ),
                ),
                
                // Floating toolbar
                if (_showToolbar || _hasTextSelection)
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.format_bold, color: Colors.white),
                              tooltip: 'Bold',
                              onPressed: () => _insertFormatting('**', '**'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.format_italic, color: Colors.white),
                              tooltip: 'Italic',
                              onPressed: () => _insertFormatting('_', '_'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.format_strikethrough, color: Colors.white),
                              tooltip: 'Strikethrough',
                              onPressed: () => _insertFormatting('~~', '~~'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.format_list_bulleted, color: Colors.white),
                              tooltip: 'Bulleted List',
                              onPressed: () => _insertFormatting('\n- ', ''),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.format_list_numbered, color: Colors.white),
                              tooltip: 'Numbered List',
                              onPressed: () => _insertFormatting('\n1. ', ''),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.image, color: Colors.white),
                              tooltip: 'Insert Image',
                              onPressed: _insertImage,
                            ),
                          ],
                        ),
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
} 