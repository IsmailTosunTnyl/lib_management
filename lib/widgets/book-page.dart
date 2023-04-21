import 'package:flutter/material.dart';
// import firebase_core plugin
import 'package:firebase_core/firebase_core.dart';
// import cloud_firestore plugin
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:lib_management/firebase_options.dart';
import 'package:lib_management/widgets/book.dart';



class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  // This widget is the root of your application.

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return const Center(
                child: Text('Something went wrong Check Connection'));
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return const BooksPage(title: 'Flutter Demo Home Page');
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class BooksPage extends StatefulWidget {
  const BooksPage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  int _counter = 0;
  final Stream<QuerySnapshot> _testStream =
      FirebaseFirestore.instance.collection('Test').snapshots();

  final Stream<QuerySnapshot> _booksStream =
      FirebaseFirestore.instance.collection('Books').snapshots();

  void _incrementCounter() {
    setState(() {
      FirebaseFirestore.instance.collection('Books').doc("1984").set({
        "author": "George Orwell",
        "available": 3,
        "image":
            "https://i.dr.com.tr/cache/500x400-0/originals/0000000064038-1.jpg",
        "name": "1984",
        "publisher": "Can Yayınları"
      });
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _booksStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text("Loading");
            }

            return Column(
              children: [
                SizedBox(
                  height: 600,
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                    ),
                    children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                      final Map<String, dynamic> data =
                          document.data()! as Map<String, dynamic>;

                      return BookWidget(
                        book: Book(
                            title: data['name'],
                            author: data['author'],
                            publisher: data['publisher'],
                            booksAvailable: data['available'],
                            image: data['image']),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
