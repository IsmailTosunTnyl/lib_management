import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_management/model/book.dart';

class BookPage extends StatefulWidget {
  final Stream<QuerySnapshot> _booksStream =
      FirebaseFirestore.instance.collection('Books').snapshots();

 

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: widget._booksStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
    );
  }
}
