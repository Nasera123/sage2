import 'package:flutter/material.dart';

class UserPreferences {
  String? displayName;
  String? avatarPath;
  String? email;
  ThemeMode themeMode;
  String language;
  // Editor preferences
  String defaultFontFamily;
  double defaultFontSize;
  bool autoSave;
  bool spellCheck;
  bool grammarCheck;
  String defaultParagraphSpacing;
  String defaultLineSpacing;
  bool showWordCount;
  bool focusMode;
  
  UserPreferences({
    this.displayName,
    this.avatarPath,
    this.email,
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.defaultFontFamily = 'Roboto',
    this.defaultFontSize = 14.0,
    this.autoSave = true,
    this.spellCheck = true,
    this.grammarCheck = false,
    this.defaultParagraphSpacing = 'normal',
    this.defaultLineSpacing = 'normal',
    this.showWordCount = false,
    this.focusMode = false,
  });
  
  // Convert UserPreferences to a map for local storage
  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarPath': avatarPath,
      'email': email,
      'themeMode': themeMode.index,
      'language': language,
      'defaultFontFamily': defaultFontFamily,
      'defaultFontSize': defaultFontSize,
      'autoSave': autoSave,
      'spellCheck': spellCheck,
      'grammarCheck': grammarCheck,
      'defaultParagraphSpacing': defaultParagraphSpacing,
      'defaultLineSpacing': defaultLineSpacing,
      'showWordCount': showWordCount,
      'focusMode': focusMode,
    };
  }
  
  // Create a UserPreferences from a map (from local storage)
  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    return UserPreferences(
      displayName: map['displayName'],
      avatarPath: map['avatarPath'],
      email: map['email'],
      themeMode: ThemeMode.values[map['themeMode'] ?? ThemeMode.system.index],
      language: map['language'] ?? 'en',
      defaultFontFamily: map['defaultFontFamily'] ?? 'Roboto',
      defaultFontSize: map['defaultFontSize'] ?? 14.0,
      autoSave: map['autoSave'] ?? true,
      spellCheck: map['spellCheck'] ?? true,
      grammarCheck: map['grammarCheck'] ?? false,
      defaultParagraphSpacing: map['defaultParagraphSpacing'] ?? 'normal',
      defaultLineSpacing: map['defaultLineSpacing'] ?? 'normal',
      showWordCount: map['showWordCount'] ?? false,
      focusMode: map['focusMode'] ?? false,
    );
  }
  
  // Create default preferences
  factory UserPreferences.defaults() {
    return UserPreferences(
      displayName: 'User',
      email: 'user@example.com',
      themeMode: ThemeMode.system,
      language: 'en',
      defaultFontFamily: 'Roboto',
      defaultFontSize: 14.0,
      autoSave: true,
      spellCheck: true,
      grammarCheck: false,
      defaultParagraphSpacing: 'normal',
      defaultLineSpacing: 'normal',
      showWordCount: false,
      focusMode: false,
    );
  }
  
  // Create a copy of preferences with updated fields
  UserPreferences copyWith({
    String? displayName,
    String? avatarPath,
    String? email,
    ThemeMode? themeMode,
    String? language,
    String? defaultFontFamily,
    double? defaultFontSize,
    bool? autoSave,
    bool? spellCheck,
    bool? grammarCheck,
    String? defaultParagraphSpacing,
    String? defaultLineSpacing,
    bool? showWordCount,
    bool? focusMode,
  }) {
    return UserPreferences(
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      email: email ?? this.email,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      defaultFontFamily: defaultFontFamily ?? this.defaultFontFamily,
      defaultFontSize: defaultFontSize ?? this.defaultFontSize,
      autoSave: autoSave ?? this.autoSave,
      spellCheck: spellCheck ?? this.spellCheck,
      grammarCheck: grammarCheck ?? this.grammarCheck,
      defaultParagraphSpacing: defaultParagraphSpacing ?? this.defaultParagraphSpacing,
      defaultLineSpacing: defaultLineSpacing ?? this.defaultLineSpacing,
      showWordCount: showWordCount ?? this.showWordCount,
      focusMode: focusMode ?? this.focusMode,
    );
  }
} 