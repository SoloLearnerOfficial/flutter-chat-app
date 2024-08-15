import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chatapp/Models/Chat.dart';
import 'package:flutter_chatapp/Models/Message.dart';
import 'package:flutter_chatapp/Models/UserProfile.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Utils.dart';
import 'package:get_it/get_it.dart';

class DataBaseService {
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  CollectionReference? _userCollection, _chatCollection;
  DataBaseService() {
    setUpUserCollection();
  }

  void setUpUserCollection() {
    _userCollection = _fireStore.collection('Users').withConverter<UserProfile>(
        fromFirestore: (data, _) => UserProfile.fromJson(data.data()!),
        toFirestore: (userProfile, _) => userProfile.toJson());
    _authService = _getIt.get<AuthService>();

    _chatCollection = _fireStore.collection('Chats').withConverter<Chat>(
        fromFirestore: (data, _) => Chat.fromJson(data.data()!),
        toFirestore: (chat, _) => chat.toJson());
  }

  Future<void> createUserProfile(UserProfile userProfile) async {
    try {
      await _userCollection!.doc(userProfile.uid!).set(userProfile);
    } catch (e) {
      print(e);
    }
  }

  //get number of user list app
  Stream<QuerySnapshot<UserProfile>> getOtherRegisteredUser() {
    return _userCollection!
        .where('uid', isNotEqualTo: _authService.user!.uid)
        .snapshots() as Stream<QuerySnapshot<UserProfile>>;
  }

  Future<bool> checkChatExist(String uid1, String uid2) async {
    String uniqueChatId = generateChatId(uid1, uid2);
    var usersChatExists = await _chatCollection!.doc(uniqueChatId).get();
    if (usersChatExists != null) {
      return usersChatExists.exists;
    }
    return false;
  }

  Future<void> createUserChat(String uid1, String uid2) async {
    String userUniqueChatID = generateChatId(uid1, uid2);
    Chat chat = Chat(id: uid1, participants: [uid1, uid2], messages: []);
    var usersChat = await _chatCollection!.doc(userUniqueChatID).set(chat);
    return usersChat;
  }

  Future<void> sendChatMessage(
      String uid1, String uid2, Message message) async {
    try {
      String userUniqueChatId = generateChatId(uid1, uid2);
      var usersChatDetails = _chatCollection?.doc(userUniqueChatId);
      await usersChatDetails?.update({
        'messages': FieldValue.arrayUnion([message.toJson()])
      });
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }

  Stream<DocumentSnapshot<Chat>> getUsersChat(String uid1, String uid2) {
    String userUniqueChatId = generateChatId(uid1, uid2);
    return _chatCollection?.doc(userUniqueChatId).snapshots()
        as Stream<DocumentSnapshot<Chat>>;
  }
}
