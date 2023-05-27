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
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userDocRef =
        FirebaseFirestore.instance.collection('Users').doc(user!.uid);

    return Center(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('BooksReservation')
            .where("user", isEqualTo: userDocRef)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          final reservationDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reservationDocs.length,
            itemBuilder: (BuildContext context, int index) {
              final reservationData =
                  reservationDocs[index].data() as Map<String, dynamic>;
              final bookRef = reservationData['book'] as DocumentReference;

              return StreamBuilder<DocumentSnapshot>(
                stream: bookRef.snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> bookSnapshot) {
                  if (bookSnapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final bookData =
                      bookSnapshot.data!.data() as Map<String, dynamic>;
                  final bookTitle = bookData['title'] as String;

                  return ListTile(
                    title: Text('ss'),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
