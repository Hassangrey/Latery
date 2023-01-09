import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/common/post_card.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/theme/colors.dart';
import 'package:routemaster/routemaster.dart';

class CommunityScreen extends ConsumerWidget {
  final String name;
  const CommunityScreen({super.key, required this.name});

  void goToModTools(BuildContext context) {
    Routemaster.of(context).push('/mod-tools/$name');
  }

  void joinCommunity(BuildContext context, Community community, WidgetRef ref) {
    ref
        .read(communityControllerProvider.notifier)
        .joinCommunity(community, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Scaffold(
      body: ref.watch(getCommunityByNameProvider(name)).when(
          data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.network(
                            community.banner,
                            fit: BoxFit.cover,
                          )),
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Color(0xCC000000),
                                    Color(0x00000000),
                                    Color(0x00000000),
                                    Color(0xCC000000),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Align(
                            alignment: Alignment.topLeft,
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(community.avatar),
                              radius: 35,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('r/${community.name}',
                                  style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold)),
                              // ? Display button depending on the user
                              community.mods.contains(user.uid)
                                  ? OutlinedButton(
                                      onPressed: () {
                                        goToModTools(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.orangeColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: const Text(
                                        'Mod Tools',
                                        style: TextStyle(
                                            color: AppColors.whiteColor),
                                      ),
                                    )
                                  : OutlinedButton(
                                      onPressed: () => joinCommunity(
                                          context, community, ref),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 25),
                                      ),
                                      child: Text(
                                          community.members.contains(user.uid)
                                              ? 'Joined'
                                              : 'Join'),
                                    ),
                            ],
                          ),
                          Text(community.bio),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                                '${community.members.length.toString()} members'),
                          ),
                        ]),
                      ),
                    ),
                  ];
                },
                body: ref.watch(getCommunityPostsProvider(name)).when(
                      data: (posts) => MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.separated(
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            return PostCard(post: post);
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const Divider();
                          },
                        ),
                      ),
                      error: (error, stackTrace) =>
                          ErrorText(errorText: error.toString()),
                      loading: () => const Loader(),
                    ),
              ),
          error: (error, stackTrace) => ErrorText(errorText: error.toString()),
          loading: () => const Loader()),
    );
  }
}
