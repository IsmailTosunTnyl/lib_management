import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

void _deskDetails(BuildContext context, Desk desk) async {
  final int deviceHeight = MediaQuery.of(context).size.height.toInt();
  final int deviceWidth = MediaQuery.of(context).size.width.toInt();

  // get rezervations data from firebase in list
  var rezervations = FirebaseFirestore.instance
      .collection('Rezervations')
      .where('desk',
          isEqualTo: FirebaseFirestore.instance
              .collection("Desks")
              .doc(desk.deskID.toString()));
  var rezervationsList = await rezervations.get();
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
              Expanded(
                  child: ListView.builder(
                itemCount: rezervationsList.docs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(rezervationsList.docs[index]
                        .data()['endtime']
                        .toString()),
                    subtitle: Text(rezervationsList.docs[index]
                        .data()['starttime']
                        .toString()),
                  );
                },
              ))
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
                Row(
                  children: [
                    const Icon(Icons.lock_clock_outlined),
                    Text(widget.desk.isAvailable ? "Yes" : "No"),
                  ],
                ),
              ],
            )),
      ),
    );
  }
}
