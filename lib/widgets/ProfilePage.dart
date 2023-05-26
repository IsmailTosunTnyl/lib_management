import 'package:flutter/material.dart';
import 'package:lib_management/widgets/components/mybooks.dart';
import 'package:lib_management/widgets/components/mydesks.dart';
import 'package:lib_management/widgets/components/my_profile.dart';

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
        child: Column(
      children: [
        ProfilePageHeader(context: context),
        SizedBox(
          height: 8,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Container(
                  height: 500, width: mediaQuery.size.width, child: MyBooks()),
              Container(
                  height: 500, width: mediaQuery.size.width, child: MyDesks()),
            ],
          ),
        ),
      ],
    ));
  }
}
