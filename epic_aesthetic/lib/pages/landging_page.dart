import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/main_page.dart';
import 'package:epic_aesthetic/pages/onboarding_page.dart';
import 'package:epic_aesthetic/pages/signup_page.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);
    final bool _isLogged = user != null;
    return _isLogged ? MainPage() : SignUpPage();
  }
}