import 'package:flutter/material.dart';
import 'package:latery/src/features/feed/screens/feeds_screen.dart';
import 'package:latery/src/features/post/screens/add_post_screen.dart';

class Constants {
  static const avatarDefault =
      'https://i.pinimg.com/originals/50/dc/42/50dc42aba40f0e6cbd1c863a3ae73179.jpg';
  static const bannerDefault =
      'https://i.pinimg.com/originals/57/7c/83/577c83a5fa23c2229fdf7df72945f324.jpg';

  static const tabWidgets = [
    FeedScreen(),
    AddPostScreen(),
  ];

  static const IconData up = IconData(0xe800, fontFamily: 'MyFlutterApp', fontPackage: null);
  static const IconData down = IconData(0xe801, fontFamily: 'MyFlutterApp', fontPackage: null);

  static const awardsPath = 'assets/images/awards';

  static const awards = {
    'awesomeAns': '${Constants.awardsPath}/awesomeanswer.png',
    'gold': '${Constants.awardsPath}/gold.png',
    'platinum': '${Constants.awardsPath}/platinum.png',
    'helpful': '${Constants.awardsPath}/helpful.png',
    'plusone': '${Constants.awardsPath}/plusone.png',
    'rocket': '${Constants.awardsPath}/rocket.png',
    'thankyou': '${Constants.awardsPath}/thankyou.png',
    'til': '${Constants.awardsPath}/til.png',
  };
}
