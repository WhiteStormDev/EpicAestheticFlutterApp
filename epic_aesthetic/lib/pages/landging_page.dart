import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/all_feed_page.dart';
import 'package:epic_aesthetic/pages/onboarding_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'login_page.dart';

class LandingPage extends StatelessWidget {
  LandingPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final UserModel user = Provider.of<UserModel>(context);
    final bool _isLogged = user != null;

    return _isLogged ? AllFeedPage() : OnBoardingPage();
  }
}