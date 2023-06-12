import 'package:flutter_test/flutter_test.dart';
import 'package:lib_management/model/book.dart';
import 'package:lib_management/model/desk.dart';

void main() {
  test('Book class should initialize correctly', () {
    // Create a sample book
    final book = Book(
      title: 'Sample Book',
      author: 'John Doe',
      publisher: 'ABC Publications',
      booksAvailable: 5,
      image: 'https://example.com/book-image.jpg',
      availableDate: DateTime.now(),
    );

    // Verify the properties of the book
    expect(book.title, 'Sample Book');
    expect(book.author, 'John Doe');
    expect(book.publisher, 'ABC Publications');
    expect(book.booksAvailable, 5);
    expect(book.image, 'https://example.com/book-image.jpg');
    expect(book.availableDate, isA<DateTime>());
  });

  test('Desk class should initialize correctly', () {
    // Create a sample book
    var desk =
        Desk(deskID: 0, isAvailable: true, isUserHere: false, usersQueue: []);

    expect(desk.deskID, 0);
  });
}
