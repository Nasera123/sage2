import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';
import '../models/book_model.dart';
import 'book_editor_view.dart';
import 'dart:io';

class BooksView extends StatefulWidget {
  const BooksView({super.key});

  @override
  State<BooksView> createState() => _BooksViewState();
}

class _BooksViewState extends State<BooksView> {
  final BookController _bookController = Get.find<BookController>();
  
  @override
  void initState() {
    super.initState();
    _refreshBooks();
  }
  
  Future<void> _refreshBooks() async {
    await _bookController.loadBooks();
  }

  void _navigateToBookEditor() {
    Get.to(() => const BookEditorView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshBooks,
        child: Obx(() {
          if (_bookController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = _bookController.books;
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.book_outlined, size: 64, color: isDarkMode ? Colors.grey : Colors.black38),
                  const SizedBox(height: 16),
                  Text('No books yet', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                  const SizedBox(height: 8),
                  Text('Create a book to organize related notes', 
                      style: TextStyle(color: isDarkMode ? Colors.grey : Colors.black54)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _navigateToBookEditor,
                    icon: const Icon(Icons.add),
                    label: const Text('Create Book'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D5AFE),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: books.length,
            itemBuilder: (context, index) {
              return BookGridItem(book: books[index]);
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToBookEditor,
        backgroundColor: const Color(0xFF3D5AFE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class BookGridItem extends StatelessWidget {
  final Book book;

  const BookGridItem({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTap: () {
        Get.to(() => BookEditorView(bookId: book.id));
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
                image: book.coverImagePath != null
                    ? DecorationImage(
                        image: FileImage(File(book.coverImagePath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  Icons.bookmark,
                  size: 48,
                  color: isDarkMode ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${book.noteIds.length} notes',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Created: ${_formatDate(book.createdAt)}',
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 