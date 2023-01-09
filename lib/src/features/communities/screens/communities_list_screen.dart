import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/error.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/common/shadow_wrapper.dart';
import 'package:latery/src/core/common/signin_button.dart';
import 'package:latery/src/features/communities/controller/community_controller.dart';
import 'package:latery/src/model/community_model.dart';
import 'package:latery/src/theme/colors.dart';
import 'package:routemaster/routemaster.dart';

class CommunitiesListScreen extends ConsumerStatefulWidget {
  const CommunitiesListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CommunitiesListScreenState();
}

class _CommunitiesListScreenState extends ConsumerState<CommunitiesListScreen> {
  final _communityNameController = TextEditingController();
  void createCommunity() {
    ref
        .read(communityControllerProvider.notifier)
        .createCommunity(_communityNameController.text.trim(), context);
  }

  void goToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
          child: isLoading
              ? const Loader()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShadowWrapper(
                        child: OrangeButton(
                          title: 'Create a Community',
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 85),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text('Enter Community Name'),
                                      const SizedBox(height: 10),
                                      TextFormField(
                                        controller: _communityNameController,
                                        decoration: const InputDecoration(
                                            hintText: 'r/Community_name',
                                            filled: true,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(18)),
                                        maxLength: 21,
                                      ),
                                      OrangeButton(
                                        title: 'Create Community',
                                        onPressed: createCommunity,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 50),
                      const Text(
                        'My Communities',
                        style: TextStyle(
                            color: AppColors.blackColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),
                      ref.watch(userCommunitiesProvider).when(
                            data: (communities) => communities.isEmpty
                                ? const Center(
                                    child: Text(
                                      'You haven\'t joined any community yet!',
                                      style: TextStyle(
                                          color: AppColors.orangeColor,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : Expanded(
                                    child: ListView.builder(
                                    itemCount: communities.length,
                                    itemBuilder: (context, index) {
                                      final community = communities[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(community.avatar),
                                        ),
                                        title: Text(
                                          'r/${community.name}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 17),
                                        ),
                                        trailing: const Icon(
                                            Icons.star_border_outlined),
                                        onTap: () {
                                          goToCommunity(context, community);
                                        },
                                      );
                                    },
                                  )),
                            error: (error, stackTrace) =>
                                ErrorText(errorText: error.toString()),
                            loading: () => const Loader(),
                          ),
                    ],
                  ),
                )),
    );
  }
}
