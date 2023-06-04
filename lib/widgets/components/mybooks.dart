import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class MyBooks extends StatefulWidget {
  BuildContext context;
  MyBooks({Key? key, required this.context}) : super(key: key);

  // create a map for stroe month and total page read
  Map<String, int> monthData = {};

  @override
  State<MyBooks> createState() => _MyBooksState();
}

class _pydata {
  _pydata(this.month, this.pages);

  final String month;
  final int pages;
}

class _MyBooksState extends State<MyBooks> {
  @override
  var user = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  Widget build(BuildContext context) {
    // init a map to store the data , key is month and value is total page read
    List<_pydata> pieData = [];
    final Stream<QuerySnapshot> BookReservationStream = FirebaseFirestore
        .instance
        .collection('BooksReservation')
        .where("user", isEqualTo: user)
        .snapshots();

    final Stream<QuerySnapshot> readedBookStream = FirebaseFirestore.instance
        .collection('BooksReservationHistory')
        .where("user", isEqualTo: user)
        .snapshots();

    return Column(
      children: [
        // add a header
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: Text(
              'My Books',
              style: TextStyle(
                color: Color.fromARGB(255, 79, 104, 155),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
            child: StreamBuilder(
          stream: BookReservationStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        return const Center(
                            child: Text('Something went wrong'));
                      }

                      if (snapshot2.connectionState ==
                          ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }

                      Map<String, dynamic> data2 =
                          snapshot2.data!.data()! as Map<String, dynamic>;

                      bool isOverdue = DateTime.now().isBefore(
                          data['returnDate']
                              .toDate()); // check if book is overdue

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

                                  int difference = data['returnDate']
                                      .toDate()
                                      .difference(DateTime.now())
                                      .inDays;
                                  print(difference);
                                  //difference = difference * -1;
                                  print('difference: $difference');
                                  print(difference);
                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    'penalty': FieldValue.increment(difference)
                                  });
                                  // get total penalty from user

                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .get()
                                      .then((value) {
                                    int penalty = value.data()!['penalty'];

                                    showDialog(
                                        context: widget.context,
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
                                                        const Icon(
                                                            Icons.warning,
                                                            color: Colors.red),
                                                        const SizedBox(
                                                            width: 10),
                                                        Flexible(
                                                          child: Text(
                                                              'You have been charged with ${difference.abs()} Point of penalty.'),
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
                                                            style:
                                                                const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color: Colors.red,
                                                              fontSize: 18,
                                                            ),
                                                          ),
                                                          const TextSpan(
                                                            text:
                                                                ' penalty points.',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w100,
                                                              color:
                                                                  Colors.black,
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
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .update({
                                    'penalty': FieldValue.increment(10)
                                  });

                                  // show a dialog to congratulate user for returning book on time

                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Congratulations!'),
                                          content: SizedBox(
                                            height: 65,
                                            child: Center(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          color: Colors.green),
                                                      const SizedBox(width: 10),
                                                      Flexible(
                                                        child: Text(
                                                            'You have returned the book on time.'),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Flexible(
                                                    child: Text(
                                                      'Your karma has increased.',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontSize: 14),
                                                    ),
                                                  ),
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
                                }

                                data['book'].update({
                                  'available': FieldValue.increment(1),
                                });
                                FirebaseFirestore.instance
                                    .collection('BooksReservation')
                                    .doc(document.id)
                                    .delete();
//
                                /* ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor:
                                      Color.fromARGB(255, 79, 104, 155),
                                  content: Text("Book returned!"),
                                ));*/
                                
                                setState(() {
                                  // refresh page
                                  widget.monthData.clear();
                                });
                              },
                              child: const Text("Return"),
                            )),
                      );
                    });
              }).toList(),
            );
          },
        )),

        // Draw a graph of the number of books borrowed by the user and number of page readed by user
        SafeArea(
          child: StreamBuilder(
            stream: readedBookStream,
            builder: (context, snapshot3) {
              if (snapshot3.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot3.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              // get data from stream
              var data = snapshot3.data!.docs.map((e) {
                Map<String, dynamic> data = e.data()! as Map<String, dynamic>;
                return data;
              }).toList();

              // List to store the Future objects returned by book.get()
              List<Future<void>> bookFutures = [];

              data.forEach((element) {
                Future<void> future = element['book'].get().then((value) {
                  Map<String, dynamic> data2 =
                      value.data()! as Map<String, dynamic>;

                  if (widget.monthData.keys.contains(
                      DateFormat('MMMM').format(element['date'].toDate()))) {
                    widget.monthData[DateFormat('MMMM')
                        .format(element['date'].toDate())] = widget.monthData[
                            DateFormat('MMMM')
                                .format(element['date'].toDate())]! +
                        data2['pagecount'] as int;
                  } else {
                    widget.monthData[DateFormat('MMMM')
                            .format(element['date'].toDate())] =
                        data2['pagecount'] as int;
                  }
                });

                bookFutures.add(future);
              });

              // Wait for all book.get() operations to complete
              return FutureBuilder(
                future: Future.wait(bookFutures),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else {
                    print("END ***********");
                    widget.monthData.forEach((key, value) {
                      pieData.add(_pydata(key, value));
                    });

                    return SfCircularChart(
                      title: ChartTitle(text: 'Pages readed by month'),
                      legend: Legend(isVisible: true),
                      series: <PieSeries<_pydata, String>>[
                        PieSeries<_pydata, String>(
                          explode: true,
                          explodeIndex: 0,
                          dataSource: pieData,
                          xValueMapper: (_pydata data, _) => data.month,
                          yValueMapper: (_pydata data, _) => data.pages,
                          dataLabelMapper: (_pydata data, _) =>
                              data.pages.toString(),
                          dataLabelSettings: DataLabelSettings(isVisible: true),
                        ),
                      ],
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
