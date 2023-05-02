import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';

class Book {
  final String title;
  final String author;
  final String publisher;
  final int booksAvailable;
  final String image;
  var availableDate;

  Book(
      {required this.title,
      required this.author,
      required this.publisher,
      required this.booksAvailable,
      required this.image,
      this.availableDate});
}

class BookWidget extends StatefulWidget {
  final Book book;
  const BookWidget({super.key, required this.book});

  @override
  State<BookWidget> createState() => _BookWidgetState();
}

void _getbook(BuildContext context, Book book) async {
  final CollectionReference BookReservation =
      FirebaseFirestore.instance.collection('BooksReservation');

  var user = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  var bookref = FirebaseFirestore.instance.collection('Books').doc(book.title);

  void _alert(BuildContext context, String message, IconData icon, Color color,
      String content) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(message),
            icon: Icon(icon, color: color, size: 50),
            content: Text(
              content,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w200),
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK"))
            ],
          );
        });
  }
  //if user dont have same book ib BooksReservation collection add it
// Get a reference to the Firestore collection

// Define the Firestore query
  Query query = BookReservation.where('user', isEqualTo: user)
      .where('book', isEqualTo: bookref);

// Get a stream of QuerySnapshot objects
  Future<QuerySnapshot> future = query.get();

// Listen to the stream and get the number of documents
  future.then((QuerySnapshot snapshot) {
    int numberOfDocuments = snapshot.size;
    print(numberOfDocuments);
    if (numberOfDocuments == 0) {
      DatePicker.showDatePicker(context,
          showTitleActions: true,
          minTime: DateTime.now(),
          maxTime: DateTime.now().add(const Duration(days: 30)),
          onConfirm: (date) {
        print('confirm $date');

        BookReservation.add({
          'user': user,
          'book': bookref,
          'date': DateTime.now(),
          'returnDate': date
        });

        bookref.update({'available': book.booksAvailable - 1});

        _alert(context, "Book Reserved", Icons.check, Colors.green,
            "You can take your book from library in 3 days");
      }, currentTime: DateTime.now(), locale: LocaleType.tr);
    } else {
      _alert(context, "You Already Have Same Book", Icons.warning, Colors.red,
          "You can only take one copy of the same book");
      print("You already have this book");
    }
  });

  // if user dont have same book ib BooksReservation collection add it
}

// open dialog for book details
void _openBookDetails(BuildContext context, Book book) {
  int deviceWidth = MediaQuery.of(context).size.width.toInt();
  int deviceHeight = MediaQuery.of(context).size.height.toInt();
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
            insetAnimationCurve: Curves.bounceInOut,
            elevation: 22,
            child: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 255, 255, 255),
                  Color.fromARGB(124, 176, 177, 173)
                ],
              )),
              padding: deviceHeight > 800
                  ? const EdgeInsets.all(20)
                  : const EdgeInsets.fromLTRB(10, 10, 10, 20),
              width: deviceWidth > 800 ? deviceWidth * 0.3 : deviceWidth * 0.8,
              height: deviceHeight * 0.6,
              child: Column(
                children: [
                  Expanded(
                    flex: 27,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      color: const Color.fromARGB(62, 120, 33, 141),
                      child: Hero(
                        tag: book.title,
                        child: Image.network(book.image, fit: BoxFit.fitWidth,
                            errorBuilder: (BuildContext context,
                                Object exception, StackTrace? stackTrace) {
                          print(exception);
                          return const Icon(Icons.book, size: 200);
                        }),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      //color: Colors.green,
                      child: Text(
                        book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      //color: Colors.yellow,
                      child: Text(
                        book.author,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Container(
                      //color: Colors.yellow,
                      child: Text(
                        book.publisher,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w200),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(

                        //color: Colors.yellow,
                        child: book.booksAvailable > 0
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 10,
                                  primary:
                                      const Color.fromARGB(255, 155, 215, 33),
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () {
                                  _getbook(context, book);
                                },
                                child: const Text(
                                  "Get Book",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ))
                            : Column(
                                children: [
                                  const Text(
                                    textAlign: TextAlign.center,
                                    "No Books Available ",
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Text("Avaliable date: " +
                                      (DateFormat.yMMMd().format(book.availableDate)).toString())
                                ],
                              )),
                  ),
                  Expanded(
                    flex: 3,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Close",
                          style: TextStyle(color: Colors.blue, fontSize: 15),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ));
      });
}

class _BookWidgetState extends State<BookWidget> {
  @override
  Widget build(BuildContext context) {
    int deviceWidth = MediaQuery.of(context).size.width.toInt();

    return InkWell(
      onTap: () => _openBookDetails(context, widget.book),
      child: Card(
          // border on card black
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 10,
          child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(10),
              height: deviceWidth * 0.63,
              width: 50,
              //change color of container
              //color: Colors.red,
              child: Column(
                children: [
                  //image
                  Expanded(
                    flex: 27,
                    child: Container(
                      height: deviceWidth * 0.63 * 0.6,
                      width: double.infinity,
                      color: const Color.fromARGB(62, 120, 33, 141),
                      child: Hero(
                        tag: widget.book.title,
                        child: Image.network(widget.book.image,
                            fit: BoxFit.fitHeight, errorBuilder:
                                (BuildContext context, Object exception,
                                    StackTrace? stackTrace) {
                          print(exception);
                          return const Icon(Icons.book, size: 200);
                        }),
                      ),
                    ),
                  ),
                  //title
                  Expanded(
                    flex: 5,
                    child: Container(
                      width: double.infinity,
                      //color: Colors.green,
                      child: Text(
                        widget.book.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  //author
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      //color: Colors.yellow,
                      child: Text(
                        widget.book.author,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // books available
                  Expanded(
                    flex: 3,
                    child: Container(
                        width: double.infinity,
                        //color: Colors.orange,
                        child: widget.book.booksAvailable > 0
                            ? Text(
                                '${widget.book.booksAvailable} books available',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.green),
                              )
                            : const Text(
                                "No books available ",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w200,
                                    color: Colors.red),
                              )),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  // book seller
                  Expanded(
                    flex: 2,
                    child: Container(
                      width: double.infinity,
                      //color: Colors.purple,
                      child: Text(
                        widget.book.publisher,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w100),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
