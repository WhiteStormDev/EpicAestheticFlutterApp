import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/widgets/card_widget.dart';
import 'package:epic_aesthetic/widgets/please_sign_up_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:provider/provider.dart';

class RatePage extends StatefulWidget {
  const RatePage({Key key}) : super(key: key);

  @override
  _RatePageState createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
  String _epicText = "Epic";
  String _aestheticText = "Aesthetic";
  String _textMessage = "<Epic< or >Aesthetic>";
  DragStartDetails _startDetails;
  List<ImageModel> imageModels;
  List<CardWidget> cardData;
  UserModel user;
  var reference = FirebaseFirestore.instance.collection('images');

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);
    if (user == null)
      return PleaseSignUpWidget();

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
      return cardData.length == 0 ?
        Text("You just liked every image!",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
        )
      : Stack(
        children:cardData.toList(),
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  var swiperController = SwiperController();

  bool isLiked(String userId, ImageModel image) {
    for (var k in image.epicLikes.keys) {
      if (k == userId){
        if (image.epicLikes[k]) return true;
      }
    }
    for (var k in image.aestheticLikes.keys) {
      if (k == userId){
        if (image.aestheticLikes[k]) return true;
      }
    }
    return false;
  }

  _getFeed() async {
    if (user == null) return;
    imageModels = await DatabaseService().getImages();
    List<CardWidget> cards = [];
    imageModels.forEach((element) {
      if(!isLiked(user.id, element))
        cards.add(CardWidget(
          imageUrl: element.imageUrl,
          id: element.id,
          onSwipe: onSwipe,
          onCancelSwipe: onCancelSwipe,
          onUpdateSwipe: onUpdateSwipe,
          onStartSwipe: onStartSwipe,
      ));
    });

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
    toast(dir);
    switch (dir) {
      case Direction.Left:
        _likeEpicImage(id);
        break;
      case Direction.Right:
        _likeAestheticImage(id);
        break;
    }
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
          duration: Duration(milliseconds: 600),
          content: Text(text)
      ),
    );
  }

  void _likeEpicImage(String swipedImageId) {
    var userId = user.id;
    reference.doc(swipedImageId).update({'epicLikes.$userId': true});
  }

  void _likeAestheticImage(String swipedImageId) {
    var userId = user.id;
    reference.doc(swipedImageId).update({'aestheticLikes.$userId': true});
  }
}

