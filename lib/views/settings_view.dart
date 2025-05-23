import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/preferences_controller.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesController = Get.find<PreferencesController>();

    return Obx(() {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserProfileSection(context, preferencesController),
          const Divider(height: 32),
          _buildAppearanceSection(context, preferencesController),
          const Divider(height: 32),
          _buildLanguageSection(context, preferencesController),
          const Divider(height: 32),
          _buildAboutSection(context),
        ],
      );
    });
  }

  Widget _buildUserProfileSection(BuildContext context, PreferencesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _changeAvatar(context, controller),
                child: Obx(() {
                  final avatarPath = controller.preferences.avatarPath;
                  return CircleAvatar(
                    radius: 50,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    backgroundImage: avatarPath != null
                        ? FileImage(File(avatarPath))
                        : null,
                    child: avatarPath == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _changeAvatar(context, controller),
                child: const Text('Change Avatar'),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Display Name'),
                subtitle: Text(controller.preferences.displayName ?? 'User'),
                trailing: const Icon(Icons.edit),
                onTap: () => _showEditNameDialog(context, controller),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, PreferencesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appearance',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Theme'),
          trailing: DropdownButton<ThemeMode>(
            value: controller.themeMode,
            onChanged: (value) {
              if (value != null) {
                controller.setThemeMode(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text('System'),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text('Light'),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text('Dark'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, PreferencesController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('Language'),
          trailing: DropdownButton<String>(
            value: controller.language,
            onChanged: (value) {
              if (value != null) {
                controller.setLanguage(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: 'id',
                child: Text('Indonesian'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          title: const Text('App Version'),
          subtitle: const Text('SAGE Local Edition 1.0.0'),
        ),
        const ListTile(
          title: Text('Made with Flutter'),
          subtitle: Text('A beautiful note-taking app'),
        ),
      ],
    );
  }

  void _changeAvatar(BuildContext context, PreferencesController controller) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final file = File(image.path);
      await controller.setAvatar(file);
    }
  }

  void _showEditNameDialog(BuildContext context, PreferencesController controller) {
    final nameController = TextEditingController(
      text: controller.preferences.displayName,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.setDisplayName(nameController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
} 