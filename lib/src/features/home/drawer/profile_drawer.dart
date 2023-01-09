import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/theme/colors.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logout();
  }

  void goToProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('/u/$uid');
  }

  void goToCommunities(BuildContext context) {
    Routemaster.of(context).push('/communities');
  }

  void toggleTheme(WidgetRef ref) {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
        child: SafeArea(
      child: Column(children: [
        CircleAvatar(
          backgroundImage: NetworkImage(user.profilePic),
          radius: 70,
        ),
        const SizedBox(height: 10),
        Text(
          'u/${user.name}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        const Divider(),
        ListTile(
          title: const Text('My Profile'),
          leading: const Icon(Icons.person),
          onTap: () => goToProfile(context, user.uid),
        ),
        ListTile(
          title: const Text('My Communities'),
          leading: const Icon(Icons.people),
          onTap: () => goToCommunities(context),
        ),
        ListTile(
          title: const Text('Logout'),
          leading: const Icon(Icons.logout, color: Colors.red),
          onTap: () => logOut(ref),
        ),
        Switch.adaptive(
          value:
              ref.watch(themeNotifierProvider.notifier).mode == ThemeMode.dark,
          onChanged: (value) => toggleTheme(ref),
        ),
      ]),
    ));
  }
}
