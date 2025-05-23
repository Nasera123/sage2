import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/folder_model.dart';
import '../services/storage_service.dart';
import 'note_controller.dart';

class FolderController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final NoteController _noteController = Get.find<NoteController>();
  
  final RxList<Folder> _folders = <Folder>[].obs;
  final RxBool _isLoading = false.obs;
  final Rx<Folder?> _selectedFolder = Rx<Folder?>(null);
  
  List<Folder> get folders => _folders;
  bool get isLoading => _isLoading.value;
  Folder? get selectedFolder => _selectedFolder.value;
  
  @override
  void onInit() {
    super.onInit();
    loadFolders();
  }
  
  Future<void> loadFolders() async {
    _isLoading.value = true;
    try {
      final loadedFolders = await _storageService.getAllFolders();
      _folders.value = loadedFolders;
    } catch (e) {
      debugPrint('Error loading folders: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<Folder> createFolder(String name, {String? parentId}) async {
    final folder = Folder(name: name, parentId: parentId);
    await _storageService.saveFolder(folder);
    _folders.add(folder);
    return folder;
  }
  
  Future<void> updateFolder(Folder folder) async {
    await _storageService.saveFolder(folder);
    
    final index = _folders.indexWhere((f) => f.id == folder.id);
    if (index != -1) {
      _folders[index] = folder;
    }
    
    if (_selectedFolder.value?.id == folder.id) {
      _selectedFolder.value = folder;
    }
  }
  
  Future<void> renameFolder(String folderId, String newName) async {
    final folder = await _storageService.getFolder(folderId);
    if (folder != null) {
      final updatedFolder = folder.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      await updateFolder(updatedFolder);
    }
  }
  
  Future<void> deleteFolder(String folderId) async {
    // First check if any notes are in this folder
    final notesInFolder = _noteController.getNotesByFolder(folderId);
    
    // Move notes to trash if they exist
    for (final note in notesInFolder) {
      await _noteController.moveNoteToTrash(note.id);
    }
    
    // Now delete the folder
    await _storageService.deleteFolder(folderId);
    _folders.removeWhere((f) => f.id == folderId);
    
    // Also delete any children folders
    final childFolders = _folders.where((f) => f.parentId == folderId).toList();
    for (final childFolder in childFolders) {
      await deleteFolder(childFolder.id);
    }
    
    if (_selectedFolder.value?.id == folderId) {
      _selectedFolder.value = null;
    }
  }
  
  Future<void> selectFolder(String? folderId) async {
    if (folderId == null) {
      _selectedFolder.value = null;
      return;
    }
    
    final folder = await _storageService.getFolder(folderId);
    _selectedFolder.value = folder;
  }
  
  List<Folder> getRootFolders() {
    return _folders.where((folder) => folder.parentId == null).toList();
  }
  
  List<Folder> getChildFolders(String parentId) {
    return _folders.where((folder) => folder.parentId == parentId).toList();
  }
  
  bool hasChildFolders(String folderId) {
    return _folders.any((folder) => folder.parentId == folderId);
  }
} 