import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/constants/constants.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';
import 'package:latery/src/features/post/controller/post_controller.dart';
import 'package:latery/src/model/post_model.dart';
import 'package:latery/src/theme/colors.dart';
import 'package:routemaster/routemaster.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(post, context);
  }

  void upvotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void goToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void goToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void goToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: currentTheme.backgroundColor,
          ),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ).copyWith(right: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => goToCommunity(context),
                                  child: CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                    radius: 16,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () => goToCommunity(context),
                                          child: Text(
                                            'r/${post.communityName}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => goToUser(context),
                                          child: Text(
                                            'u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                            if (post.uid == user.uid)
                              IconButton(
                                onPressed: () => deletePost(context, ref),
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.orangeColor,
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(post.title,
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        if (isTypeImage)
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35,
                            width: double.infinity,
                            child: Image.network(
                              post.link!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (isTypeLink)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: AnyLinkPreview(
                              displayDirection:
                                  UIDirection.uiDirectionHorizontal,
                              link: post.link!,
                            ),
                          ),
                        if (isTypeText)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            alignment: Alignment.topLeft,
                            child: Text(
                              post.description!,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ), // TextStyle
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => upvotePost(ref),
                                  icon: const Icon(Constants.up, size: 30),
                                  color: post.upvotes.contains(user.uid)
                                      ? AppColors.orangeColor
                                      : null,
                                ),
                                Text(
                                  '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                                IconButton(
                                  onPressed: () => downvotePost(ref),
                                  icon: const Icon(Constants.down, size: 30),
                                  color: post.downvotes.contains(user.uid)
                                      ? AppColors.orangeColor
                                      : null,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => goToComments(context),
                                  icon: const Icon(
                                    Icons.comment,
                                  ),
                                ),
                                Text(
                                  '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ],
                            ),
                            ref
                                .watch(getCommunityByNameProvider(
                                    post.communityName))
                                .when(
                                  data: (data) {
                                    if (data.mods.contains(user.uid)) {
                                      return IconButton(
                                        onPressed: () =>
                                            deletePost(context, ref),
                                        icon: const Icon(
                                          Icons.admin_panel_settings,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  },
                                  error: (error, stackTrace) =>
                                      ErrorText(errorText: error.toString()),
                                  loading: (() => const Loader()),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ]),
        )
      ],
    );
  }
}
