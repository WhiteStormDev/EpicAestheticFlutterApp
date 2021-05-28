import 'package:epic_aesthetic/shared/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'button_widget.dart';

class PleaseSignUpWidget extends StatelessWidget {
  const PleaseSignUpWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please login or sign up to see more",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
            SizedBox(
              height: 20,
            ),
            ButtonWidget(
              title: "Ok",
              hasBorder: false,
              onPress: () => goToLogin(context)
            ),
          ],
        ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.of(context).popAndPushNamed("/SignUp");
  }
}
