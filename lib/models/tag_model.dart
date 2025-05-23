import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Tag {
  final String id;
  String name;
  Color color;
  DateTime createdAt;

  Tag({
    String? id,
    required this.name,
    Color? color,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        color = color ?? Colors.blue,
        createdAt = createdAt ?? DateTime.now();

  // Convert Tag to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create a Tag from a map (from local storage)
  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  // Create a copy of the tag with updated fields
  Tag copyWith({
    String? name,
    Color? color,
  }) {
    return Tag(
      id: id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt,
    );
  }
} 