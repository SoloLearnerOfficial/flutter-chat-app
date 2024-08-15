import 'package:flutter/material.dart';
import 'package:flutter_chatapp/Models/UserProfile.dart';
import 'package:flutter_chatapp/Pages/UsersChatPage.dart';
import 'package:flutter_chatapp/Services/AlertService.dart';
import 'package:flutter_chatapp/Services/AuthService.dart';
import 'package:flutter_chatapp/Services/DataBaseService.dart';
import 'package:flutter_chatapp/Services/NavigationService.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AuthService _authService;
  late DataBaseService _dataBaseService;
  late NavigationService _navigationService;
  late AlertService _alertService;
  GetIt getIt = GetIt.instance;
  @override
  void initState() {
    super.initState();
    _authService = getIt.get<AuthService>();
    _dataBaseService = getIt.get<DataBaseService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Messages'),
        actions: [
          IconButton(
              onPressed: () async {
                var isLoggedOut = await _authService.logOut();
                if (isLoggedOut) {
                  _alertService.showToastMessage('Successfully Logged Out');
                  _navigationService.pushReplacementNamed('/LoginPage');
                } else {
                  _alertService.showToastMessage('Failed Logged Out',
                      icon: const Icon(
                        Icons.error,
                        color: Colors.red,
                      ));
                }
              },
              icon: const Icon(
                Icons.logout,
                color: Colors.red,
              ))
        ],
      ),
      body: _buildUI(size),
    );
  }

  Widget _buildUI(Size size) {
    return SafeArea(
      child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.width * 0.04),
          child: _chatUI(size)),
    );
  }

  Widget _chatUI(Size size) {
    return StreamBuilder(
        stream: _dataBaseService.getOtherRegisteredUser(),
        builder: (ctx, snapshots) {
          if (snapshots.hasError) {
            return const Center(
              child: Text('Unable to load data!'),
            );
          }
          if (snapshots.hasData && snapshots.data != null) {
            final users = snapshots.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (ctx, index) {
                  UserProfile userProfile = users[index].data();
                  return GestureDetector(
                    onTap: () async {
                      bool isUserChatExists =
                          await _dataBaseService.checkChatExist(
                              _authService.user!.uid,
                              userProfile.uid.toString());
                      if (!isUserChatExists) {
                        _dataBaseService.createUserChat(
                            _authService.user!.uid, userProfile.uid!);
                      }
                      _navigationService.push(MaterialPageRoute(
                          builder: (ctx) =>
                              UsersChatPage(userProfile: userProfile)));
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: size.width * 0.03),
                      child: ListTile(
                        dense: false,
                        leading: CircleAvatar(
                            radius: size.width * 0.07,
                            backgroundImage: NetworkImage(userProfile.pfpUrl!)),
                        title: Text(userProfile.name!),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
