import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Consts.dart';
import 'package:flutter_chatapp/Models/UserProfile.dart';
import 'package:flutter_chatapp/Services/AlertService.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/DataBaseService.dart';
import 'package:flutter_chatapp/Services/MediaService.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:flutter_chatapp/Services/StorageService.dart';
import 'package:get_it/get_it.dart';

import '../Widgets/CommonTextField.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GetIt _getIt = GetIt.instance;
  late NavigationService _navigationService;
  late MediaService _mediaService;
  late AuthService _authService;
  late StorageService _storageService;
  late DataBaseService _dataBaseService;
  late AlertService _alertService;
  File? _selectedImage;
  final GlobalKey<FormState> _key = GlobalKey();
  String name = '', email = '', password = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _navigationService = _getIt.get<NavigationService>();
    _mediaService = _getIt.get<MediaService>();
    _authService = _getIt.get<AuthService>();
    _storageService = _getIt.get<StorageService>();
    _dataBaseService = _getIt.get<DataBaseService>();
    _alertService = _getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: !isLoading
          ? _buildUI(size)
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildUI(Size size) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(size.width * 0.04),
        child: SingleChildScrollView(
          child: SizedBox(
            height: size.height,
            width: size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Let \'s get going!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const Text(
                  'Register an account using the form below',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
                _profileImage(size),
                _loginForm(size),
                _loginButton(size),
                _createAccountLink(size)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _profileImage(Size size) {
    return Padding(
      padding: EdgeInsets.only(top: size.width * 0.1),
      child: Center(
        child: GestureDetector(
          onTap: () async {
            File? image = await _mediaService.pickImage();
            setState(() {
              _selectedImage = image;
            });
          },
          child: CircleAvatar(
            radius: size.width * 0.15,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : NetworkImage(PLACEHOLDER_PFP) as ImageProvider,
          ),
        ),
      ),
    );
  }

  Widget _loginForm(Size size) {
    return SizedBox(
      height: size.width * 0.9,
      child: Form(
          key: _key,
          autovalidateMode: AutovalidateMode.always,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CommonTextField(
                hintText: 'Name',
                size: size,
                validationRegExp: NAME_VALIDATION_REGEX,
                onSaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
              ),
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
            if ((_key.currentState?.validate() ?? false) &&
                _selectedImage != null) {
              _key.currentState?.save();
              setState(() {
                isLoading = true;
              });
              bool isCredentialCreated =
                  await _authService.registerUserCredential(email, password);
              if (isCredentialCreated) {
                String? url = await _storageService.uploadUserProfile(
                    _selectedImage!, _authService.user!.uid);
                if (url != null) {
                  setState(() {
                    isLoading = true;
                  });
                  await _dataBaseService.createUserProfile(UserProfile(
                      uid: _authService.user!.uid, name: name, pfpUrl: url));
                  _alertService
                      .showToastMessage('User registered successfully');
                  _navigationService.pushReplacementNamed('/LoginPage');
                } else {
                  _alertService.showToastMessage('Failed to Login',
                      icon: const Icon(Icons.error, color: Colors.red));
                }
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
              'Register',
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
          const Text('Already have an account? '),
          GestureDetector(
            onTap: () {
              _navigationService.pushReplacementNamed('/LoginPage');
            },
            child: const Text(
              'Login',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
