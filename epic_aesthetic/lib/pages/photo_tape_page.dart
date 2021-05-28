import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/views/image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class PhotoTapePage extends StatefulWidget {
  PhotoTapePage({
    Key key,
    this.feedType,
    }) : super(key: key);

  FeedType feedType;
  @override
  State<StatefulWidget> createState() => _PhotoTapePageState(feedType);
}

class _PhotoTapePageState extends State<PhotoTapePage>
    with AutomaticKeepAliveClientMixin<PhotoTapePage> {
  UserModel user;
  List<ImageModel> images;
  List<ImageView> feedData;
  final FeedType feedType;

  _PhotoTapePageState(this.feedType);

  String getLabel() {
    switch (feedType)
    {
      case FeedType.Epic:
        return "Epic";
      case FeedType.Aesthetic:
        return "Aesthetic";
      case FeedType.All:
        return "All";
    }
  }

  buildFeed() {
    if (feedData != null) {
      return ListView(
        children: feedData.reversed.toList(),
      );
    } else {
      return Container(
          alignment: FractionalOffset.center,
          child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);
    _getFeed();
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.refresh, color: Global.white),
            onPressed: _refresh),
        title: Text(getLabel(),
            style: const TextStyle(
                fontFamily: "Billabong", color: Global.white, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Global.purple
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: buildFeed(),
      ),
    );
  }

  Future<Null> _refresh() async {
    await _getFeed();

    setState(() {});

    return;
  }

  _getFeed() async {
    List<ImageView> imageViews;
    images = await DatabaseService().getImages();
    UserModel userFromDb = user == null ? null : await DatabaseService().getUser(user.id);
    imageViews = _generateFeed(images, userFromDb);
    setState(() {
      feedData = imageViews;
    });
  }

  List<ImageView> _generateFeed(List<ImageModel> imageModels, userFromDb) {
    List<ImageView> imageViews = [];
    switch (feedType){
      case FeedType.Epic:
        imageModels.sort((i1 , i2) {
          var epic1 = 0;
          var epic2 = 0;
          i1.epicLikes.forEach((key, value) {
            if (value)
              epic1 = epic1 + 1;
          });
          i2.epicLikes.forEach((key, value) {
            if (value)
              epic2 = epic2 + 1;
          });

          return epic1.compareTo(epic2);
        });
        break;
      case FeedType.Aesthetic:
        imageModels.sort((i1 , i2) {
          var aesthetic1 = 0;
          var aesthetic2 = 0;
          i1.aestheticLikes.forEach((key, value) {
            if (value)
              aesthetic1 = aesthetic1 + 1;
          });
          i2.aestheticLikes.forEach((key, value) {
            if (value)
              aesthetic2 = aesthetic2 + 1;
          });

          return aesthetic1.compareTo(aesthetic2);
        });
        break;
      case FeedType.All:
        imageModels.sort((i1 , i2) {
          var aLikes1 = 0;
          var aLikes2 = 0;
          var eLikes1 = 0;
          var eLikes2 = 0;

          i1.aestheticLikes.forEach((key, value) {
            if (value)
              aLikes1 = aLikes1 + 1;
          });
          i2.aestheticLikes.forEach((key, value) {
            if (value)
              aLikes2 = aLikes2 + 1;
          });
          i1.epicLikes.forEach((key, value) {
            if (value)
              eLikes1 = eLikes1 + 1;
          });
          i2.epicLikes.forEach((key, value) {
            if (value)
              eLikes2 = eLikes2 + 1;
          });

          var likes1 = max(aLikes1, eLikes1);
          var likes2 = max(aLikes2, eLikes2);

          return likes1.compareTo(likes2);
        });
        break;
    }

    for (var image in imageModels) {
      imageViews.add(ImageView.fromPost(image, userFromDb, feedType));
    }

    return imageViews;
  }

  @override
  bool get wantKeepAlive => true;
}

// ignore: must_be_immutable
class ActivityFeedItem extends StatelessWidget {
  final String username;
  final String
  userId;
  final String mediaUrl;
  final String mediaId;

  ActivityFeedItem({this.username, this.userId, this.mediaUrl, this.mediaId});

  factory ActivityFeedItem.fromPost(ImageModel imageModel, UserModel user) {
    return ActivityFeedItem(
      username: user.username,
      userId: user.id,
      mediaUrl: imageModel.imageUrl,
      mediaId: imageModel.id,
    );
  }

  Widget mediaPreview = Container();
  String actionText = "actionText";

  String getLabel() {

  }
  void configureItem(BuildContext context) {
    mediaPreview = GestureDetector(
      child: Container(
        height: 45.0,
        width: 45.0,
        child: AspectRatio(
          aspectRatio: 487 / 451,
          child: Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
                  image: NetworkImage(mediaUrl),
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Epic or Aesthetic',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Image.network(mediaUrl),
    );
  }
}

enum FeedType {
  Epic,
  Aesthetic,
  All
}
