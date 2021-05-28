import 'dart:async';

import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/widgets/card_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RatePageFake extends StatefulWidget {
  const RatePageFake({Key key}) : super(key: key);

  @override
  _RatePageFakeState createState() => _RatePageFakeState();
}

class _RatePageFakeState extends State<RatePageFake> {
  String _epicText = "Epic";
  String _aestheticText = "Aesthetic";
  String _textMessage = " ";
  DragStartDetails _startDetails;
  List<ImageModel> imageModels;
  List<CardWidget> cardData;


  _signUp() {
    Navigator.of(context).popAndPushNamed("/SignUp");
    // SharedPreferences.getInstance().then( (result) {
    //   result.setBool('first123456', true);
    // });
  }

  @override
  Widget build(BuildContext context) {
    _getFeed();

    return Scaffold(
      appBar: AppBar(
        title: Text("Epic or Aesthetic?"),
        backgroundColor: Global.purple,
      ),
      body:
        Column(
          children: [
            SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("<< " + _epicText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
                Text(_aestheticText + " >>",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Text(_textMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 40,
            ),
            Container(
              height: 400,
              margin: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              child: buildFeed(),
            ),
            SizedBox(
              height: 20,
            ),
            Text(_textMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ],
        ),
    );
  }


  buildFeed() {
    if (cardData != null) {
      return Stack(
        children: cardData.toList(),
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  var swiperController = SwiperController();
  var swipesCount = 0;

  _getFeed() async {
    imageModels = await DatabaseService().getImages();
    List<CardWidget> cards = [];
    imageModels.forEach((element) {
      cards.add(CardWidget(
      imageUrl: element.imageUrl,
      id: element.id,
      onSwipe: onSwipe,
      onCancelSwipe: onCancelSwipe,
      onUpdateSwipe: onUpdateSwipe,
      onStartSwipe: onStartSwipe,
    ));});

    setState(() {
      cardData = cards;
    });
  }

  onStartSwipe(DragStartDetails details){
    setState(() {
      _startDetails = details;
    });
  }

  onUpdateSwipe(DragUpdateDetails details){
    setState(() {
      var deltaX = _startDetails.localPosition.dx - details.localPosition.dx;
      var deltaY = _startDetails.localPosition.dy - details.localPosition.dy;

      if (deltaX.abs() > deltaY.abs() || deltaY.abs() < 20){
        _textMessage = deltaX < 0 ? "Aesthetic!" : "Epic!";
      } else {
        _textMessage = "Skip!";
      }
    });
  }

  onCancelSwipe(Offset offset, DragEndDetails details){
    _textMessage = "";
  }

  onSwipe(Direction dir, String id) {
    swipesCount = swipesCount + 1;
    toast(dir);

    if (swipesCount > 3)
      _signUp();
  }
  toast(Direction dir)
  {
    setState(() {
      String content;
      switch (dir) {

        case Direction.Left:
          content = "EPIC!";
          break;
        case Direction.Right:
          content = "AESTHETIC!";
          break;
        case Direction.Up:
          content = "meh...";
          break;
        case Direction.Down:
          content = "meh...";
          break;
      }

      _showToast(content);
    });
  }

  void _showToast(String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        duration: Duration(milliseconds: 450),
        content: Text(text)
      ),
    );
  }
}

