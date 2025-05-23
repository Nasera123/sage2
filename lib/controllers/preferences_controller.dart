import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_preferences.dart';
import '../services/storage_service.dart';

class PreferencesController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<UserPreferences> _preferences = UserPreferences.defaults().obs;
  final RxBool _isLoading = false.obs;
  
  UserPreferences get preferences => _preferences.value;
  bool get isLoading => _isLoading.value;
  
  ThemeMode get themeMode => _preferences.value.themeMode;
  String get language => _preferences.value.language;
  
  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }
  
  Future<void> loadPreferences() async {
    _isLoading.value = true;
    try {
      final loadedPreferences = await _storageService.getUserPreferences();
      _preferences.value = loadedPreferences;
    } catch (e) {
      debugPrint('Error loading preferences: $e');
      _preferences.value = UserPreferences.defaults();
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> updatePreferences(UserPreferences preferences) async {
    await _storageService.saveUserPreferences(preferences);
    _preferences.value = preferences;
  }
  
  Future<void> setDisplayName(String displayName) async {
    final updatedPreferences = _preferences.value.copyWith(
      displayName: displayName,
    );
    await updatePreferences(updatedPreferences);
  }
  
  Future<void> setAvatar(File avatarFile) async {
    // Remove old avatar if exists
    if (_preferences.value.avatarPath != null) {
      await _storageService.deleteImage(_preferences.value.avatarPath!);
    }
    
    final avatarPath = await _storageService.saveImage(avatarFile);
    final updatedPreferences = _preferences.value.copyWith(
      avatarPath: avatarPath,
    );
    await updatePreferences(updatedPreferences);
  }
  
  Future<void> setThemeMode(ThemeMode themeMode) async {
    final updatedPreferences = _preferences.value.copyWith(
      themeMode: themeMode,
    );
    await updatePreferences(updatedPreferences);
    Get.changeThemeMode(themeMode);
  }
  
  Future<void> setLanguage(String language) async {
    final updatedPreferences = _preferences.value.copyWith(
      language: language,
    );
    await updatePreferences(updatedPreferences);
    
    // Update app locale
    final locale = _getLocaleFromLanguageCode(language);
    Get.updateLocale(locale);
  }
  
  Locale _getLocaleFromLanguageCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'id':
        return const Locale('id', 'ID');
      default:
        return const Locale('en', 'US');
    }
  }
} 