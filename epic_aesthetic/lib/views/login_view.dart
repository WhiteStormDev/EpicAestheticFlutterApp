import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/view_models/login_view_model.dart';
import 'package:epic_aesthetic/widgets/button_widget.dart';
import 'package:epic_aesthetic/widgets/textfield_widget.dart';
import 'package:epic_aesthetic/widgets/wave_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  LoginView({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => LoginViewState();
}

class LoginViewState extends State<LoginView> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _firstnameController = TextEditingController();
  var _lastnameController = TextEditingController();

  String _email;
  String _password;
  String _firstName;
  String _lastName;

  bool showLogin = true;
  var _authenticationService = new AuthenticationService();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final model = Provider.of<LoginViewModel>(context);

    Widget _signForm(String label, void onPress()){
      return Scaffold(
        backgroundColor: Global.white,
        body: Stack(
          children: <Widget>[
            Container(
              height: size.height,
              color: Global.mediumBlue,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeOutQuad,
              top: keyboardOpen ? -size.height / 3.7 : 0.0,
              child: WaveWidget(
                size: size,
                yOffset: size.height / 3.0,
                color: Global.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 100.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    label,
                    style: TextStyle(
                      color: Global.white,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextFieldWidget(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                    prefixIconData: Icons.mail_outline,
                    suffixIconData: model.isValid ? Icons.check : null,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextFieldWidget(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: model.isVisible ? false : true,
                        prefixIconData: Icons.lock_outline,
                        suffixIconData: model.isVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        onChanged: (value) {
                          _passwordController.value = value;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Global.mediumBlue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ButtonWidget(
                    title: label,
                    hasBorder: false,
                    onPress: () => onPress(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          (
              showLogin
                  ?
              Column(
                children: <Widget>[
                  _signForm("Login", _loginUser),
                  // Padding(
                  //   padding: EdgeInsets.only(top: 10),
                  //   child: GestureDetector(
                  //     child: Text("Don't have an account? Sign up.", style: TextStyle(fontSize: 20, color: Colors.black),),
                  //     onTap:() {
                  //       setState((){
                  //         showLogin = false;
                  //       });
                  //     },
                  //   ),
                  // )
                ],
              )
                  :
              Column(
                children: <Widget>[
                  _signForm("Sign up", _signUpUser),
                  // Padding(
                  //   padding: EdgeInsets.all(10),EdgeInsets.only(top: 10),
                  //   child: GestureDetector(
                  //     child: Text("Already have an account? Login.", style: TextStyle(fontSize: 20, color: Colors.black),),
                  //     onTap:() {
                  //       setState((){
                  //         showLogin = true;
                  //       });
                  //     },
                  //   ),
                  // )
                ],
              )
          )
        ],
      ),
    );

  }

  void _loginUser() async {
    _email = _emailController.text;
    _password = _passwordController.text;

    if(_email.isEmpty || _password.isEmpty){
      return;
    }

    UserModel user = await _authenticationService.signInWithEmailAndPassword(_email.trim(), _password.trim());
    if(user == null){
      Fluttertoast.showToast(
          msg: "Can't sign in. Invalid email or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  void _signUpUser() async {
    _email = _emailController.text;
    _password = _passwordController.text;
    _firstName = _firstnameController.text;
    _lastName = _lastnameController.text;
    if(_email.isEmpty || _password.isEmpty || _firstName.isEmpty || _lastName.isEmpty) {
      Fluttertoast.showToast(
          msg: "Can't sign up. Please fill all fields",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }

    UserModel user = await _authenticationService.signUpWithEmailAndPassword(_email.trim(), _password.trim());

    if(user == null){
      Fluttertoast.showToast(
          msg: "Can't sign up. Invalid email or password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    else {
      _emailController.clear();
      _passwordController.clear();
    }

    user.firstName = _firstName;
    user.lastName = _lastName;

    DatabaseService().createUser(user);
  }
}