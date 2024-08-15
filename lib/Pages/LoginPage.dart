import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Consts.dart';
import 'package:flutter_chatapp/Services/AlertService.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:flutter_chatapp/Widgets/CommonTextField.dart';
import 'package:get_it/get_it.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _key = GlobalKey();
  String email = '', password = '';
  GetIt getIt = GetIt.instance;
  late AuthService _authService;
  late NavigationService _navigationService;
  late AlertService _alertService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _buildUI(size),
    );
  }

  Widget _buildUI(Size size) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HI, Welcome Back!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Hell again, you\'ve been missed',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            _loginForm(size),
            _loginButton(size),
            _createAccountLink(size)
          ],
        ),
      ),
    );
  }

  Widget _loginForm(Size size) {
    return Container(
      height: size.width * 0.75,
      margin: EdgeInsets.symmetric(vertical: size.width * 0.04),
      child: Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonTextField(
                hintText: 'Email',
                size: size,
                validationRegExp: EMAIL_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    email = value!;
                  });
                },
              ),
              CommonTextField(
                hintText: 'Password',
                size: size,
                validationRegExp: PASSWORD_VALIDATION_REGEX,
                isObscureText: true,
                onSaved: (value) {
                  setState(() {
                    password = value!;
                  });
                },
              ),
            ],
          )),
    );
  }

  Widget _loginButton(Size size) {
    return GestureDetector(
        onTap: () async {
          try {
            if (_key.currentState?.validate() ?? false) {
              _key.currentState?.save();
              bool isLoggedIn =
                  await _authService.createUserCredential(email, password);
              if (isLoggedIn) {
                _alertService.showToastMessage('Successfully Logged In');
                _navigationService.pushReplacementNamed('/HomePage');
              } else {
                _alertService.showToastMessage('Failed to Login',
                    icon: const Icon(Icons.error, color: Colors.red));
              }
            }
          } catch (e) {
            _alertService.showToastMessage('Failed to Login',
                icon: const Icon(Icons.error, color: Colors.red));
          }
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: size.width * 0.03),
          color: Theme.of(context).primaryColor,
          child: const Center(
            child: Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ));
  }

  Widget _createAccountLink(Size size) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text('Don\'t have an account? '),
          GestureDetector(
            onTap: () {
              _navigationService.pushReplacementNamed('/SignUpPage');
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
