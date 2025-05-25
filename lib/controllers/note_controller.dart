import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/note_model.dart';
import '../services/storage_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class NoteController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxList<Note> _notes = <Note>[].obs;
  final Rx<Note?> _selectedNote = Rx<Note?>(null);
  final RxBool _isLoading = false.obs;
  
  List<Note> get notes => _notes.where((note) => !note.isTrashed).toList();
  List<Note> get trashedNotes => _notes.where((note) => note.isTrashed).toList();
  bool get isLoading => _isLoading.value;
  Note? get selectedNote => _selectedNote.value;
  
  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }
  
  Future<void> loadNotes() async {
    _isLoading.value = true;
    try {
      final allNotes = await _storageService.getAllNotes();
      _notes.value = allNotes;
    } catch (e) {
      debugPrint('Error loading notes: $e');
      // If no notes exist, create a sample note
      if (_notes.isEmpty) {
        await createNote(
          title: 'Welcome to SAGE',
          content: 'This is your first note. Start writing!',
        );
      }
    } finally {
      _isLoading.value = false;
    }
  }
  
  // Get note by ID
  Future<Note?> getNote(String id) async {
    return await _storageService.getNote(id);
  }
  
  Future<Note> createNote({
    required String title,
    String content = "",
    List<String> tags = const [],
    String? folderId,
    String? bookId,
    int? bookPageNumber,
  }) async {
    final note = Note(
      title: title,
      content: content,
      folderId: folderId,
      bookId: bookId,
      bookPageNumber: bookPageNumber,
      isTrashed: false,
    );
    
    await _storageService.saveNote(note);
    _notes.add(note);
    return note;
  }
  
  Future<void> updateNote(Note note) async {
    await _storageService.saveNote(note);
    
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    
    if (_selectedNote.value?.id == note.id) {
      _selectedNote.value = note;
    }
  }
  
  Future<String> addImageToNote(File imageFile) async {
    if (kIsWeb) {
      // For web, we can't access the local file system in the same way
      // So we'll just return a placeholder
      return 'web_image_${DateTime.now().millisecondsSinceEpoch}';
    }
    
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${documentsDir.path}/images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
      
      final filename = const Uuid().v4() + '.jpg';
      final savedImagePath = '${imagesDir.path}/$filename';
      
      await imageFile.copy(savedImagePath);
      return savedImagePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return 'error_saving_image';
    }
  }
  
  Future<void> selectNote(String? noteId) async {
    if (noteId == null) {
      _selectedNote.value = null;
      return;
    }
    
    final note = await _storageService.getNote(noteId);
    _selectedNote.value = note;
  }
  
  Future<void> moveNoteToTrash(String noteId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null) {
      final trashedNote = note.copyWith(isTrashed: true);
      await updateNote(trashedNote);
      
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = trashedNote;
      }
      
      if (_selectedNote.value?.id == noteId) {
        _selectedNote.value = null;
      }
    }
  }
  
  Future<void> restoreNoteFromTrash(String noteId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null) {
      final restoredNote = note.copyWith(isTrashed: false);
      await updateNote(restoredNote);
      
      final index = _notes.indexWhere((n) => n.id == noteId);
      if (index != -1) {
        _notes[index] = restoredNote;
      }
    }
  }
  
  Future<void> deleteNotePermanently(String noteId) async {
    try {
      final note = await _storageService.getNote(noteId);
      if (note != null) {
        // Delete associated images
        if (!kIsWeb) {
          for (final imagePath in note.imageReferences) {
            final imageFile = File(imagePath);
            if (await imageFile.exists()) {
              await imageFile.delete();
            }
          }
        }
        
        await _storageService.deleteNote(noteId);
        _notes.removeWhere((n) => n.id == noteId);
        
        if (_selectedNote.value?.id == noteId) {
          _selectedNote.value = null;
        }
      }
    } catch (e) {
      debugPrint('Error deleting note: $e');
    }
  }
  
  Future<void> emptyTrash() async {
    final trashedNotes = _notes.where((note) => note.isTrashed).toList();
    for (final note in trashedNotes) {
      await deleteNotePermanently(note.id);
    }
  }
  
  // Alias for deleteNotePermanently - used by BookController
  Future<void> deleteNote(String noteId) async {
    return deleteNotePermanently(noteId);
  }
  
  List<Note> getNotesByFolder(String folderId) {
    return notes.where((note) => note.folderId == folderId).toList();
  }
  
  List<Note> getNotesByBook(String bookId) {
    return notes.where((note) => note.bookId == bookId).toList();
  }
  
  List<Note> getNotesByTag(String tagId) {
    return notes.where((note) => note.tagIds.contains(tagId)).toList();
  }
  
  List<Note> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return notes.where((note) => 
        note.title.toLowerCase().contains(lowercaseQuery) ||
        note.content.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }
  
  Future<void> addTagToNote(String noteId, String tagId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null) {
      final currentTagIds = List<String>.from(note.tagIds);
      if (!currentTagIds.contains(tagId)) {
        currentTagIds.add(tagId);
        final updatedNote = note.copyWith(tagIds: currentTagIds);
        await updateNote(updatedNote);
      }
    }
  }
  
  Future<void> removeTagFromNote(String noteId, String tagId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null) {
      final currentTagIds = List<String>.from(note.tagIds);
      if (currentTagIds.contains(tagId)) {
        currentTagIds.remove(tagId);
        final updatedNote = note.copyWith(tagIds: currentTagIds);
        await updateNote(updatedNote);
      }
    }
  }
} 