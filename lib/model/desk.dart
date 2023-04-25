import 'package:flutter/material.dart';

class Desk {
  /// Desk class
  final String deskID;
  final bool isAvailable;
  final bool isUserHere;
  final List<String> usersQueue;

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
  const DeskWidget({Key? key,required this.desk}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    
    return _DeskWidgetState();
  }
}

class _DeskWidgetState extends State<DeskWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Card(
      child: Container(
        color: widget.desk.isAvailable ? Colors.green : Colors.red,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text("Desk ${widget.desk.deskID}"),
            Icon(Icons.people_alt_outlined, size: 50,),
            
            Row(
              children: [
                Icon(Icons.lock_clock_outlined),
                Text(widget.desk.isAvailable ? "Yes" : "No"),
              ],
            ),
            
          ],
        )
        ),
    );
  }
}
