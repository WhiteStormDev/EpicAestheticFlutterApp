import 'dart:io';

import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/image_upload_page.dart';
import 'package:epic_aesthetic/pages/photo_tape_page.dart';
import 'package:epic_aesthetic/pages/profile_page.dart';
import 'package:epic_aesthetic/pages/rate_page.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  final List<Widget> screens = [
    new ProfilePage(),
    new ImageUploadPage(),
    new PhotoTapePage(feedType: FeedType.Epic),
    new PhotoTapePage(feedType: FeedType.All),
    new PhotoTapePage(feedType: FeedType.Aesthetic),
    new RatePage(),
  ];

  @override
  State<StatefulWidget> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  File file;
  int _pageIndex = 0;
  UserModel user;

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);
    return Scaffold(
        bottomNavigationBar: new BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          unselectedLabelStyle: TextStyle(color: Global.lightGrey),
          selectedLabelStyle: TextStyle(color: Global.purple),
          unselectedIconTheme: IconThemeData(color: Global.lightGrey),
          selectedIconTheme: IconThemeData(color: Global.purple),
          showSelectedLabels: true,

          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.account_box_rounded),
                label: 'account'),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.upload_file),
                label: 'upload'),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.fireplace), label: 'epic'),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.compare_rounded), label: 'all'),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.wallpaper), label: 'aesthetic' ),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.rate_review_rounded),
                label: 'rate'),

          ],
          onTap: (int index) {
            setState(() {
              _pageIndex = index;
            });
          },
          currentIndex: _pageIndex,
        ),
        body: IndexedStack(
          index: _pageIndex,
          children: widget.screens,
        ));
  }
}
