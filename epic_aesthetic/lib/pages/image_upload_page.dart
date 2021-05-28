import 'dart:io';

import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/widgets/button_widget.dart';
import 'package:epic_aesthetic/widgets/please_sign_up_widget.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ImageUploadPage extends StatefulWidget {
  ImageUploadPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ImageUploadPageState();
}

class ImageUploadPageState extends State<ImageUploadPage> {
  File file;
  ImagePicker imagePicker = ImagePicker();
  bool uploading = false;
  UserModel user;

  Widget build(BuildContext context) {
    user = Provider.of<UserModel>(context);
    if (user == null)
      return PleaseSignUpWidget();

    return file == null
        ? Padding(
      padding: const EdgeInsets.all(30.0),
      child: Scaffold(
        bottomSheet:  ButtonWidget(
            title: "Create image",
            hasBorder: false,
            onPress: () => _selectImage(context)
        ),
      )
    )
        : Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.white70,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: clearImage),
          title: const Text(
            'Post image',
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            FlatButton(
                onPressed: postImage,
                child: Text(
                  "Post",
                  style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0),
                ))
          ],
        ),
        body: ListView(
          children: <Widget>[
            PostForm(
              imageFile: file,
              loading: uploading,
            ),
            Divider()
          ],
        ));
  }

  _selectImage(BuildContext parentContext) async {
    return showDialog<Null>(
      context: parentContext,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: <Widget>[
            SimpleDialogOption(
                child: const Text('Take a photo'),
                onPressed: () async {
                  Navigator.pop(context);
                  PickedFile imageFile = await imagePicker.getImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1200,
                      imageQuality: 80);
                  setState(() {
                    file = File(imageFile.path);
                  });
                }),
            SimpleDialogOption(
                child: const Text('Choose from Gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  PickedFile imageFile = await imagePicker.getImage(
                      source: ImageSource.gallery,
                      maxWidth: 1920,
                      maxHeight: 1200,
                      imageQuality: 80);
                  setState(() {
                    file = File(imageFile.path);
                  });
                }),
            SimpleDialogOption(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  void postImage() {
    setState(() {
      uploading = true;
    });
    uploadImage(file).then((String data) {
      postToFireStore(data);
    }).then((_) {
      setState(() {
        file = null;
        uploading = false;
      });
    });
  }

  void postToFireStore(String imageUrl) async {
    Map<String, bool> epicLikes = Map();
    Map<String, bool> aestheticLikes = Map();
    epicLikes.putIfAbsent(user.id, () => false);
    aestheticLikes.putIfAbsent(user.id, () => false);
    DatabaseService().createImage(ImageModel.fromParameters(
        Uuid().v1(),
        imageUrl,
        user.id,
        epicLikes,
        aestheticLikes,
        DateTime.now()));
  }

  void clearImage() {
    setState(() {
      file = null;
    });
  }

  Future<String> uploadImage(var imageFile) async {
    var id = Uuid().v1();
    Reference ref = FirebaseStorage.instance.ref().child("post_$id.jpg");
    UploadTask uploadTask = ref.putFile(imageFile);
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    return downloadUrl;
  }
}

class PostForm extends StatelessWidget {
  final imageFile;
  final bool loading;

  PostForm({this.imageFile, this.loading});

  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        loading
            ? LinearProgressIndicator()
            : Padding(padding: EdgeInsets.only(top: 0.0)),
        Divider(),
        Container(
            height: 360,
            width: 360,
            decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.fill,
                  alignment: FractionalOffset.topCenter,
                  image: FileImage(imageFile),
                ))
        ),
        Divider()
      ],
    );
  }
}
