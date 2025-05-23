import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  String title;
  String content; // Plain text content
  List<String> tags;
  String? folderId;
  String? bookId;
  int? bookPageNumber;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isTrashed;
  List<String> imageReferences; // Paths to local images
  List<String> tagIds;

  Note({
    String? id,
    required this.title,
    required this.content,
    this.tags = const [],
    this.folderId,
    this.bookId,
    this.bookPageNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isTrashed = false,
    this.imageReferences = const [],
    List<String>? tagIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        tagIds = tagIds ?? [];

  // Convert Note to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'folderId': folderId,
      'bookId': bookId,
      'bookPageNumber': bookPageNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isTrashed': isTrashed ? 1 : 0,
      'imageReferences': jsonEncode(imageReferences),
      'tagIds': tagIds,
    };
  }

  // Create a Note from a map (from local storage)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      tags: List<String>.from(map['tags'] ?? []),
      folderId: map['folderId'],
      bookId: map['bookId'],
      bookPageNumber: map['bookPageNumber'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      isTrashed: map['isTrashed'] == 1,
      imageReferences: List<String>.from(jsonDecode(map['imageReferences'] ?? '[]')),
      tagIds: List<String>.from(map['tagIds'] ?? []),
    );
  }

  // Create a copy of the note with updated fields
  Note copyWith({
    String? title,
    String? content,
    List<String>? tags,
    String? folderId,
    String? bookId,
    int? bookPageNumber,
    DateTime? updatedAt,
    bool? isTrashed,
    List<String>? imageReferences,
    List<String>? tagIds,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      folderId: folderId ?? this.folderId,
      bookId: bookId ?? this.bookId,
      bookPageNumber: bookPageNumber ?? this.bookPageNumber,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isTrashed: isTrashed ?? this.isTrashed,
      imageReferences: imageReferences ?? this.imageReferences,
      tagIds: tagIds ?? List<String>.from(this.tagIds),
    );
  }
} 