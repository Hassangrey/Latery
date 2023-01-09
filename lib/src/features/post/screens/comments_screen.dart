import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/common/post_card.dart';
import 'package:latery/src/features/post/controller/post_controller.dart';
import 'package:latery/src/features/post/widgets/comment_card.dart';
import 'package:latery/src/model/post_model.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentsScreen({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final commentController = TextEditingController();
  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref.read(postControllerProvider.notifier).addComment(
        context: context,
        commentText: commentController.text.trim(),
        post: post);
    commentController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
            data: (post) {
              return SafeArea(
                child: Column(
                  children: [
                    PostCard(post: post),
                    const SizedBox(height: 10),
                    TextField(
                      onSubmitted: ((value) => addComment(post)),
                      controller: commentController,
                      decoration: InputDecoration(
                          hintText: 'What are your thoughts?',
                          filled: true,
                          border: InputBorder.none,
                          suffixIcon: IconButton(
                              onPressed: (() => addComment(post)),
                              icon: const Icon(
                                  Icons.arrow_circle_right_outlined))),
                    ),
                    ref.watch(getPostCommentsProvider(widget.postId)).when(
                          data: (comments) => Expanded(
                            child: ListView.separated(
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return CommentCard(comment: comment);
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return const Divider();
                              },
                            ),
                          ),
                          error: (error, stackTrace) =>
                              ErrorText(errorText: error.toString()),
                          loading: () => const Loader(),
                        )
                  ],
                ),
              );
            },
            error: (error, stackTrace) =>
                ErrorText(errorText: error.toString()),
            loading: () => const Loader(),
          ),
    );
  }
}
