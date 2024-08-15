import 'package:flutter/foundation.dart';

class UserProfile {
  String? uid;
  String? name;
  String? pfpUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.pfpUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
        uid: json['uid'], name: json['name'], pfpUrl: json['pfpUrl']);
  }

  Map<String, dynamic> toJson() {
    return {'uid': uid, 'name': name, 'pfpUrl': pfpUrl};
  }
}
