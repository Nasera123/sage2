import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';
import '../models/book_model.dart';

class BooksView extends StatelessWidget {
  const BooksView({super.key});

  @override
  Widget build(BuildContext context) {
    final bookController = Get.find<BookController>();

    return Obx(() {
      if (bookController.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final books = bookController.books;
      
      if (books.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.book_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No books yet'),
              SizedBox(height: 8),
              Text('Create a book to organize related notes', style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return BookGridItem(book: books[index]);
        },
      );
    });
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
    
    return GestureDetector(
      onTap: () {
        // Show book details
        _showBookDetails(context, book);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: book.coverImagePath != null
                  ? Image.asset(
                      book.coverImagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultCover();
                      },
                    )
                  : _buildDefaultCover(),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${book.noteIds.length} notes',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Created: ${_formatDate(book.createdAt)}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultCover() {
    final colors = [
      Colors.blue.shade200,
      Colors.red.shade200,
      Colors.green.shade200,
      Colors.amber.shade200,
      Colors.purple.shade200,
      Colors.teal.shade200,
    ];
    
    final colorIndex = book.id.hashCode % colors.length;
    final color = colors[colorIndex];
    
    return Container(
      color: color,
      child: Center(
        child: Icon(
          Icons.book,
          size: 64,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showBookDetails(BuildContext context, Book book) {
    final bookController = Get.find<BookController>();
    final notes = bookController.getSortedBookNotes(book.id);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // Show edit dialog
                          _showRenameDialog(context, book);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          // Show delete confirmation
                          _showDeleteConfirmation(context, book);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: notes.isEmpty
                      ? const Center(
                          child: Text('No notes in this book yet'),
                        )
                      : ListView.builder(
                          controller: scrollController,
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text('${index + 1}'),
                              ),
                              title: Text(note.title),
                              subtitle: Text(
                                'Last updated: ${_formatDate(note.updatedAt)}',
                              ),
                              onTap: () {
                                // Navigate to note
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening note "${note.title}"'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context, Book book) {
    final bookController = Get.find<BookController>();
    final titleController = TextEditingController(text: book.title);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Book'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Book Title',
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
              if (titleController.text.isNotEmpty) {
                bookController.renameBook(book.id, titleController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Book book) {
    final bookController = Get.find<BookController>();
    final notes = bookController.getSortedBookNotes(book.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text(
          'Are you sure you want to delete "${book.title}"?\n\n' +
          'The book will be deleted, but the ${notes.length} notes will remain available outside the book.',
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
              bookController.deleteBook(book.id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
} 