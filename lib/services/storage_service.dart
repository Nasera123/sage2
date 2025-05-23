import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';
import '../models/folder_model.dart';
import '../models/book_model.dart';
import '../models/tag_model.dart';
import '../models/user_preferences.dart';

class StorageService {
  static const String notesBoxName = 'notes';
  static const String foldersBoxName = 'folders';
  static const String booksBoxName = 'books';
  static const String tagsBoxName = 'tags';
  static const String preferencesBoxName = 'preferences';

  // Initialize storage
  Future<void> init() async {
    await Hive.initFlutter();
    await openBoxes();
  }

  // Open Hive boxes
  Future<void> openBoxes() async {
    await Hive.openBox<Map>(notesBoxName);
    await Hive.openBox<Map>(foldersBoxName);
    await Hive.openBox<Map>(booksBoxName);
    await Hive.openBox<Map>(tagsBoxName);
    await Hive.openBox<Map>(preferencesBoxName);
  }

  // Get application document directory
  Future<Directory> get _appDir async {
    return await getApplicationDocumentsDirectory();
  }

  // Save an image and return its path
  Future<String> saveImage(File imageFile) async {
    final appDirectory = await _appDir;
    final imagesDirectory = Directory('${appDirectory.path}/images');
    if (!await imagesDirectory.exists()) {
      await imagesDirectory.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedFile = await imageFile.copy('${imagesDirectory.path}/$fileName');
    return savedFile.path;
  }

  // Delete an image by path
  Future<void> deleteImage(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // NOTES OPERATIONS
  Future<void> saveNote(Note note) async {
    final box = Hive.box<Map>(notesBoxName);
    await box.put(note.id, note.toMap());
  }

  Future<Note?> getNote(String id) async {
    final box = Hive.box<Map>(notesBoxName);
    final noteMap = box.get(id);
    return noteMap != null ? Note.fromMap(Map<String, dynamic>.from(noteMap)) : null;
  }

  Future<List<Note>> getAllNotes() async {
    final box = Hive.box<Map>(notesBoxName);
    return box.values
        .map((map) => Note.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> deleteNote(String id) async {
    final box = Hive.box<Map>(notesBoxName);
    await box.delete(id);
  }

  // FOLDER OPERATIONS
  Future<void> saveFolder(Folder folder) async {
    final box = Hive.box<Map>(foldersBoxName);
    await box.put(folder.id, folder.toMap());
  }

  Future<Folder?> getFolder(String id) async {
    final box = Hive.box<Map>(foldersBoxName);
    final folderMap = box.get(id);
    return folderMap != null ? Folder.fromMap(Map<String, dynamic>.from(folderMap)) : null;
  }

  Future<List<Folder>> getAllFolders() async {
    final box = Hive.box<Map>(foldersBoxName);
    return box.values
        .map((map) => Folder.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> deleteFolder(String id) async {
    final box = Hive.box<Map>(foldersBoxName);
    await box.delete(id);
  }

  // BOOK OPERATIONS
  Future<void> saveBook(Book book) async {
    final box = Hive.box<Map>(booksBoxName);
    await box.put(book.id, book.toMap());
  }

  Future<Book?> getBook(String id) async {
    final box = Hive.box<Map>(booksBoxName);
    final bookMap = box.get(id);
    return bookMap != null ? Book.fromMap(Map<String, dynamic>.from(bookMap)) : null;
  }

  Future<List<Book>> getAllBooks() async {
    final box = Hive.box<Map>(booksBoxName);
    return box.values
        .map((map) => Book.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> deleteBook(String id) async {
    final box = Hive.box<Map>(booksBoxName);
    await box.delete(id);
  }

  // TAG OPERATIONS
  Future<void> saveTag(Tag tag) async {
    final box = Hive.box<Map>(tagsBoxName);
    await box.put(tag.id, tag.toMap());
  }

  Future<Tag?> getTag(String id) async {
    final box = Hive.box<Map>(tagsBoxName);
    final tagMap = box.get(id);
    return tagMap != null ? Tag.fromMap(Map<String, dynamic>.from(tagMap)) : null;
  }

  Future<List<Tag>> getAllTags() async {
    final box = Hive.box<Map>(tagsBoxName);
    return box.values
        .map((map) => Tag.fromMap(Map<String, dynamic>.from(map)))
        .toList();
  }

  Future<void> deleteTag(String id) async {
    final box = Hive.box<Map>(tagsBoxName);
    await box.delete(id);
  }

  // USER PREFERENCES OPERATIONS
  Future<void> saveUserPreferences(UserPreferences preferences) async {
    final box = Hive.box<Map>(preferencesBoxName);
    await box.put('preferences', preferences.toMap());
  }

  Future<UserPreferences> getUserPreferences() async {
    final box = Hive.box<Map>(preferencesBoxName);
    final preferencesMap = box.get('preferences');
    return preferencesMap != null 
      ? UserPreferences.fromMap(Map<String, dynamic>.from(preferencesMap)) 
      : UserPreferences.defaults();
  }

  // Export all data to a single JSON object
  Future<Map<String, dynamic>> exportAllData() async {
    final notes = await getAllNotes();
    final folders = await getAllFolders();
    final books = await getAllBooks();
    final tags = await getAllTags();
    final preferences = await getUserPreferences();

    return {
      'notes': notes.map((note) => note.toMap()).toList(),
      'folders': folders.map((folder) => folder.toMap()).toList(),
      'books': books.map((book) => book.toMap()).toList(),
      'tags': tags.map((tag) => tag.toMap()).toList(),
      'preferences': preferences.toMap(),
      'version': '1.0',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  // Import data from a JSON object
  Future<void> importAllData(Map<String, dynamic> data) async {
    // Clear current data
    await Hive.box<Map>(notesBoxName).clear();
    await Hive.box<Map>(foldersBoxName).clear();
    await Hive.box<Map>(booksBoxName).clear();
    await Hive.box<Map>(tagsBoxName).clear();

    // Import notes
    final notesList = (data['notes'] as List).cast<Map<String, dynamic>>();
    for (final noteMap in notesList) {
      final note = Note.fromMap(noteMap);
      await saveNote(note);
    }

    // Import folders
    final foldersList = (data['folders'] as List).cast<Map<String, dynamic>>();
    for (final folderMap in foldersList) {
      final folder = Folder.fromMap(folderMap);
      await saveFolder(folder);
    }

    // Import books
    final booksList = (data['books'] as List).cast<Map<String, dynamic>>();
    for (final bookMap in booksList) {
      final book = Book.fromMap(bookMap);
      await saveBook(book);
    }

    // Import tags
    final tagsList = (data['tags'] as List).cast<Map<String, dynamic>>();
    for (final tagMap in tagsList) {
      final tag = Tag.fromMap(tagMap);
      await saveTag(tag);
    }

    // Import preferences
    if (data['preferences'] != null) {
      final preferences = UserPreferences.fromMap(data['preferences']);
      await saveUserPreferences(preferences);
    }
  }
} 