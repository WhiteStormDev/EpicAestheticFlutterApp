import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  String id;
  String username;
  String profileImageUrl;

  UserModel.fromFireBase(User user) {
    id = user.uid;

  }

  UserModel.fromJson(Map<String, dynamic> values) {
    if (values == null)
      return;

    id = values['id'];
    username = values['username'];
    profileImageUrl = values['profileImageUrl'];
  }

  UserModel.fromDocument(DocumentSnapshot documentSnapshot) {
    id = documentSnapshot['id'];
    username = documentSnapshot['username'];
    profileImageUrl = documentSnapshot['profileImageUrl'];
  }


  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "username": username,
      "profileImageUrl": profileImageUrl
    };
  }
}