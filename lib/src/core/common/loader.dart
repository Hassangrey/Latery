import 'package:flutter/material.dart';
import 'package:latery/src/theme/colors.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.orangeColor,
      ),
    );
  }
}
