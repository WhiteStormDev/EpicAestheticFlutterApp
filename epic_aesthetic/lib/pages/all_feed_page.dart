import 'dart:io';

import 'package:epic_aesthetic/pages/image_upload_page.dart';
import 'package:epic_aesthetic/pages/photo_tape_page.dart';
import 'package:epic_aesthetic/pages/profile_page.dart';
import 'package:flutter/material.dart';


class AllFeedPage extends StatefulWidget {
  AllFeedPage({Key key}) : super(key: key);
  final List<Widget> screens = [
    new PhotoTapePage(),
    new ImageUploadPage(),
    new ProfilePage()
  ];

  @override
  State<StatefulWidget> createState() => AllFeedPageState();
}

class AllFeedPageState extends State<AllFeedPage> {
  File file;
  int _pageIndex = 0;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
                icon: new Icon(Icons.wallpaper), title: new Text('feed')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.add_a_photo),
                title: new Text('add new photo')),
            new BottomNavigationBarItem(
                icon: new Icon(Icons.account_box_rounded),
                title: new Text('account'))
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
