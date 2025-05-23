import 'dart:convert';
import 'package:uuid/uuid.dart';

class Book {
  final String id;
  String title;
  String? coverImagePath;
  List<String> noteIds; // IDs of notes contained in this book
  DateTime createdAt;
  DateTime updatedAt;

  Book({
    String? id,
    required this.title,
    this.coverImagePath,
    this.noteIds = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert Book to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'coverImagePath': coverImagePath,
      'noteIds': jsonEncode(noteIds),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a Book from a map (from local storage)
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      coverImagePath: map['coverImagePath'],
      noteIds: List<String>.from(jsonDecode(map['noteIds'] ?? '[]')),
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  // Create a copy of the book with updated fields
  Book copyWith({
    String? title,
    String? coverImagePath,
    List<String>? noteIds,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id,
      title: title ?? this.title,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      noteIds: noteIds ?? this.noteIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Methods to manage notes in the book
  void addNote(String noteId) {
    if (!noteIds.contains(noteId)) {
      noteIds.add(noteId);
      updatedAt = DateTime.now();
    }
  }

  void removeNote(String noteId) {
    noteIds.remove(noteId);
    updatedAt = DateTime.now();
  }

  void reorderNotes(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final String item = noteIds.removeAt(oldIndex);
    noteIds.insert(newIndex, item);
    updatedAt = DateTime.now();
  }
} 