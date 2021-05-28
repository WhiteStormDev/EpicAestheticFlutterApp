import 'package:epic_aesthetic/pages/image_upload_page.dart';
import 'package:epic_aesthetic/pages/landging_page.dart';
import 'package:epic_aesthetic/pages/main_page.dart';
import 'package:epic_aesthetic/pages/rate_page_fake.dart';
import 'package:epic_aesthetic/pages/signup_page.dart';
import 'package:epic_aesthetic/pages/splash_page.dart';
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
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel>.value(
      value: AuthenticationService().currentUser,
      child: MaterialApp(
        routes: <String, WidgetBuilder>
        {
          "/RatePageFake": (BuildContext context) => new RatePageFake(),
          "/SignUp": (BuildContext context) => new SignUpPage(),
          "/MainPage": (BuildContext context) => new MainPage(),
          "/AddImage": (BuildContext context) => new ImageUploadPage(),
          "/LandingPage": (BuildContext context) => new LandingPage(),
         },
        title: 'Epic or Aesthetic?',
        home: Splash(),
      ),

    );
  }

}