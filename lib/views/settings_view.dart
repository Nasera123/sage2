import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/preferences_controller.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesController = Get.find<PreferencesController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).appBarTheme.foregroundColor,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        leading: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Get.offAll(() => const HomeScreen());
          },
          child: Icon(
            Icons.arrow_back,
            color: Theme.of(context).appBarTheme.iconTheme?.color,
          ),
        ),
      ),
      body: Obx(() {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            // Account Section
            _buildAccountSection(context, preferencesController),
            
            // Appearance Section
            _buildAppearanceSection(context, preferencesController),
            
            // Editor Settings Section
            _buildEditorSection(context, preferencesController),
            
            // Security Section
            _buildSecuritySection(context),
            
            // About Section
            _buildAboutSection(context),
          ],
        );
      }),
    );
  }

  Widget _buildAccountSection(BuildContext context, PreferencesController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Obx(() {
            final avatarPath = controller.preferences.avatarPath;
            return CircleAvatar(
              backgroundColor: Colors.indigo.shade200,
              backgroundImage: avatarPath != null
                  ? FileImage(File(avatarPath))
                  : null,
              child: avatarPath == null
                  ? Icon(Icons.person, color: isDarkMode ? Colors.white : Colors.black54)
                  : null,
            );
          }),
          title: Text(
            controller.preferences.email ?? 'user@example.com',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'Your account',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : Colors.black54,
              fontSize: 14,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: isDarkMode ? Colors.grey : Colors.black54),
          onTap: () => _showEditAccountDialog(context, controller),
        ),
        Divider(color: isDarkMode ? const Color(0xFF333333) : Colors.grey[300], height: 1),
      ],
    );
  }

  Widget _buildAppearanceSection(BuildContext context, PreferencesController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: Icon(Icons.dark_mode, color: isDarkMode ? Colors.white : Colors.black87),
          title: Text(
            'Dark Mode',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch(
            value: controller.themeMode == ThemeMode.dark,
            onChanged: (value) {
              controller.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        Divider(color: isDarkMode ? const Color(0xFF333333) : Colors.grey[300], height: 1),
        
        ListTile(
          leading: Icon(Icons.language, color: isDarkMode ? Colors.white : Colors.black87),
          title: Text(
            'Language',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<String>(
            value: controller.language,
            dropdownColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            iconEnabledColor: isDarkMode ? Colors.white : Colors.black,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            underline: Container(),
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
        Divider(color: isDarkMode ? const Color(0xFF333333) : Colors.grey[300], height: 1),
      ],
    );
  }

  Widget _buildEditorSection(BuildContext context, PreferencesController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'EDITOR',
            style: TextStyle(
              color: isDarkMode ? Colors.grey : Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        // Font Settings
        ListTile(
          leading: Icon(Icons.font_download, color: isDarkMode ? Colors.white : Colors.black87),
          title: Text(
            'Default Font',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<String>(
            value: controller.preferences.defaultFontFamily,
            dropdownColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
            iconEnabledColor: isDarkMode ? Colors.white : Colors.black,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            underline: Container(),
            onChanged: (value) {
              if (value != null) {
                controller.setDefaultFontFamily(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'Roboto',
                child: Text('Roboto'),
              ),
              DropdownMenuItem(
                value: 'Open Sans',
                child: Text('Open Sans'),
              ),
              DropdownMenuItem(
                value: 'Lato',
                child: Text('Lato'),
              ),
              DropdownMenuItem(
                value: 'Montserrat',
                child: Text('Montserrat'),
              ),
            ],
          ),
        ),
        Divider(color: isDarkMode ? const Color(0xFF333333) : Colors.grey[300], height: 1),
        
        // Font Size
        ListTile(
          leading: const Icon(Icons.format_size, color: Colors.white),
          title: const Text(
            'Default Font Size',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<double>(
            value: controller.preferences.defaultFontSize,
            dropdownColor: const Color(0xFF1A1A1A),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            onChanged: (value) {
              if (value != null) {
                controller.setDefaultFontSize(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 12.0,
                child: Text('12'),
              ),
              DropdownMenuItem(
                value: 14.0,
                child: Text('14'),
              ),
              DropdownMenuItem(
                value: 16.0,
                child: Text('16'),
              ),
              DropdownMenuItem(
                value: 18.0,
                child: Text('18'),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Auto Save
        ListTile(
          leading: const Icon(Icons.save, color: Colors.white),
          title: const Text(
            'Auto Save',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch(
            value: controller.preferences.autoSave,
            onChanged: (value) {
              controller.setAutoSave(value);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Spell Check
        ListTile(
          leading: const Icon(Icons.spellcheck, color: Colors.white),
          title: const Text(
            'Spell Check',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch(
            value: controller.preferences.spellCheck,
            onChanged: (value) {
              controller.setSpellCheck(value);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Grammar Check
        ListTile(
          leading: const Icon(Icons.checklist, color: Colors.white),
          title: const Text(
            'Grammar Check',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch(
            value: controller.preferences.grammarCheck,
            onChanged: (value) {
              controller.setGrammarCheck(value);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Paragraph Spacing
        ListTile(
          leading: const Icon(Icons.height, color: Colors.white),
          title: const Text(
            'Paragraph Spacing',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: DropdownButton<String>(
            value: controller.preferences.defaultParagraphSpacing,
            dropdownColor: const Color(0xFF1A1A1A),
            iconEnabledColor: Colors.white,
            style: const TextStyle(color: Colors.white),
            underline: Container(),
            onChanged: (value) {
              if (value != null) {
                controller.setDefaultParagraphSpacing(value);
              }
            },
            items: const [
              DropdownMenuItem(
                value: 'compact',
                child: Text('Compact'),
              ),
              DropdownMenuItem(
                value: 'normal',
                child: Text('Normal'),
              ),
              DropdownMenuItem(
                value: 'relaxed',
                child: Text('Relaxed'),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Word Count
        ListTile(
          leading: const Icon(Icons.numbers, color: Colors.white),
          title: const Text(
            'Show Word Count',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Switch(
            value: controller.preferences.showWordCount,
            onChanged: (value) {
              controller.setShowWordCount(value);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        // Focus Mode
        ListTile(
          leading: const Icon(Icons.center_focus_strong, color: Colors.white),
          title: const Text(
            'Focus Mode',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: const Text(
            'Hide UI elements while typing',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: Switch(
            value: controller.preferences.focusMode,
            onChanged: (value) {
              controller.setFocusMode(value);
            },
            activeColor: Colors.indigo.shade200,
            activeTrackColor: Colors.indigo.shade700,
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
      ],
    );
  }
  
  Widget _buildSecuritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'SECURITY',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.white),
          title: const Text(
            'Sign Out',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          onTap: () => _showLogoutConfirmation(context),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
          child: Text(
            'ABOUT',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const ListTile(
          leading: Icon(Icons.info_outline, color: Colors.white),
          title: Text(
            'App Version',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'SAGE Local Edition 1.0.0',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
        
        const ListTile(
          leading: Icon(Icons.code, color: Colors.white),
          title: Text(
            'Made with Flutter',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            'A beautiful note-taking app',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ),
        const Divider(color: Color(0xFF333333), height: 1),
      ],
    );
  }

  void _showEditAccountDialog(BuildContext context, PreferencesController controller) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final nameController = TextEditingController(
      text: controller.preferences.displayName,
    );
    final emailController = TextEditingController(
      text: controller.preferences.email,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Edit Account',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () => _changeAvatar(context, controller),
              child: Obx(() {
                final avatarPath = controller.preferences.avatarPath;
                return CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.indigo.shade200,
                  backgroundImage: avatarPath != null
                      ? FileImage(File(avatarPath))
                      : null,
                  child: avatarPath == null
                      ? Icon(Icons.person, size: 40, color: isDarkMode ? Colors.white : Colors.black54)
                      : null,
                );
              }),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _changeAvatar(context, controller),
              child: Text('Change Photo', style: TextStyle(color: isDarkMode ? Colors.indigo : Colors.indigo.shade700)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Display Name',
                labelStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.grey : Colors.black38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: isDarkMode ? Colors.grey : Colors.black38),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.indigo),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                controller.setDisplayName(nameController.text);
              }
              if (emailController.text.isNotEmpty) {
                controller.setEmail(emailController.text);
              }
              Navigator.pop(context);
            },
            child: Text('Save', style: TextStyle(color: Colors.indigo)),
          ),
        ],
      ),
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
  
  void _showLogoutConfirmation(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        title: Text(
          'Logout',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.offAll(() => const LoginScreen());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
} 