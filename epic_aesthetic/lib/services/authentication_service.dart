import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService
{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<UserModel> get currentUser{
    return _firebaseAuth.authStateChanges().map((user) => user != null ? UserModel.fromFireBase(user) : null);
  }

  Future logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel> signUpByEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      var user = result.user;
      if (user == null)
        return null;

      DatabaseService().createUser(UserModel.fromFireBase(user));
      return UserModel.fromFireBase(user);
    } catch (e){
      print(e);
      return null;
    }
  }

  Future<UserModel> loginByEmailAndPassword(String email, String password) async {
    try{
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      var user = result.user;
      return DatabaseService().getUser(UserModel.fromFireBase(user).id);
    } catch (e){
      print(e);
      return null;
    }
  }
}