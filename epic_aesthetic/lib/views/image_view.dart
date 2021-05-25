import 'package:cached_network_image/cached_network_image.dart';
import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class ImageView extends StatefulWidget {
  const ImageView(
      { this.imageUrl,
        this.username,
        this.epicLikes,
        this.aestheticLikes,
        this.imageId,
        this.ownerId});

  factory ImageView.fromDocument(DocumentSnapshot document) {
    return ImageView(
      imageUrl: document['imageUrl'],
      epicLikes: document['epicLikes'],
      aestheticLikes: document['aestheticLikes'],
      imageId: document.id,
      ownerId: document['userId'],
    );
  }

  factory ImageView.fromPost(ImageModel imageModel, UserModel user) {
    return ImageView(
      username: user.firstName,
      imageUrl: imageModel.imageUrl,
      epicLikes: imageModel.epicLikes,
      aestheticLikes: imageModel.aestheticLikes,
      ownerId: imageModel.userId,
      imageId: imageModel.id,
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

  _ImageView createState() => _ImageView(
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

  var reference = FirebaseFirestore.instance.collection('posts');
  UserModel user;

  _ImageView({
        this.imageUrl,
        this.username,
        this.epicLikes,
        this.aestheticLikes,
        this.imageId,
        this.epicLikesCount,
        this.aestheticLikesCount,
        this.ownerId});

  GestureDetector buildLikeIcon() {
    Color color;
    IconData icon;

    if (liked) {
      color = Colors.pink;
      icon = CupertinoIcons.heart_solid;
    } else {
      icon = CupertinoIcons.heart;
    }
    icon = CupertinoIcons.heart;
    return GestureDetector(
        child: Icon(
          icon,
          size: 25.0,
          color: color,
        ),
        onTap: () {
          _likePost(imageId);
        });
  }

  GestureDetector buildLikeableImage() {
    return GestureDetector(
      onDoubleTap: () => _likePost(imageId),
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
                backgroundImage: CachedNetworkImageProvider(snapshot.data.photoUrl),
                backgroundColor: Colors.grey,
              ),
              title: GestureDetector(
                child: Text(snapshot.data.name, style: boldStyle),
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
    user = Provider.of<UserModel>(context);
    liked = (aestheticLikes[user.id] == true);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        buildPostHeader(ownerId: ownerId),
        buildLikeableImage(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: const EdgeInsets.only(left: 20.0, top: 40.0)),
            buildLikeIcon(),
            Padding(padding: const EdgeInsets.only(right: 5.0)),
            Container(
              margin: const EdgeInsets.only(left: 5.0),
              child: Text(
                "$epicLikesCount likes",
                style: boldStyle,
              ),
            )
            // GestureDetector(
            //     child: const Icon(
            //       Icons.comment,
            //       size: 25.0,
            //     ),
            //     // onTap: () {
            //     //   goToComments(
            //     //       context: context,
            //     //       postId: postId,
            //     //       ownerId: ownerId,
            //     //       mediaUrl: mediaUrl);
            //     // }
            //     ),
          ],
        ),
        // Row(
        //   children: <Widget>[
        //     Container(
        //       margin: const EdgeInsets.only(left: 20.0),
        //       child: Text(
        //         "13 likes",
        //         // "$likeCount likes",
        //         style: boldStyle,
        //       ),
        //     )
        //   ],
        // ),
        // Row(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Container(
        //         margin: const EdgeInsets.only(left: 20.0),
        //         child: Text(
        //           "$username ",
        //           style: boldStyle,
        //         )),
        //     Expanded(child: Text("description")),
        //   ],
        // )
      ],
    );
  }

  void _likePost(String postId2) {
    var userId = user.id;
    bool _liked = epicLikes[userId] == true;

    if (_liked) {
      print('removing like');
      reference.doc(imageId).update({
        'likes.$userId': false
      });

      setState(() {
        epicLikesCount = epicLikesCount - 1;
        liked = false;
        epicLikes[userId] = false;
      });

      // removeActivityFeedItem();
    }

    if (!_liked) {
      print('liking');
      setState(() {
        epicLikesCount = epicLikesCount + 1;
        liked = true;
        epicLikes[userId] = true;
        showHeart = true;
      });
      Timer(const Duration(milliseconds: 2000), () {
        setState(() {
          showHeart = false;
        });
      });
      reference.doc(imageId).update({'likes.$userId': true});

    }
  }

  // void addActivityFeedItem() {
  //   FirebaseFirestore.instance
  //       .collection("insta_a_feed")
  //       .doc(ownerId)
  //       .collection("items")
  //       .doc(postId)
  //       .set({
  //     "username": currentUserModel.username,
  //     "userId": currentUserModel.id,
  //     "type": "like",
  //     "userProfileImg": currentUserModel.photoUrl,
  //     "mediaUrl": mediaUrl,
  //     "timestamp": DateTime.now(),
  //     "postId": postId,
  //   });
  // }

  void removeActivityFeedItem() {
    FirebaseFirestore.instance
        .collection("insta_a_feed")
        .doc(ownerId)
        .collection("items")
        .doc(imageId)
        .delete();
  }
}

// class ImagePostFromId extends StatelessWidget {
//   final String id;
//
//   const ImagePostFromId({this.id});
//
//   getImagePost() async {
//     var document =
//     await FirebaseFirestore.instance.collection('insta_posts').doc(id).get();
//     return ImagePost.fromDocument(document);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder(
//         future: getImagePost(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData)
//             return Container(
//                 alignment: FractionalOffset.center,
//                 padding: const EdgeInsets.only(top: 10.0),
//                 child: CircularProgressIndicator());
//           return snapshot.data;
//         });
//   }
// }
//
// void goToComments(
//     {BuildContext context, String postId, String ownerId, String mediaUrl}) {
//   Navigator.of(context)
//       .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
//     return CommentScreen(
//       postId: postId,
//       postOwner: ownerId,
//       postMediaUrl: mediaUrl,
//     );
//   }));
// }
