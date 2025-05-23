import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/book_model.dart';
import '../models/note_model.dart';
import '../services/storage_service.dart';
import 'note_controller.dart';

class BookController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final NoteController _noteController = Get.find<NoteController>();
  
  final RxList<Book> _books = <Book>[].obs;
  final RxBool _isLoading = false.obs;
  final Rx<Book?> _selectedBook = Rx<Book?>(null);
  
  List<Book> get books => _books;
  bool get isLoading => _isLoading.value;
  Book? get selectedBook => _selectedBook.value;
  
  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }
  
  Future<void> loadBooks() async {
    _isLoading.value = true;
    try {
      final loadedBooks = await _storageService.getAllBooks();
      _books.value = loadedBooks;
    } catch (e) {
      debugPrint('Error loading books: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<Book> createBook(String title, {String? coverImagePath}) async {
    final book = Book(
      title: title, 
      coverImagePath: coverImagePath,
    );
    await _storageService.saveBook(book);
    _books.add(book);
    return book;
  }
  
  Future<void> updateBook(Book book) async {
    await _storageService.saveBook(book);
    
    final index = _books.indexWhere((b) => b.id == book.id);
    if (index != -1) {
      _books[index] = book;
    }
    
    if (_selectedBook.value?.id == book.id) {
      _selectedBook.value = book;
    }
  }
  
  Future<void> renameBook(String bookId, String newTitle) async {
    final book = await _storageService.getBook(bookId);
    if (book != null) {
      final updatedBook = book.copyWith(
        title: newTitle,
        updatedAt: DateTime.now(),
      );
      await updateBook(updatedBook);
    }
  }
  
  Future<void> setCoverImage(String bookId, File imageFile) async {
    final book = await _storageService.getBook(bookId);
    if (book != null) {
      // Remove the old cover image if it exists
      if (book.coverImagePath != null) {
        await _storageService.deleteImage(book.coverImagePath!);
      }
      
      final imagePath = await _storageService.saveImage(imageFile);
      final updatedBook = book.copyWith(
        coverImagePath: imagePath,
        updatedAt: DateTime.now(),
      );
      await updateBook(updatedBook);
    }
  }
  
  Future<void> deleteBook(String bookId) async {
    final book = await _storageService.getBook(bookId);
    if (book != null) {
      // Delete cover image if it exists
      if (book.coverImagePath != null) {
        await _storageService.deleteImage(book.coverImagePath!);
      }
      
      // Handle associated notes
      final notesInBook = _noteController.getNotesByBook(bookId);
      for (final note in notesInBook) {
        // Remove book reference but don't delete the note
        final updatedNote = note.copyWith(bookId: null, bookPageNumber: null);
        await _noteController.updateNote(updatedNote);
      }
      
      // Delete the book
      await _storageService.deleteBook(bookId);
      _books.removeWhere((b) => b.id == bookId);
      
      if (_selectedBook.value?.id == bookId) {
        _selectedBook.value = null;
      }
    }
  }
  
  Future<void> selectBook(String? bookId) async {
    if (bookId == null) {
      _selectedBook.value = null;
      return;
    }
    
    final book = await _storageService.getBook(bookId);
    _selectedBook.value = book;
  }
  
  Future<void> addNoteToBook(String bookId, String noteId, {int? pageNumber}) async {
    final book = await _storageService.getBook(bookId);
    final note = await _storageService.getNote(noteId);
    
    if (book != null && note != null) {
      // Update the book
      if (!book.noteIds.contains(noteId)) {
        final updatedBook = book.copyWith(
          noteIds: [...book.noteIds, noteId],
        );
        await updateBook(updatedBook);
      }
      
      // Update the note
      final updatedNote = note.copyWith(
        bookId: bookId,
        bookPageNumber: pageNumber,
      );
      await _noteController.updateNote(updatedNote);
    }
  }
  
  Future<void> removeNoteFromBook(String bookId, String noteId) async {
    final book = await _storageService.getBook(bookId);
    final note = await _storageService.getNote(noteId);
    
    if (book != null && note != null) {
      // Update the book
      final updatedNoteIds = book.noteIds.where((id) => id != noteId).toList();
      final updatedBook = book.copyWith(noteIds: updatedNoteIds);
      await updateBook(updatedBook);
      
      // Update the note
      final updatedNote = note.copyWith(
        bookId: null,
        bookPageNumber: null,
      );
      await _noteController.updateNote(updatedNote);
    }
  }
  
  Future<void> reorderBookNotes(String bookId, int oldIndex, int newIndex) async {
    final book = await _storageService.getBook(bookId);
    if (book != null) {
      book.reorderNotes(oldIndex, newIndex);
      await updateBook(book);
      
      // Update page numbers of affected notes
      final notesInBook = _noteController.getNotesByBook(bookId);
      for (int i = 0; i < book.noteIds.length; i++) {
        final noteId = book.noteIds[i];
        final note = notesInBook.firstWhereOrNull((n) => n.id == noteId);
        if (note != null && note.bookPageNumber != i + 1) {
          final updatedNote = note.copyWith(bookPageNumber: i + 1);
          await _noteController.updateNote(updatedNote);
        }
      }
    }
  }
  
  List<Note> getSortedBookNotes(String bookId) {
    final notes = _noteController.getNotesByBook(bookId);
    notes.sort((a, b) {
      final aPage = a.bookPageNumber ?? 9999;
      final bPage = b.bookPageNumber ?? 9999;
      return aPage.compareTo(bPage);
    });
    return notes;
  }
} 