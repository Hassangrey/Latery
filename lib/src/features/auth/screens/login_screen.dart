import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latery/src/core/common/loader.dart';
import 'package:latery/src/core/common/shadow_wrapper.dart';
import 'package:latery/src/core/common/signin_button.dart';
import 'package:latery/src/features/auth/controller/auth_controller.dart';
import 'package:latery/src/theme/colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: isLoading
            ? const Loader()
            : Stack(
                children: [
                  const SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                  ),
                  Image.asset('assets/images/banner_login.png'),
                  Positioned(
                    top: 310,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 50, horizontal: 25),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: AppColors.whiteColor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // ignore: prefer_const_literals_to_create_immutables
                        children: [
                          const Text(
                            'The Best Latery\n Experince',
                            style: TextStyle(
                              fontFamily: 'Helvetica',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 60),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Username & Email',
                            ),
                          ),
                          const SizedBox(height: 30),
                          const TextField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                          ),
                          const SizedBox(height: 60),
                          const SignInButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
        floatingActionButton: SizedBox(
          width: 100,
          height: 100,
          child: ShadowWrapper(
            child: FloatingActionButton(
              elevation: 2,
              onPressed: () {},
              backgroundColor: AppColors.orangeColor,
              child: const Text(
                'Skip',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Helvetica'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
