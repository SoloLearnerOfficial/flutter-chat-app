import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Pages/HomePage.dart';
import 'package:flutter_chatapp/Pages/LoginPage.dart';
import 'package:flutter_chatapp/Pages/UsersChatPage.dart';
import '../Pages/SignUpPage.dart';

class NavigationService {
  late GlobalKey<NavigatorState> _navigatorService;

  final Map<String, Widget Function(BuildContext)> _route = {
    '/LoginPage': (context) => const LoginPage(),
    '/SignUpPage': (context) => const SignUpPage(),
    '/HomePage': (context) => const HomePage(),
  };

  Map<String, Widget Function(BuildContext)> get route {
    return _route;
  }

  GlobalKey<NavigatorState>? get navigatorService {
    return _navigatorService;
  }

  NavigationService() {
    _navigatorService = GlobalKey<NavigatorState>();
  }

  void push(Route route) {
    _navigatorService.currentState!.push(route);
  }

  void pushNamed(String route) {
    _navigatorService.currentState?.pushNamed(route);
  }

  void pushReplacementNamed(String route) {
    _navigatorService.currentState?.pushReplacementNamed(route);
  }

  void goBack() {
    _navigatorService.currentState?.pop();
  }
}
