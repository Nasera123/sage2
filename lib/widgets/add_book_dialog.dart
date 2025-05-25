import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog> {
  final TextEditingController _titleController = TextEditingController();
  final BookController _bookController = Get.find<BookController>();
  final _formKey = GlobalKey<FormState>();
  bool _isCreating = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
  
  Future<void> _createBook() async {
    if (!_formKey.currentState!.validate() || _isCreating) return;
    
    setState(() {
      _isCreating = true;
    });
    
    try {
      await _bookController.createBook(_titleController.text.trim());
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating book: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Book'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Book Title',
            hintText: 'Enter book title',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a book title';
            }
            return null;
          },
          autofocus: true,
          onFieldSubmitted: (_) => _createBook(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreating ? null : _createBook,
          child: _isCreating 
              ? const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ) 
              : const Text('Create'),
        ),
      ],
    );
  }
} 