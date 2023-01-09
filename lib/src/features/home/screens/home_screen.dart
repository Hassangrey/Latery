import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/shadow_wrapper.dart';
import 'package:latery/src/core/constants/constants.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/features/home/delegates/search_community_delegate.dart';
import 'package:latery/src/features/home/drawer/profile_drawer.dart';
import 'package:latery/src/model/userdata_model.dart';
import 'package:latery/src/theme/colors.dart';
import 'package:routemaster/routemaster.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _page = 0;
  void displayUserDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Text('u/${user.name}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: currentTheme.textTheme.bodyMedium!.color!,
              )),
          const Icon(
            Icons.keyboard_arrow_down,
            size: 30,
          )
        ]),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context, delegate: SearchCommunityDelegate(ref));
              },
              icon: const Icon(
                Icons.search,
                size: 30,
              ))
        ],
        elevation: 0,
        centerTitle: false,
        leading: Builder(builder: (context) {
          return IconButton(
            icon: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.blackColor, width: 2.5)),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                )),
            onPressed: () => displayUserDrawer(context),
          );
        }),
      ),
      drawer: const ProfileDrawer(),
      body: Constants.tabWidgets[_page],
      bottomNavigationBar: CupertinoTabBar(
        activeColor: currentTheme.iconTheme.color,
        backgroundColor: currentTheme.backgroundColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
          ),
        ],
        onTap: onPageChanged,
        currentIndex: _page,
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
    required this.user,
  });

  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(backgroundImage: NetworkImage(user.profilePic)),
          title: Text(user.name),
          subtitle: Text(user.uid),
          trailing: const Icon(Icons.more),
        ),
        const Text(
          'The breathtaking world of One Piece.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.network(
            user.banner,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.comment),
            const Icon(Icons.share),
            const Icon(Icons.card_giftcard),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.greyColor.withOpacity(0.05)),
              child: const Text(
                '1.8k',
              ),
            )
          ],
        ),
      ]),
    );
  }
}

class Catagories extends StatelessWidget {
  const Catagories({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: AppColors.greyColor.withOpacity(0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ShadowWrapper(
            child: ElevatedButton.icon(
              label: const Text('Best Posts'),
              icon: const Icon(Icons.rocket),
              onPressed: () => Routemaster.of(context).push('/communities'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.orangeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          const Text(
            'Hot',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'New',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Top',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
