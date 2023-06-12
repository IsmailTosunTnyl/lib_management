import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';

class MainDrawer extends StatefulWidget {
  final Function(String v) PageChange;
  MainDrawer({super.key, required this.PageChange});
  String username = "";
  @override
  State<MainDrawer> createState() {
    return _MainDrawerState();
  }
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    getuser() async {
      var userref = FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      var user = await userref.get();
      setState(() {
        widget.username = user.data()!['name'];
      });
    }

    var userstream = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();

    return InkWell(
      onTap: () {
        getuser();
      },
      child: Drawer(
          child: Column(
        children: [
          DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.fromARGB(255, 246, 242, 212),
                    Color.fromARGB(255, 149, 209, 204),
                    Color.fromARGB(255, 85, 132, 172),
                    Color.fromARGB(255, 79, 104, 155),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.person, size: 50),
                  const SizedBox(
                    width: 10,
                  ),
                  StreamBuilder(
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Text(
                            snapshot.data!['name'],
                            style: TextStyle(fontSize: 20),
                          );
                        } else {
                          return const Text(
                            "Loading",
                            style: TextStyle(fontSize: 20),
                          );
                        }
                      },
                      stream: userstream),
                ],
              )),
          ListTile(
              leading: Icon(Icons.book_rounded),
              title: Text("Books"),
              onTap: () {
                widget.PageChange("BookPage");
                Navigator.pop(context);
              }),
          ListTile(
              leading: Icon(Icons.desk_rounded),
              title: Text("Desk"),
              onTap: () {
                widget.PageChange("DeskPage");
                Navigator.pop(context);
              }),
          ListTile(
              leading: Icon(Icons.adb_outlined),
              title: Text("BookAI"),
              onTap: () {
                widget.PageChange("BookAIPage");
                Navigator.pop(context);
              }),
          ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile"),
              onTap: () {
                widget.PageChange("ProfilePage");
                Navigator.pop(context);
              }),
        ],
      )),
    );
  }
}
