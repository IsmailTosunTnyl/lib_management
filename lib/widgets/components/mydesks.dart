import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDesks extends StatefulWidget {
  const MyDesks({Key? key}) : super(key: key);

  @override
  State<MyDesks> createState() => _MyDesksState();
}

class _MyDesksState extends State<MyDesks> {
  var user = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> deskReservations = FirebaseFirestore.instance
        .collection('Rezervations')
        .where("user", isEqualTo: user)
        .snapshots();

    return Column(
      children: [
        Container(
          height: 40,
          width: MediaQuery.of(context).size.width,
          child: const Center(
            child: Text(
              'My Desks ',
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
            stream: deskReservations,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;

                return StreamBuilder(
                    stream: data['desk'].snapshots(),
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

                      return Card(
                        child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              color: Colors.green,
                              child: Center(
                                  child: Text(
                                data2['deskID'].toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                            ),
                            title: Text(data2['deskID'].toString()),
                            subtitle: Text(
                                data['isstart'] ? "Started" : "Not started"),
                            // cancel reservation
                            trailing: TextButton(
                              onPressed: () {
                                // move to history
                                FirebaseFirestore.instance
                                    .collection('RezervataionHistory')
                                    .doc(document.id)
                                    .set({
                                  'user': data['user'],
                                  'desk': data['desk'],
                                  'isstart': data['isstart'],
                                  'isend': data['isend'],
                                  'starttime': data['starttime'],
                                  'endtime': data['endtime'],
                                });

                                FirebaseFirestore.instance
                                    .collection('Rezervations')
                                    .doc(document.id)
                                    .delete();

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  backgroundColor:
                                      Color.fromARGB(255, 79, 104, 155),
                                  content: Text("Reservation canceled"),
                                ));
                              },
                              child: Text("Cancel"),
                            )),
                      );
                    });
              }).toList());
            },
          ),
        ),
      ],
    );
  }
}
