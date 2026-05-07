import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Pages/LoginPage.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import 'Utils.dart';

void main() async {
  await setUp();
  runApp(MyApp());
}

Future<void> setUp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registerServices();
}

class MyApp extends StatelessWidget {
  late NavigationService _navigationService;
  late AuthService _authService;
  GetIt getIt = GetIt.instance;

  MyApp() {
    _navigationService = getIt.get<NavigationService>();
    _authService = getIt.get<AuthService>();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigationService.navigatorService,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: GoogleFonts.montaguSlabTextTheme()),
      home: const LoginPage(),
      initialRoute: _authService.user != null ? '/HomePage' : '/LoginPage',
      routes: _navigationService.route,
    );
  }
}
