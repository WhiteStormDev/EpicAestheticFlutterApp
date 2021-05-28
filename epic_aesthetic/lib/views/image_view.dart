import 'package:cached_network_image/cached_network_image.dart';
import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/photo_tape_page.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ImageView extends StatefulWidget {
  const ImageView(
      { this.feedType,
        this.imageUrl,
        this.username,
        this.epicLikes,
        this.aestheticLikes,
        this.imageId,
        this.ownerId});

  factory ImageView.fromDocument(DocumentSnapshot document, FeedType feedType) {
    return ImageView(
      imageUrl: document['imageUrl'],
      epicLikes: document['epicLikes'],
      aestheticLikes: document['aestheticLikes'],
      imageId: document.id,
      ownerId: document['userId'],
      feedType: feedType,

    );
  }

  factory ImageView.fromPost(ImageModel imageModel, UserModel user, FeedType feedType) {
    return  ImageView(
      username: user == null ? "" : user.username,
      imageUrl: imageModel.imageUrl,
      epicLikes: imageModel.epicLikes,
      aestheticLikes: imageModel.aestheticLikes,
      ownerId: imageModel.userId,
      imageId: imageModel.id,
      feedType: feedType,
    );
  }

  int getLikeCount(var likes) {
    if (likes == null) {
      return 0;
    }
// issue is below
    var vals = likes.values;
    int count = 0;
    for (var val in vals) {
      if (val == true) {
        count = count + 1;
      }
    }

    return count;
  }

  final String imageUrl;
  final String username;
  final epicLikes;
  final aestheticLikes;
  final String imageId;
  final String ownerId;
  final FeedType feedType;

  _ImageView createState() => _ImageView(
    feedType: feedType,
    imageUrl: this.imageUrl,
    username: this.username,
    epicLikes: this.epicLikes,
    aestheticLikes: this.aestheticLikes,
    epicLikesCount: getLikeCount(this.epicLikes),
    aestheticLikesCount: getLikeCount(this.aestheticLikes),
    ownerId: this.ownerId,
    imageId: this.imageId,
  );
}

class _ImageView extends State<ImageView> {
  final FeedType feedType;
  final String imageUrl;
  final String username;
  Map epicLikes;
  Map aestheticLikes;
  int epicLikesCount;
  int aestheticLikesCount;
  final String imageId;
  bool liked;
  final String ownerId;

  bool showHeart = false;

  TextStyle boldStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  var reference = FirebaseFirestore.instance.collection('images');
  UserModel user;

  _ImageView({
        this.feedType,
        this.imageUrl,
        this.username,
        this.epicLikes,
        this.aestheticLikes,
        this.imageId,
        this.epicLikesCount,
        this.aestheticLikesCount,
        this.ownerId});

  Row buildBothLikeIcons() {
    return Row(
      children: [
        buildLikeIcon(FeedType.Epic),
        Padding(padding: const EdgeInsets.only(right: 15.0)),
        buildLikeIcon(FeedType.Aesthetic)
      ],
    );
  }
  Row buildLikeIcon(FeedType type) {
    Color color;
    IconData icon;
    String likeLabel;
    int count;

    switch (type) {
      case FeedType.Epic:
        color = epicLikesCount > 0 ? Colors.pink : Colors.black;
        icon = Icons.fireplace_rounded;
        likeLabel = "epics";
        count = epicLikesCount;
        break;
      case FeedType.Aesthetic:
        color = aestheticLikesCount > 0 ? Colors.pink : Colors.black;
        icon = Icons.wallpaper;
        likeLabel = "aesthetics";
        count = aestheticLikesCount;
        break;
    }

    return Row(
      children: [
          GestureDetector(
          child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        //onTap: () {_likePost(imageId);}
        ),
        Padding(padding: const EdgeInsets.only(right: 5.0)),
        Container(
          margin: const EdgeInsets.only(left: 5.0),
          child: Text(
            "$count " + likeLabel,
            style: boldStyle,
          ),
        )
      ]
    );
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      //onDoubleTap: () => _likePost(imageId),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.fitWidth,
            placeholder: (context, url) => loadingPlaceHolder,
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
          showHeart
              ?
          Positioned(
            child: Container(
              width: 100,
              height: 100,
              child:  Opacity(
                  opacity: 0.85,
                  child: FlareActor("assets/flare/Like.flr",
                    animation: "Like",
                  )),
            ),
          )
              : Container()
        ],
      ),
    );
  }

  buildPostHeader({String ownerId}) {
    if (ownerId == null) {
      return Text("owner error");
    }

    return FutureBuilder(
        future: DatabaseService().getUser(ownerId),
        builder: (context, snapshot) {

          if (snapshot.data != null) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(snapshot.data.profileImageUrl),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                child: Text(snapshot.data.username, style: boldStyle),
                // child: Text("Username", style: boldStyle),
                // onTap: () {
                //   openProfile(context, ownerId);
                // },
              ),
              // subtitle: Text('subtitleText'),
            );
          }
          return Container();
        });
  }

  Container loadingPlaceHolder = Container(
    height: 400.0,
    child: Center(child: CircularProgressIndicator()),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(ownerId: ownerId),
        buildLikeableImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            feedType == FeedType.All ?
                buildBothLikeIcons()
              :
                buildLikeIcon(feedType),
          ],
        ),
      ],
    );
  }

  void removeActivityFeedItem() {
    FirebaseFirestore.instance
        .collection("insta_a_feed")
        .doc(ownerId)
        .collection("items")
        .doc(imageId)
        .delete();
  }
}
