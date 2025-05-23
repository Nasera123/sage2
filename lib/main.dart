import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/storage_service.dart';
import 'controllers/note_controller.dart';
import 'controllers/folder_controller.dart';
import 'controllers/book_controller.dart';
import 'controllers/tag_controller.dart';
import 'controllers/preferences_controller.dart';
import 'controllers/navigation_controller.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive and services
  final storageService = StorageService();
  await storageService.init();
  
  // Register services and controllers
  Get.put(storageService);
  Get.put(NoteController());
  Get.put(FolderController());
  Get.put(BookController());
  Get.put(TagController());
  Get.put(PreferencesController());
  Get.put(NavigationController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesController = Get.find<PreferencesController>();
    
    return GetMaterialApp(
      title: 'SAGE Local Edition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.indigo,
          secondary: Colors.indigo.shade300,
          surface: const Color(0xFF121212),
          background: const Color(0xFF121212),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF121212),
        ),
        useMaterial3: true,
      ),
      themeMode: preferencesController.themeMode,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
