import 'package:flutter/material.dart';
import 'package:latery/src/theme/colors.dart';

class ShadowWrapper extends StatelessWidget {
  final Widget child;
  const ShadowWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.orangeColor,
            blurRadius: 25,
            spreadRadius: -15,
            offset: Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }
}
