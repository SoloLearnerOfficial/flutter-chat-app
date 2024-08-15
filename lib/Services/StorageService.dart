import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_chatapp/Utils.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _firebaseStroage = FirebaseStorage.instance;
  StorageService() {}

  Future<String?> uploadUserProfile(File file, String uid) async {
    try {
      Reference userProfile = _firebaseStroage
          .ref('Users/Images')
          .child('$uid${path.extension(file.path)}');
      UploadTask uploadImage = userProfile.putFile(file);
      return uploadImage.then((p) {
        if (p.state == TaskState.success) {
          return userProfile.getDownloadURL();
        }
      });
    } catch (e) {
      print(e);
    }
    return '';
  }

  Future<String?> uploadUserImage(File file, String uid1, String uid2) async {
    try {
      String uniqueUserID = generateChatId(uid1, uid2);
      Reference userChatImages = _firebaseStroage
          .ref('Chats/$uniqueUserID')
          .child('${DateTime.now()}${path.extension(file.path)}');
      UploadTask uploadTask = userChatImages.putFile(file);
      return uploadTask.then((uploadState) {
        if (uploadState.state == TaskState.success) {
          return userChatImages.getDownloadURL();
        }
      });
    } on FirebaseException catch (e) {
      print(e);
    }
    return null;
  }
}
