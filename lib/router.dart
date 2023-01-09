import 'package:flutter/material.dart';
import 'package:latery/src/features/auth/screens/login_screen.dart';
import 'package:latery/src/features/communities/screens/add_mod_screen.dart';
import 'package:latery/src/features/communities/screens/communities_list_screen.dart';
import 'package:latery/src/features/communities/screens/community_screen.dart';
import 'package:latery/src/features/communities/screens/edit_community_screen.dart';
import 'package:latery/src/features/communities/screens/mod_tools_screen.dart';
import 'package:latery/src/features/home/screens/home_screen.dart';
import 'package:latery/src/features/post/screens/add_post_type_screen.dart';
import 'package:latery/src/features/post/screens/comments_screen.dart';
import 'package:latery/src/features/user_profile/screens/edit_profile_screen.dart';
import 'package:latery/src/features/user_profile/screens/user_profile_screen.dart';
import 'package:routemaster/routemaster.dart';

// * Logged out routes
final loggedOutRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: LoginScreen()),
});

// * Logged in routes
final loggedInRoute = RouteMap(routes: {
  '/': (_) => const MaterialPage(child: HomeScreen()),
  '/communities': (_) => const MaterialPage(child: CommunitiesListScreen()),
  '/r/:name': (route) =>
      MaterialPage(child: CommunityScreen(name: route.pathParameters['name']!)),
  '/mod-tools/:name': (route) =>
      MaterialPage(child: ModToolsScreen(name: route.pathParameters['name']!)),
  '/edit-community/:name': (route) => MaterialPage(
      child: EditCommunityScreen(name: route.pathParameters['name']!)),
  '/add-mod/:name': (route) =>
      MaterialPage(child: AddModScreen(name: route.pathParameters['name']!)),
  '/u/:uid': (route) =>
      MaterialPage(child: UserProfileScreen(uid: route.pathParameters['uid']!)),
  '/edit-profile/:uid': (route) =>
      MaterialPage(child: EditProfileScreen(uid: route.pathParameters['uid']!)),
  '/add-post/:type': (route) => MaterialPage(
      child: AddPostTypeScreen(type: route.pathParameters['type']!)),
  '/post/:postId/comments': (route) => MaterialPage(
      child: CommentsScreen(postId: route.pathParameters['postId']!)),
});
