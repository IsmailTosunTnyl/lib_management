import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MyDesks extends StatefulWidget {
  MyDesks({Key? key}) : super(key: key);
  Map<String, int> monthData = {};

  @override
  State<MyDesks> createState() => _MyDesksState();
}

class _pydata {
  _pydata(this.month, this.minutes);

  final String month;
  final int minutes;
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

    final Stream<QuerySnapshot> deskReservationsHistory = FirebaseFirestore
        .instance
        .collection('RezervataionHistory')
        .where("user", isEqualTo: user)
        .where("isend", isEqualTo: true)
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
                            // ignore: prefer_interpolation_to_compose_strings
                            title: data['isstart']
                                ? Text('Desk ${data2['deskID']} (Started)')
                                : Text(
                                    'Desk ${data2['deskID']} (Not started Yet)'),
                            subtitle: Text(
                                'Start time: ${DateFormat('dd/MM/yyyy HH:mm').format(data['starttime'].toDate())}\nEnd time: ${DateFormat('dd/MM/yyyy HH:mm').format(data['endtime'].toDate())}'),
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
        SafeArea(
            child: StreamBuilder(
          stream: deskReservationsHistory,
          builder: (context, snapshot2) {
            if (snapshot2.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot2.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            var data = snapshot2.data!.docs.map((e) {
              Map<String, dynamic> data = e.data()! as Map<String, dynamic>;

              return data;
            }).toList();

            List<Future<void>> deskFutures = [];

            data.forEach((element) {
              // get the difference between start and end time in minutes with absolute value

              var timedifference = element['endtime']
                  .toDate()
                  .difference(element['starttime'].toDate())
                  .inMinutes;

              // if time difference is negative, it means that the user has not ended the reservation dont add it to the list

              if (timedifference > 0) {
                if (widget.monthData.keys.contains(
                    DateFormat('MMMM').format(element['starttime'].toDate()))) {
                  widget.monthData[DateFormat('MMMM')
                          .format(element['starttime'].toDate())] =
                      widget.monthData[DateFormat('MMMM')
                              .format(element['starttime'].toDate())]! +
                          timedifference as int;
                } else {
                  widget.monthData[DateFormat('MMMM')
                          .format(element['starttime'].toDate())] =
                      timedifference as int;
                }
              }
            });

            List<_pydata> pieData = [];
            widget.monthData.forEach((key, value) {
              pieData.add(_pydata(key, value));
            });

            print(widget.monthData);
            return SfCircularChart(
              title: ChartTitle(text: 'Desk usage per month'),
              palette: const [
                Colors.red,
                Colors.green,
                Colors.blue,
                Colors.yellow,
                Colors.purple,
                Colors.orange,
                Colors.pink,
                Colors.teal,
                Colors.brown,
                Colors.grey,
              ],
              legend: Legend(isVisible: true),
              series: <PieSeries<_pydata, String>>[
                PieSeries<_pydata, String>(
                  explode: true,
                  explodeIndex: 0,
                  dataSource: pieData,
                  xValueMapper: (_pydata data, _) => data.month,
                  yValueMapper: (_pydata data, _) => data.minutes,
                  dataLabelMapper: (_pydata data, _) => data.minutes.toString(),
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            );
          },
        ))
      ],
    );
  }
}
