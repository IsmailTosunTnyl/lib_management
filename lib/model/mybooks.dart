import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyBooks extends StatefulWidget {
  const MyBooks({Key? key}) : super(key: key);

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _MyBooksState extends State<MyBooks> {
  @override
  var user = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> BookReservationStream = FirebaseFirestore
        .instance
        .collection('BooksReservation')
        .where("user", isEqualTo: user)
        .snapshots();

    return Container(
        child: StreamBuilder(
      stream: BookReservationStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Something went wrong'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data =
                document.data()! as Map<String, dynamic>;

            // get book data from book reference in data

            return StreamBuilder(
                stream: data['book'].snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot2) {
                  if (snapshot2.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot2.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  Map<String, dynamic> data2 =
                      snapshot2.data!.data()! as Map<String, dynamic>;

                  return Card(
                    child: ListTile(
                        leading: Image.network(data2['image']),
                        title: Text(data2['name']),
                        subtitle:
                            DateTime.now().isBefore(data['returnDate'].toDate())
                                ? Text(data['returnDate']
                                    .toDate()
                                    .toString()
                                    .substring(0, 10))
                                : Text(
                                    '${data['returnDate'].toDate().toString().substring(0, 10)} (Overdue)',
                                    style: const TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold),
                                  ),
                        trailing: TextButton(
                          onPressed: () {
                            //FirebaseFirestore.instance
                            //    .collection('BooksReservation')
                            //    .doc(document.id)
                            //    .delete();
                            print(document.id);
                          },
                          child: const Text("Return"),
                        )),
                  );
                });
          }).toList(),
        );
      },
    ));
  }
}
