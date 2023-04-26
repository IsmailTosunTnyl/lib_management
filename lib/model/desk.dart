import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

/// Desk class for the desk object
class Desk {
  /// Desk class
  final int deskID;
  final bool isAvailable;
  final bool isUserHere;
  var usersQueue;

  Desk(
      {required this.deskID,
      required this.isAvailable,
      required this.isUserHere,
      required this.usersQueue});

  factory Desk.fromJson(Map<String, dynamic> json) {
    return Desk(
        deskID: json['deskID'],
        isAvailable: json['isAvailable'],
        isUserHere: json['isUserHere'],
        usersQueue: json['usersQueue']);
  }
}

void _makerezervation(BuildContext context, var rezervationsList, Desk desk) {
  bool isreserved = false;
  var pickedstarttime;
  var pickedendtime;
  DatePicker.showDateTimePicker(
    context,
    minTime: DateTime.now(),
    currentTime: DateTime.now(),
    showTitleActions: true,
    onConfirm: (date) {
      DatePicker.showDateTimePicker(
        minTime: date.add(const Duration(minutes: 30)),
        context,
        showTitleActions: true,
        onConfirm: (date2) {
          pickedendtime = date2;
          pickedstarttime = date;
          for (int index = 0; index < rezervationsList.docs.length; index++) {
            DateTime startdatetime =
                (rezervationsList.docs[index].data()['starttime'] as Timestamp)
                    .toDate();
            DateTime enddatetime =
                (rezervationsList.docs[index].data()['endtime'] as Timestamp)
                    .toDate();

            if (startdatetime.isBefore(date2) && date.isBefore(enddatetime)) {
              // show alert
              isreserved = true;
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      icon: Icon(Icons.warning, color: Colors.red),
                      title: const Text("Warning",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      content: const Text(
                          "There is a reservation in this time duration \n Please select another time interval "),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text("Ok"))
                      ],
                    );
                  });
            }
          }

          if (!isreserved) {
            // get user data from firebaseauth

            var user = FirebaseAuth.instance.currentUser!.uid;

            // add rezervation to firebase
            FirebaseFirestore.instance.collection('Rezervations').add({
              'desk': FirebaseFirestore.instance
                  .collection("Desks")
                  .doc(desk.deskID.toString()),
              'starttime': pickedstarttime,
              'endtime': pickedendtime,
              'user': FirebaseFirestore.instance
                  .collection("Users")
                  .doc(user.toString()),
              'isstart': false,
              'isend': false,
            });

            // show alert
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    icon: Icon(Icons.check, color: Colors.green),
                    title: const Text("Success",
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    content: const Text(
                      "Rezervation is added",
                      textAlign: TextAlign.center,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Ok"))
                    ],
                  );
                });
          }
        },
        maxTime: date.add(const Duration(hours: 5)),
        currentTime: date.add(const Duration(minutes: 30)),
        locale: LocaleType.tr,
      );
    },
    locale: LocaleType.tr,
  );
}

Future<QuerySnapshot<Map<String, dynamic>>> _getRezervationlist(
    Desk desk) async {
  var rezervations = FirebaseFirestore.instance
      .collection('Rezervations')
      .where('desk',
          isEqualTo: FirebaseFirestore.instance
              .collection("Desks")
              .doc(desk.deskID.toString()))
      .orderBy('starttime', descending: false);

  return rezervations.get();
}

void _deskDetails(BuildContext context, Desk desk) async {
  final int deviceHeight = MediaQuery.of(context).size.height.toInt();
  final int deviceWidth = MediaQuery.of(context).size.width.toInt();

  // get rezervations data from firebase in list
  /*
  var rezervations = FirebaseFirestore.instance
      .collection('Rezervations')
      .where('desk',
          isEqualTo: FirebaseFirestore.instance
              .collection("Desks")
              .doc(desk.deskID.toString()));*/
  var rezervationsList = await _getRezervationlist(desk);

  //print(rezervationsList.docs[0].data());
  // ignore: use_build_context_synchronously
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shadowColor: desk.isAvailable ? Colors.green : Colors.red,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 10,
          insetAnimationCurve: Curves.bounceIn,
          insetAnimationDuration: const Duration(seconds: 5),
          child: Container(
            margin: const EdgeInsets.all(10),
            width: deviceWidth * 0.8,
            height: deviceHeight * 0.5,
            child: Column(children: [
              Text("Desk ${desk.deskID}",
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: desk.isAvailable ? Colors.green : Colors.red,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                width: double.infinity,
                height: deviceHeight * 0.1,
                margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                child: const Icon(
                  Icons.people_alt_outlined,
                  size: 50,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // build rezervation add button
              ElevatedButton(
                onPressed: () =>
                    _makerezervation(context, rezervationsList, desk),
                child: Text("Make Rezervation"),
              ),
              Expanded(
                  child: Column(children: [
                const Text(
                  "Rezervations",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: rezervationsList.docs.length <= 0
                      ? Text("No Future Rezervation")
                      : ListView.builder(
                          itemCount: rezervationsList.docs.length,
                          itemBuilder: (context, index) {
                            DateTime enddatetime = (rezervationsList.docs[index]
                                    .data()['endtime'] as Timestamp)
                                .toDate();
                            DateTime startdatetime = (rezervationsList
                                    .docs[index]
                                    .data()['starttime'] as Timestamp)
                                .toDate();
                            String startDate = DateFormat('dd/MM/yyyy, HH:mm')
                                .format(startdatetime);
                            String endDate = DateFormat('dd/MM/yyyy, HH:mm')
                                .format(enddatetime);
                            // find duration of rezervation
                            Duration duration =
                                startdatetime.difference(enddatetime);

                            return Card(
                              child: Row(
                                children: [
                                  Column(
                                    children: [
                                      Text("Start: $startDate"),
                                      Text("End: $endDate")
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Icon(Icons.timelapse, size: 30),
                                  Flexible(
                                      child: Text(
                                          "${duration.inMinutes.abs()} minutes"))
                                ],
                              ),
                            );
                          },
                        ),
                )
              ]))
              // show rezervations in a listview
            ]),
          ),
        );
      });
}

/// DeskWidget class for the desk widget
class DeskWidget extends StatefulWidget {
  final Desk desk;
  const DeskWidget({Key? key, required this.desk}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DeskWidgetState();
  }
}

class _DeskWidgetState extends State<DeskWidget> {
  @override
  Widget build(BuildContext context) {
    // Find Duration for the desk before available
    var rezervations_stream = FirebaseFirestore.instance
        .collection('Rezervations')
        .where('desk',
            isEqualTo: FirebaseFirestore.instance
                .collection("Desks")
                .doc(widget.desk.deskID.toString()))
        .orderBy('starttime', descending: false)
        .limit(1)
        .snapshots();

    return InkWell(
      onTap: () => _deskDetails(context, widget.desk),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 7,
        shadowColor: widget.desk.isAvailable ? Colors.green : Colors.red,
        child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: widget.desk.isAvailable ? Colors.green : Colors.red,
                  width: 2),
            ),
            child: Column(
              children: [
                Text("Desk ${widget.desk.deskID}",
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.bold)),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                  color: widget.desk.isAvailable ? Colors.green : Colors.red,
                  child: const Icon(
                    Icons.people_alt_outlined,
                    size: 50,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 5, 8, 5),
                  child: Row(
                    children: widget.desk.isAvailable
                        ? [
                            const Icon(Icons.check_circle),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(child: Text("Desk Available")),
                          ]
                        : [
                            const Icon(Icons.timelapse_sharp),
                            StreamBuilder(
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasError) {
                                    return Flexible(
                                        child:
                                            const Text('Something went wrong'));
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Text("Loading");
                                  }

                                  return Container(
                                      child: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                            Map<String, dynamic> data =
                                                document.data()!
                                                    as Map<String, dynamic>;

                                            // find duration of rezervation
                                            Duration duration = (DateTime.now())
                                                .difference((data['endtime']
                                                        as Timestamp)
                                                    .toDate());

                                            return Flexible(
                                                child: Text(
                                                    "${duration.inMinutes.abs()} minutes"));
                                          })
                                          .toList()
                                          .last);
                                },
                                stream: rezervations_stream),
                          ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
