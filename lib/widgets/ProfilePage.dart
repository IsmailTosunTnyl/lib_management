import 'package:flutter/material.dart';
import 'package:lib_management/model/mybooks.dart';
import 'package:lib_management/model/mydesks.dart';

class ProfilePage extends StatefulWidget {
  final BuildContext context;
  const ProfilePage({Key? key, required this.context}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Container(
                height: 500, width: mediaQuery.size.width, child: MyBooks()),
            Container(
                height: 500, width: mediaQuery.size.width, child: MyDesks()),
          ],
        ));
  }
}
