import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:epic_aesthetic/models/image_model.dart';
import 'package:epic_aesthetic/models/user_model.dart';

class DatabaseService
{
  final userCollectionReference =
  FirebaseFirestore.instance.collection('users');
  final imageCollectionReference =
  FirebaseFirestore.instance.collection('images');

  Future createUser(UserModel user) async {
    user.profileImageUrl = "https://firebasestorage.googleapis.com/v0/b/epicaesthetic-744a7.appspot.com/o/2803918820.jpg?alt=media&token=38a69122-aa55-4d5b-9e02-ec5b80be4fdc";
    return await userCollectionReference
        .doc(user.id)
        .set(user.toMap());
  }

  Future createImage(ImageModel image) async {
    return await imageCollectionReference
        .doc(image.id)
        .set(image.toMap());
  }

  Future<UserModel> getUser(String id) async {
    UserModel userFromDB;
    var snapshot = await userCollectionReference.doc(id).get();
    userFromDB = UserModel.fromJson(snapshot.data());
    return userFromDB;
  }

  Future<List<ImageModel>> getTopAestheticImagesByMonth() async {
    QuerySnapshot snapshot = await imageCollectionReference.orderBy("aesthetic").get();
    return snapshot.docs
        .map((doc) => ImageModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<List<ImageModel>> getTopEpicImagesByMonth() async {
    QuerySnapshot snapshot = await imageCollectionReference.orderBy("epic").get();
    return snapshot.docs
        .map((doc) => ImageModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<List<ImageModel>> getTopEpicAestheticImages() async {
    QuerySnapshot snapshot = await imageCollectionReference.orderBy("epic").orderBy("aesthetic").get();
    return snapshot.docs
        .map((doc) => ImageModel.fromJson(doc.id, doc.data()))
        .toList();
  }

  Future<List<ImageModel>> getImages() async {
    QuerySnapshot snapshot = await imageCollectionReference.orderBy("dateTime").get();
    return snapshot.docs
        .map((doc) => ImageModel.fromJson(doc.id, doc.data()))
        .toList();
  }
}