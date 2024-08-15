import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_chatapp/Services/AlertService.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/DataBaseService.dart';
import 'package:flutter_chatapp/Services/MediaService.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:flutter_chatapp/Services/StorageService.dart';
import 'package:flutter_chatapp/firebase_options.dart';
import 'package:get_it/get_it.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerServices() async {
  GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DataBaseService>(DataBaseService());
  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
}

String generateChatId(String uid1, String uid2) {
  List chat = [uid1, uid2];
  chat.sort();
  return chat.fold(
      "", (previousValue, nextValue) => '$previousValue$nextValue');
}
