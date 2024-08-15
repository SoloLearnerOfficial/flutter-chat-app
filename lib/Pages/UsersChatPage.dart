import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Models/Chat.dart';
import 'package:flutter_chatapp/Models/UserProfile.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/DataBaseService.dart';
import 'package:flutter_chatapp/Services/MediaService.dart';
import 'package:flutter_chatapp/Services/StorageService.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';

import '../Models/Message.dart';

class UsersChatPage extends StatefulWidget {
  UserProfile userProfile;
  UsersChatPage({required this.userProfile});

  @override
  State<UsersChatPage> createState() => _UsersChatPageState();
}

class _UsersChatPageState extends State<UsersChatPage> {
  final GetIt _getIt = GetIt.instance;
  late AuthService _authService;
  late StorageService _storageService;
  late MediaService _mediaService;
  late DataBaseService _dataBaseService;
  ChatUser? currentUser, otherUser;
  @override
  void initState() {
    super.initState();
    _authService = _getIt.get<AuthService>();
    _dataBaseService = _getIt.get<DataBaseService>();
    _mediaService = _getIt.get<MediaService>();
    _storageService = _getIt.get<StorageService>();
    currentUser = ChatUser(
        id: _authService.user!.uid, firstName: _authService.user!.displayName);
    otherUser = ChatUser(
        id: widget.userProfile.uid!,
        firstName: widget.userProfile.name,
        profileImage: widget.userProfile.pfpUrl);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.only(right: size.width * 0.02),
              child: CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.userProfile.pfpUrl!,
                ),
              ),
            ),
            Text(widget.userProfile.name!)
          ],
        ),
      ),
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return StreamBuilder(
        stream: _dataBaseService.getUsersChat(
            _authService.user!.uid!, widget.userProfile.uid!),
        builder: (ctx, snapshots) {
          Chat? chat = snapshots?.data?.data();
          List<ChatMessage> chatMessages = [];
          if (chat != null && chat.messages != null) {
            chatMessages = getUsersChatMessage(chat.messages!);
          }
          return DashChat(
              messageOptions: const MessageOptions(
                showOtherUsersAvatar: true,
                showTime: true,
              ),
              inputOptions: InputOptions(
                  alwaysShowSend: true,
                  autocorrect: true,
                  trailing: [_imageButton()]),
              messages: chatMessages,
              currentUser: currentUser!,
              onSend: _chatMessageSent);
        });
  }

  Widget _imageButton() {
    return IconButton(
        onPressed: () async {
          File? file = await _mediaService.pickImage();
          if (file != null) {
            String? uploadedImageUrl = await _storageService.uploadUserImage(
                file, _authService.user!.uid, widget.userProfile.uid!);
            if (uploadedImageUrl != null) {
              ChatMessage chatMessage = ChatMessage(
                  user: currentUser!,
                  createdAt: DateTime.now(),
                  medias: [
                    ChatMedia(
                        url: uploadedImageUrl,
                        fileName: '',
                        type: MediaType.image)
                  ]);
              await _chatMessageSent(chatMessage);
            }
          }
        },
        icon: const Icon(
          Icons.image,
          color: Colors.blueAccent,
        ));
  }

  Future<void> _chatMessageSent(ChatMessage chatmessage) async {
    if (chatmessage.medias?.isNotEmpty ?? false) {
      if (chatmessage.medias!.first.type.toString() ==
          MessageType.image.name.toString()) {
        Message message = Message(
            senderID: _authService.user!.uid!,
            content: chatmessage.medias!.first.url,
            messageType: MessageType.image,
            sentAt: Timestamp.fromDate(chatmessage.createdAt));
        await _dataBaseService.sendChatMessage(
            _authService.user!.uid!, widget.userProfile.uid!, message);
      }
    } else {
      Message message = Message(
          senderID: _authService.user!.uid!,
          content: chatmessage.text,
          messageType: MessageType.Text,
          sentAt: Timestamp.fromDate(chatmessage.createdAt));
      await _dataBaseService.sendChatMessage(
          _authService.user!.uid!, widget.userProfile.uid!, message);
    }
  }

  List<ChatMessage> getUsersChatMessage(List<Message> messages) {
    List<ChatMessage> userChatMessage = messages.map((userMessage) {
      if (userMessage.messageType!.name.toString() ==
          MessageType.image.name.toString()) {
        return ChatMessage(
            user: userMessage.senderID == currentUser!.id
                ? currentUser!
                : otherUser!,
            createdAt: userMessage.sentAt!.toDate(),
            medias: [
              ChatMedia(
                  url: userMessage.content!,
                  fileName: '',
                  type: MediaType.image)
            ]);
      } else {
        return ChatMessage(
            user: userMessage.senderID == currentUser!.id
                ? currentUser!
                : otherUser!,
            createdAt: userMessage.sentAt!.toDate(),
            text: userMessage.content!);
      }
    }).toList();
    userChatMessage.sort((firstMessage, nextMessage) {
      return nextMessage.createdAt.compareTo(firstMessage.createdAt);
    });
    return userChatMessage;
  }
}
