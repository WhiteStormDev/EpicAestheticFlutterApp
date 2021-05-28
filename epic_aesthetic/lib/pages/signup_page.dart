import 'package:epic_aesthetic/models/user_model.dart';
import 'package:epic_aesthetic/pages/main_page.dart';
import 'package:epic_aesthetic/services/authentication_service.dart';
import 'package:epic_aesthetic/services/database_service.dart';
import 'package:epic_aesthetic/shared/globals.dart';
import 'package:epic_aesthetic/view_models/singup_view_model.dart';
import 'package:epic_aesthetic/widgets/button_widget.dart';
import 'package:epic_aesthetic/widgets/textfield_widget.dart';
import 'package:epic_aesthetic/widgets/wave_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();
  var _usernameController = TextEditingController();

  String _email;
  String _password;
  String _username;
  bool _isLogin = false;
  bool _newUser = false;

  var _authenticationService = new AuthenticationService();

  @override
  Widget build(BuildContext context) {
      var user = Provider.of<UserModel>(context);
      final size = MediaQuery.of(context).size;
      final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
      final model = new SignUpViewModel();

      return user != null ? onMainPageWidget(user) :
        Scaffold(
        backgroundColor: Global.white,
        body: Stack(
          children: <Widget>[
            Container(
              height: size.height,
              color: Global.purple,
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
                    _isLogin ? "Login" : "Sign Up",
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
                  if (!_isLogin)
                    TextFieldWidget(
                      viewModel: model,
                      controller: _usernameController,
                      hintText: 'Username',
                      obscureText: false,
                      prefixIconData: Icons.account_box_outlined,
                    ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFieldWidget(
                    viewModel: model,
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                    prefixIconData: Icons.mail_outline,
                    suffixIconData: model.isValidEMail ? Icons.check : null,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      TextFieldWidget(
                        viewModel: model,
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: model.isVisible ? false : true,
                        prefixIconData: Icons.lock_outline,
                        // suffixIconData: model.isVisible
                        //     ? Icons.visibility
                        //     : Icons.visibility_off,
                        onChanged: (value) {
                          _passwordController.value = value;
                        },
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      InkWell(
                        onTap: mainPage,
                        child: Text(
                          'Continue without signing',
                          style: TextStyle(
                            color: Global.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ButtonWidget(
                    title: _isLogin ? "Login" : "Sign Up",
                    hasBorder: false,
                    onPress: () {
                      if (_isLogin)
                        _loginUser();
                      else
                        _signUpUser();
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ButtonWidget(
                    title: _isLogin ? "Create account" : "Already have an account",
                    hasBorder: false,
                    onPress: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }

    mainPage (){
      Navigator.of(context).popAndPushNamed("/MainPage");
    }

    Widget onMainPageWidget(UserModel user) {
      if (_newUser) {
        user.username = _username;
        DatabaseService().createUser(user);
        _usernameController.clear();
      }
      return MainPage();
    }

  void _loginUser() async {
    _email = _emailController.text;
    _password = _passwordController.text;
    _newUser = false;

    if(_email.isEmpty || _password.isEmpty){
      _showToast("Please fill all fields");
      return;
    }

    UserModel user = await _authenticationService.loginByEmailAndPassword(_email.trim(), _password.trim());
    if(user == null){
      _showToast("Invalid email or password");
    }
    else {
      _emailController.clear();
      _passwordController.clear();
    }
  }

  void _signUpUser() async {
    _email = _emailController.text;
    _password = _passwordController.text;
    _username = _usernameController.text;
    _newUser = true;

    if (_email.isEmpty || _password.isEmpty || _username.isEmpty) {
      _showToast("Please fill all fields");
      return;
    }

    UserModel user = await _authenticationService.signUpByEmailAndPassword(
        _email.trim(), _password.trim());

    if (user == null) {
      _showToast("Invalid email or password");
      return;
    }

    _emailController.clear();
    _passwordController.clear();

  }

  void _showToast(String text) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
          duration: Duration(milliseconds: 450),
          content: Text(text)
      ),
    );
  }
}
