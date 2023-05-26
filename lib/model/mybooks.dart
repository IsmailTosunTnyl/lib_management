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

                  bool isOverdue = DateTime.now().isBefore(
                      data['returnDate'].toDate()); // check if book is overdue

                  return Card(
                    child: ListTile(
                        leading: Image.network(data2['image']),
                        title: Text(data2['name']),
                        subtitle: isOverdue
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
                            // move book from BooksReservation to BooksReservationHistory

                            FirebaseFirestore.instance
                                .collection('BooksReservationHistory')
                                .doc()
                                .set({
                              'book': data['book'],
                              'user': data['user'],
                              'date': data['date'],
                              'isReturned': data['isReturned'],
                              'returnDate': data['returnDate'],
                            });

                            if (!isOverdue) {
                              // if book is overdue, add 1 to user's penalty
                              // get time difference between return date and current date

                              int difference = DateTime.now()
                                  .difference(data['returnDate'].toDate())
                                  .inDays;
                              print(difference);
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                'penalty': FieldValue.increment(difference)
                              });
                              // get total penalty from user

                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .get()
                                  .then((value) {
                                int penalty = value.data()!['penalty'];

                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Penalty'),
                                        content: SizedBox(
                                          height: 80,
                                          child: Center(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(Icons.warning,
                                                        color: Colors.red),
                                                    const SizedBox(width: 10),
                                                    Flexible(
                                                      child: Text(
                                                          'You have been charged with ${difference} Point of penalty.'),
                                                    ),
                                                    // show total penalty
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Flexible(
                                                    child: RichText(
                                                  text: TextSpan(
                                                    text: 'You have total ',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w100,
                                                      color: Colors.black,
                                                      fontSize: 16,
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                        text: '$penalty',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                      const TextSpan(
                                                        text:
                                                            ' penalty points.',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w100,
                                                          color: Colors.black,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))
                                              ],
                                            ),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('OK'))
                                        ],
                                      );
                                    });
                              });

                              // show dialog with penalty with icon
                            }
                            data['book'].update({
                              'available': FieldValue.increment(1),
                            });
                            FirebaseFirestore.instance
                                .collection('BooksReservation')
                                .doc(document.id)
                                .delete();
//
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor:
                                  Color.fromARGB(255, 79, 104, 155),
                              content: Text("Book returned!"),
                            ));
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
