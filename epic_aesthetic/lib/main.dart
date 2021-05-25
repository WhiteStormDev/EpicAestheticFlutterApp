import 'package:epic_aesthetic/pages/landging_page.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // @override
  // Widget build(BuildContext context) {
  //   return ChangeNotifierProvider(
  //     create: (context) => LoginViewModel(),
  //     child: MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       home: LoginView(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthenticationService().currentUser,
      child: MaterialApp(
        title: 'Epic or Aesthetic?',
        home: LandingPage(),
      ),
    );
  }

}