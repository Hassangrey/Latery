import 'package:flutter/foundation.dart';

class UserData {
  final String uid;
  final String name;
  final String email;
  final String profilePic;
  final String banner;
  final bool isAuthenticated;
  final int karma;
  final List<String> awards;

  UserData({
    required this.uid,
    required this.name,
    required this.email,
    required this.profilePic,
    required this.banner,
    required this.isAuthenticated,
    required this.karma,
    required this.awards,
  });

  UserData copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePic,
    String? banner,
    bool? isAuthenticated,
    int? karma,
    List<String>? awards,
  }) {
    return UserData(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePic: profilePic ?? this.profilePic,
      banner: banner ?? this.banner,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'email': email,
      'profilePic': profilePic,
      'banner': banner,
      'isAuthenticated': isAuthenticated,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
        uid: map['uid'] ?? '',
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        profilePic: map['profilePic'] ?? '',
        banner: map['banner'] ?? '',
        isAuthenticated: map['isAuthenticated'] ?? false,
        karma: map['karma'] ?? 0,
        awards: List<String>.from(
          map['awards'],
        ));
  }

  @override
  String toString() {
    return 'UserData(uid: $uid, name: $name, email: $email, profilePic: $profilePic, banner: $banner, isAuthenticated: $isAuthenticated, karma: $karma, awards: $awards)';
  }

  @override
  bool operator ==(covariant UserData other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.profilePic == profilePic &&
        other.banner == banner &&
        other.isAuthenticated == isAuthenticated &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        profilePic.hashCode ^
        banner.hashCode ^
        isAuthenticated.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
