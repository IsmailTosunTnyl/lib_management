import 'package:flutter/material.dart';

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
      onTap: () => print(widget.desk.usersQueue),
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
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 10),
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
