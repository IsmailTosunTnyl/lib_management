import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/desk.dart';

class DeskPage extends StatefulWidget {
  DeskPage({Key? key}) : super(key: key);

  final Stream<QuerySnapshot> _desksStream =
      FirebaseFirestore.instance.collection('Desks').snapshots();
  @override
  State<StatefulWidget> createState() {
    return _DeskPageState();
  }
}

class _DeskPageState extends State<DeskPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: StreamBuilder(
            stream: widget._desksStream,
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
                    height: 100,
                    child: GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.7,
                      ),
                      children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        final Map<String, dynamic> data =
                            document.data()! as Map<String, dynamic>;

                        return DeskWidget(
                          desk: Desk.fromJson(data),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            }));
  }
}
