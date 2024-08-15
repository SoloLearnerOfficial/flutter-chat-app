import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user;

  User? get _user {
    return user;
  }

  AuthService() {
    _firebaseAuth.authStateChanges().listen(authStateChange);
  }

  Future<bool> createUserCredential(String email, String password) async {
    try {
      var _userCredentials = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (_userCredentials.user != null) {
        user = _userCredentials.user;
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> registerUserCredential(String email, String password) async {
    try {
      var credential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (credential.user != null) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<bool> logOut() async {
    try {
      var logOut = await _firebaseAuth.signOut();
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void authStateChange(User? users) {
    if (users != null) {
      user = users;
    } else {
      user = null;
    }
  }
}
