import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/photo_tape_page.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/views/image_view.dart';
import 'package:epic_aesthetic/widgets/please_sign_up_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({this.userId});

  final String userId;

  _ProfilePage createState() => _ProfilePage(this.userId);
}

class _ProfilePage extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  String profileId;
  String currentUserId;
  String view = "grid";
  int imageCount = 0;
  UserModel userModel;

  _ProfilePage(this.profileId);

  editProfile() {
    var editPage = EditProfilePage();

    Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return Center(
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                color: Global.white,
                onPressed: () {
                  Navigator.of(context).popAndPushNamed("/SignUp");
                },
              ),
              title: Text('Edit Profile',
                  style: TextStyle(
                      color: Global.white, fontWeight: FontWeight.bold)),
              backgroundColor: Global.purple,
              actions: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.check,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      editPage.applyChanges();
                      Navigator.maybePop(context);
                    })
              ],
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: editPage,
                ),
              ],
            )),
      );
    }));
  }

  void logout() async {

    await AuthenticationService().logout();
  }

  @override
  Widget build(BuildContext context) {
    userModel = Provider.of<UserModel>(context);
    if (userModel == null)
      return PleaseSignUpWidget();

    currentUserId = userModel.id;
    profileId = userModel.id;
    super.build(context); // reloads state when opened again

    Column buildStatColumn(String label, int number) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            number.toString(),
            style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
          ),
          Container(
              margin: const EdgeInsets.only(top: 4.0),
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400),
              ))
        ],
      );
    }

    Container buildFollowButton(
        {String text,
          Color backgroundcolor,
          Color textColor,
          Color borderColor,
          Function function}) {
      return Container(
        padding: EdgeInsets.only(top: 2.0),
        child: FlatButton(
            onPressed: function,
            child: Container(
              decoration: BoxDecoration(
                  color: backgroundcolor,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(5.0)),
              alignment: Alignment.center,
              child: Text(text,
                  style:
                  TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              width: 220.0,
              height: 27.0,
            )),
      );
    }

    Container buildProfileFollowButton() {
      if (currentUserId == profileId) {
        return buildFollowButton(
          text: "Edit Profile",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey,
          function: editProfile,
        );
      }
      return buildFollowButton(
          text: "loading...",
          backgroundcolor: Colors.white,
          textColor: Colors.black,
          borderColor: Colors.grey);
    }

    Row buildImageViewButtonBar() {
      Color isActiveButtonColor(String viewName) {
        if (view == viewName) {
          return Global.purple;
        } else {
          return Colors.black26;
        }
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.grid_on, color: isActiveButtonColor("grid")),
            onPressed: () {
              changeView("grid");
            },
          ),
          IconButton(
            icon: Icon(Icons.list, color: isActiveButtonColor("feed")),
            onPressed: () {
              changeView("feed");
            },
          ),
        ],
      );
    }

    Container buildUserPosts() {
      Future<List<ImageView>> getPosts() async {
        List<ImageView> images = [];
        var snap = await FirebaseFirestore.instance
            .collection('images')
            .where('userId', isEqualTo: profileId)
            .get();
        for (var doc in snap.docs) {
          images.add(ImageView.fromDocument(doc, FeedType.All));
        }
        setState(() {
          imageCount = snap.docs.length;
        });

        return images.reversed.toList();
      }

      return Container(
          child: FutureBuilder<List<ImageView>>(
            future: getPosts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                    alignment: FractionalOffset.center,
                    padding: const EdgeInsets.only(top: 10.0),
                    child: CircularProgressIndicator());
              else if (view == "grid") {
                // build the grid
                return GridView.count(
                    crossAxisCount: 3,
                    childAspectRatio: 1.0,
//                    padding: const EdgeInsets.all(0.5),
                    mainAxisSpacing: 1.5,
                    crossAxisSpacing: 1.5,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: snapshot.data.map((ImageView imageView) {
                      return GridTile(child: ImageTile(imageView));
                    }).toList());
              } else if (view == "feed") {
                return Column(
                    children: snapshot.data.map((ImageView imageView) {
                      return imageView;
                    }).toList());
              }
            },
          ));
    }

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(profileId.trim())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Container(
                alignment: FractionalOffset.center,
                child: CircularProgressIndicator());

          var user = UserModel.fromDocument(snapshot.data);

          return Scaffold(
              appBar: AppBar(
                  backgroundColor: Global.purple,
                  actions: <Widget>[
                    Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child:
                          Container(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: logout,
                              child: Icon(
                                Icons.logout,
                                color: Global.white,
                              ),
                            )
                          )
                    )
                  ]
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(top: 15.0, left: 15.0),
                      child: Text(
                        user.username,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Column(
                              children: [
                                CircleAvatar(
                                  backgroundImage: NetworkImage(user.profileImageUrl),
                                  radius: 40.0,
                                  backgroundColor: Colors.grey,
                                ),
                              ],
                            ),
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      buildStatColumn("images", imageCount),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        buildProfileFollowButton()
                                      ]),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  buildImageViewButtonBar(),
                  Divider(height: 0.0),
                  buildUserPosts(),
                ],
              ));
        });
  }

  changeView(String viewName) {
    setState(() {
      view = viewName;
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class ImageTile extends StatelessWidget {
  final ImageView imageView;

  ImageTile(this.imageView);

  clickedImage(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
      return Center(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Photo',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
            ),
            body: ListView(
              children: <Widget>[
                Container(
                  child: imageView,
                ),
              ],
            )),
      );
    }));
  }

  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => clickedImage(context),
        child: Image.network(imageView.imageUrl, fit: BoxFit.cover));
  }
}
