import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:epic_aesthetic/views/image_view.dart';
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
                color: Colors.black,
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
              title: Text('Edit Profile',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white,
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
              width: 250.0,
              height: 27.0,
            )),
      );
    }

    Container buildProfileFollowButton() {
      // viewing your own profile - should show edit button
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
          return Colors.blueAccent;
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
        List<ImageView> posts = [];
        var snap = await FirebaseFirestore.instance
            .collection('posts')
        // .orderBy("timeStamp")
            .where('userId', isEqualTo: profileId)
            .get();
        for (var doc in snap.docs) {
          posts.add(ImageView.fromDocument(doc));
        }
        setState(() {
          imageCount = snap.docs.length;
        });

        return posts.reversed.toList();
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
                actions: <Widget>[
                  Padding(
                      padding: EdgeInsets.only(right: 20.0),
                      child: GestureDetector(
                        onTap: logout,
                        child: Icon(
                          Icons.logout,
                          color: Colors.black,
                        ),
                      )
                  ),
                  // Padding(
                  //     padding: EdgeInsets.only(right: 20.0),
                  //     child: GestureDetector(
                  //       onTap: () {},
                  //       child: Icon(
                  //           Icons.more_vert
                  //       ),
                  //     )
                  // ),
                ],
                // title: Text(
                //   user.name,
                //   style: const TextStyle(color: Colors.black),
                // ),
                // leading: IconButton(
                //     icon: Icon(Icons.logout, color: Colors.black),
                //     onPressed: logout),

                backgroundColor: Colors.white,
              ),
              body: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 40.0,
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(user.profileImageUrl),
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
                                      buildStatColumn("posts", imageCount),
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
                        Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Text(
                              user.firstName,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        // Container(
                        //   alignment: Alignment.centerLeft,
                        //   padding: const EdgeInsets.only(top: 1.0),
                        //   child: Text(user.bio),
                        // ),
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

  // ensures state is kept when switching pages
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

void openProfile(BuildContext context, String userId) {
  Navigator.of(context)
      .push(MaterialPageRoute<bool>(builder: (BuildContext context) {
    return ProfilePage(userId: userId);
  }));
}
