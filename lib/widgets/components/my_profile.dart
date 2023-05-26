import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePageHeader extends StatefulWidget {
  final BuildContext context;
  String username = "";
  String email = "";
  String penalty = "";
  ProfilePageHeader({Key? key, required this.context}) : super(key: key);

  @override
  State<ProfilePageHeader> createState() => _ProfilePageHeaderState();
}

class _ProfilePageHeaderState extends State<ProfilePageHeader> {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) => {
              setState(() {
                widget.username = value.data()!['name'];
                widget.email = value.data()!['email'];
                widget.penalty = value.data()!['penalty'].toString();
              })
            });
    var mediaQuery = MediaQuery.of(context);
    return Container(
        height: 100,
        width: mediaQuery.size.width,
        color: const Color.fromARGB(255, 79, 104, 155),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // fill horisationally with an image
            Positioned(
              child: Opacity(
                opacity: 0.8,
                child: Container(
                  height: 200,
                  width: mediaQuery.size.width,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/Images/plants2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                Text(widget.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 1),
                Text(widget.email,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
                const SizedBox(height: 1),
                Text("Penalty: ${widget.penalty}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ],
        ));
  }
}
