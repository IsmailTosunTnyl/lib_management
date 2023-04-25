import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/desk.dart';

class DeskPage extends StatefulWidget {
  BuildContext context;
  DeskPage({Key? key,required this.context}) : super(key: key);

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
    var mediaQuery = MediaQuery.of(context);
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
                  Container(
                    height: mediaQuery.size.height,
                    padding: const EdgeInsets.all(5),
                    child: GridView(
                      gridDelegate:
                           SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:(mediaQuery.size.width / 170).truncate() ,
                        childAspectRatio: 0.5,
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
