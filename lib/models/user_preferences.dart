import 'package:flutter/material.dart';

class UserPreferences {
  String? displayName;
  String? avatarPath;
  ThemeMode themeMode;
  String language;
  
  UserPreferences({
    this.displayName,
    this.avatarPath,
    this.themeMode = ThemeMode.system,
    this.language = 'en',
  });
  
  // Convert UserPreferences to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarPath': avatarPath,
      'themeMode': themeMode.index,
      'language': language,
    };
  }
  
  // Create a UserPreferences from a map (from local storage)
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      displayName: map['displayName'],
      avatarPath: map['avatarPath'],
      themeMode: ThemeMode.values[map['themeMode'] ?? ThemeMode.system.index],
      language: map['language'] ?? 'en',
    );
  }
  
  // Create default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      displayName: 'User',
      themeMode: ThemeMode.system,
      language: 'en',
    );
  }
  
  // Create a copy of preferences with updated fields
  UserPreferences copyWith({
    String? displayName,
    String? avatarPath,
    ThemeMode? themeMode,
    String? language,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
} 