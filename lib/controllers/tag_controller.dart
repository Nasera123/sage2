import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/tag_model.dart';
import '../services/storage_service.dart';
import 'note_controller.dart';

class TagController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final NoteController _noteController = Get.find<NoteController>();
  
  final RxList<Tag> _tags = <Tag>[].obs;
  final RxBool _isLoading = false.obs;
  
  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    loadTags();
  }
  
  Future<void> loadTags() async {
    _isLoading.value = true;
    try {
      final loadedTags = await _storageService.getAllTags();
      _tags.value = loadedTags;
    } catch (e) {
      debugPrint('Error loading tags: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<Tag> createTag(String name, {Color? color}) async {
    final tag = Tag(name: name, color: color);
    await _storageService.saveTag(tag);
    _tags.add(tag);
    return tag;
  }
  
  Future<void> updateTag(Tag tag) async {
    await _storageService.saveTag(tag);
    
    final index = _tags.indexWhere((t) => t.id == tag.id);
    if (index != -1) {
      _tags[index] = tag;
    }
  }
  
  Future<void> renameTag(String tagId, String newName) async {
    final tag = await _storageService.getTag(tagId);
    if (tag != null) {
      final updatedTag = tag.copyWith(name: newName);
      await updateTag(updatedTag);
    }
  }
  
  Future<void> changeTagColor(String tagId, Color newColor) async {
    final tag = await _storageService.getTag(tagId);
    if (tag != null) {
      final updatedTag = tag.copyWith(color: newColor);
      await updateTag(updatedTag);
    }
  }
  
  Future<void> deleteTag(String tagId) async {
    // Find notes with this tag
    final notesWithTag = _noteController.getNotesByTag(tagId);
    
    // Remove tag from notes
    for (final note in notesWithTag) {
      final updatedTags = note.tags.where((tag) => tag != tagId).toList();
      final updatedNote = note.copyWith(tags: updatedTags);
      await _noteController.updateNote(updatedNote);
    }
    
    // Delete the tag
    await _storageService.deleteTag(tagId);
    _tags.removeWhere((t) => t.id == tagId);
  }
  
  Future<void> addTagToNote(String tagId, String noteId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null && !note.tags.contains(tagId)) {
      final updatedNote = note.copyWith(
        tags: [...note.tags, tagId],
      );
      await _noteController.updateNote(updatedNote);
    }
  }
  
  Future<void> removeTagFromNote(String tagId, String noteId) async {
    final note = await _storageService.getNote(noteId);
    if (note != null && note.tags.contains(tagId)) {
      final updatedTags = note.tags.where((tag) => tag != tagId).toList();
      final updatedNote = note.copyWith(tags: updatedTags);
      await _noteController.updateNote(updatedNote);
    }
  }
  
  // Returns tag objects corresponding to a note's tag IDs
  List<Tag> getTagsForNote(List<String> tagIds) {
    return _tags.where((tag) => tagIds.contains(tag.id)).toList();
  }
} 