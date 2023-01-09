import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';

class AddModScreen extends ConsumerStatefulWidget {
  final String name;
  const AddModScreen({super.key, required this.name});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModScreenState();
}

class _AddModScreenState extends ConsumerState<AddModScreen> {
  Set<String> uids = {};
  int counter = 0;

  void addMod(String uid) => setState(() {
        uids.add(uid);
      });

  void removeMod(String uid) => setState(() {
        uids.remove(uid);
      });

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Moderators'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: saveMods,
          ),
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (community) => ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) {
                  final member = community.members[index];
                  return ref.watch(getUserDataProvider(member)).when(
                        data: (user) {
                          if (community.mods.contains(member) && counter == 0) {
                            uids.add(member);
                          }
                          counter++;
                          return CheckboxListTile(
                            value: uids.contains(member),
                            onChanged: (val) {
                              if (val!) {
                                addMod(member);
                              } else {
                                removeMod(user.uid);
                              }
                            },
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(user.profilePic),
                                  radius: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(user.name),
                              ],
                            ),
                          );
                        },
                        error: (error, stackTrace) =>
                            ErrorText(errorText: error.toString()),
                        loading: () => const Loader(),
                      );
                },
              ),
          error: (error, stackTrace) => ErrorText(errorText: error.toString()),
          loading: () => const Loader()),
    );
  }
}
