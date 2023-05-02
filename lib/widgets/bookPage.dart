import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lib_management/model/book.dart';

class BookPage extends StatefulWidget {
  final Stream<QuerySnapshot> _booksStream =
      FirebaseFirestore.instance.collection('Books').snapshots();

  final Stream<QuerySnapshot> _booksReservationStream =
      FirebaseFirestore.instance.collection('BooksReservation').orderBy("returnDate").snapshots();

  BuildContext context;
  BookPage({Key? key, required this.context}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  @override
  Widget build(BuildContext context) {
    var booksReservation = FirebaseFirestore.instance
        .collection('BooksReservation')
        .limit(1)
        .snapshots();

    print(booksReservation);

    var mediaQuery = MediaQuery.of(context);
    print((mediaQuery.size.width / 170).truncate());
    print("******************************");
    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: widget._booksStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          return StreamBuilder<QuerySnapshot>(
              stream: widget._booksReservationStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot2) {
                if (snapshot2.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height,
                        padding: const EdgeInsets.all(5),
                        child: GridView(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                (mediaQuery.size.width / 170).truncate(),
                            childAspectRatio: 0.6,
                          ),
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            final Map<String, dynamic> data =
                                document.data()! as Map<String, dynamic>;

                            /*snapshot2.data!.docs.map((DocumentSnapshot doc) {
                              final Map<String, dynamic> data2 =
                                  doc.data()! as Map<String, dynamic>;
                              if (data['name'] == data2['name']) {
                                data['available'] = data['available'] - 1;
                              }
                            }).toList();*/

                            var data2 = snapshot2.data!.docs;
                            

                            for (var rez in data2) {
                              if (rez["book"] == document.reference) {
                                
                                
                                return BookWidget(
                              book: Book(
                                  title: data['name'],
                                  author: data['author'],
                                  publisher: data['publisher'],
                                  booksAvailable: data['available'],
                                  image: data['image'],
                                  availableDate: (rez['returnDate'] as Timestamp).toDate() ),
                            );
                            
                              }
                            }

                            return BookWidget(
                              book: Book(
                                  title: data['name'],
                                  author: data['author'],
                                  publisher: data['publisher'],
                                  booksAvailable: data['available'],
                                  image: data['image'],
                                  availableDate: null),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
      ),
    );
  }
}
