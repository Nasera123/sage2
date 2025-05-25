import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/preferences_controller.dart';
import '../controllers/folder_controller.dart';
import '../controllers/navigation_controller.dart';
import '../widgets/add_note_dialog.dart';
import '../widgets/add_folder_dialog.dart';
import '../views/book_editor_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesController = Get.find<PreferencesController>();
    final folderController = Get.find<FolderController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Theme.of(context).drawerTheme.backgroundColor,
      child: Column(
        children: [
          // User Profile Section
          _buildUserProfileHeader(context, preferencesController),
          
          // Search Bar
          _buildSearchBar(context),
          
          // Main Navigation
          _buildNavItem(context, Icons.home_outlined, 'Home', () {
            _navigateAndClose(context, 0);
          }),
          _buildNavItem(context, Icons.inbox_outlined, 'Inbox', () {
            _navigateAndClose(context, 0); // Navigate to notes - can be changed to inbox when implemented
          }),
          
          // Private Section
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'PRIVATE',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          _buildNavItem(context, Icons.article_outlined, 'Reading List', () {
            _navigateAndClose(context, 0); // Navigate to notes - can be changed to reading list when implemented
          }),
          _buildNavItem(context, Icons.book_outlined, 'My Books', () {
            _navigateAndClose(context, 2); // Books view
          }),
          _buildNavItem(context, Icons.add_box_outlined, 'New Book', () {
            _showAddBookScreen(context);
          }),
          _buildNavItem(context, Icons.note_add_outlined, 'New page', () {
            _showAddNoteDialog(context);
          }),
          
          // Folders Section
          _buildFoldersSection(context, folderController),
          
          // Shared Section
          _buildSharedSection(context),
          
          // Bottom Navigation Items
          const Spacer(),
          _buildNavItem(context, Icons.tag, 'Tags', () {
            _navigateAndClose(context, 3); // Tags view
          }, showArrow: true),
          _buildNavItem(context, Icons.settings_outlined, 'Settings', () {
            _navigateAndClose(context, 4); // Settings view
          }),
          _buildNavItem(context, Icons.delete_outline, 'Trash', () {
            _navigateAndClose(context, 5); // Trash view
          }),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  void _navigateAndClose(BuildContext context, int index) {
    // Use this pattern to allow the parent (HomeScreen) to handle view switching
    Navigator.of(context).pop(); // Close drawer
    Get.find<NavigationController>().setCurrentIndex(index);
  }
  
  void _showAddNoteDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer first
    showDialog(
      context: context,
      builder: (context) => const AddNoteDialog(),
    );
  }
  
  void _showAddFolderDialog(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer first
    showDialog(
      context: context,
      builder: (context) => const AddFolderDialog(),
    );
  }
  
  void _showAddBookScreen(BuildContext context) {
    Navigator.of(context).pop(); // Close drawer first
    Get.to(() => const BookEditorView());
  }
  
  Widget _buildUserProfileHeader(BuildContext context, PreferencesController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              backgroundImage: controller.preferences.avatarPath != null
                  ? FileImage(File(controller.preferences.avatarPath!))
                  : null,
              child: controller.preferences.avatarPath == null
                  ? Icon(Icons.person, color: isDarkMode ? Colors.white70 : Colors.black54)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.preferences.displayName ?? 'User',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Tap to edit profile',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, color: isDarkMode ? Colors.white70 : Colors.black54),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, color: isDarkMode ? Colors.white70 : Colors.black54),
              onPressed: () {
                _navigateAndClose(context, 4); // Settings view
              },
            ),
          ],
        ),
      );
    });
  }
  
  Widget _buildSearchBar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
            prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.grey : Colors.black54),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, IconData icon, String title, VoidCallback onTap, {bool showArrow = false}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      trailing: showArrow ? Icon(Icons.keyboard_arrow_down, color: isDarkMode ? Colors.white70 : Colors.black54) : null,
      onTap: onTap,
    );
  }
  
  Widget _buildFoldersSection(BuildContext context, FolderController folderController) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FOLDERS',
                style: TextStyle(
                  color: isDarkMode ? Colors.grey : Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: isDarkMode ? Colors.white70 : Colors.black54, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => _showAddFolderDialog(context),
              ),
            ],
          ),
        ),
        Obx(() {
          if (folderController.folders.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Text(
                'No folders yet',
                style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
              ),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: folderController.folders.length,
            itemBuilder: (context, index) {
              final folder = folderController.folders[index];
              return ListTile(
                leading: Icon(Icons.folder_outlined, color: isDarkMode ? Colors.white70 : Colors.black87),
                title: Text(
                  folder.name,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                onTap: () {
                  _navigateAndClose(context, 1); // Navigate to folders view
                },
              );
            },
          );
        }),
      ],
    );
  }
  
  Widget _buildSharedSection(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'SHARED',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            'Shared pages will go here',
            style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.share, color: isDarkMode ? Colors.white70 : Colors.black87, size: 16),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Start collaborating action
                },
                child: Text(
                  'Start collaborating',
                  style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}