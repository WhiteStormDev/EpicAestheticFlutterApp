import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/views/image_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhotoTapePage extends StatefulWidget {
  PhotoTapePage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => PhotoTapePageState();
}

class PhotoTapePageState extends State<PhotoTapePage>
    with AutomaticKeepAliveClientMixin<PhotoTapePage> {
  UserModel user;
  List<ImageModel> posts;
  List<ImageView> feedData;

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
            icon: Icon(Icons.refresh, color: Colors.black),
            onPressed: _refresh),
        title: const Text('ARCHTR',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
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
    posts = await DatabaseService().getPosts();
    UserModel userFromDb = await DatabaseService().getUser(user.id);
    imageViews = _generateFeed(posts, userFromDb);
    setState(() {
      feedData = imageViews;
    });
  }

  List<ImageView> _generateFeed(List<ImageModel> imageModels, userFromDb) {
    List<ImageView> imageViews = [];

    for (var image in imageModels) {
      imageViews.add(ImageView.fromPost(image, userFromDb));
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
  userId; // types include liked photo, follow user, comment on photo
  final String mediaUrl;
  final String mediaId;

  ActivityFeedItem({this.username, this.userId, this.mediaUrl, this.mediaId});

  factory ActivityFeedItem.fromPost(ImageModel imageModel, UserModel user) {
    return ActivityFeedItem(
      username: user.firstName,
      userId: user.id,
      mediaUrl: imageModel.imageUrl,
      mediaId: imageModel.id,
    );
  }

  Widget mediaPreview = Container();
  String actionText = "actionText";

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

    // if (type == "like") {
    //   actionText = " liked your post.";
    // } else if (type == "follow") {
    //   actionText = " starting following you.";
    // } else if (type == "comment") {
    //   actionText = " commented: $commentData";
    // } else {
    //   actionText = "Error - invalid activityFeed type: $type";
    // }
  }

  @override
  Widget build(BuildContext context) {
    configureItem(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archtr',
            style: const TextStyle(
                fontFamily: "Billabong", color: Colors.black, fontSize: 35.0)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Image.network(mediaUrl),
      // mainAxisSize: MainAxisSize.max,
      // children: <Widget>[
      //   Expanded(
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: <Widget>[
      //         GestureDetector(
      //           child: Text(
      //             username,
      //             style: TextStyle(fontWeight: FontWeight.bold),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      //   Container(
      //     decoration: BoxDecoration(
      //         image: DecorationImage(
      //           fit: BoxFit.fill,
      //           alignment: FractionalOffset.topCenter,
      //           image: NetworkImage(mediaUrl),
      //         )),
      //   )
      // ],
    );
  }
}
