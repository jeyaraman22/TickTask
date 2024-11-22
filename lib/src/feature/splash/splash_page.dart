import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:tick_task/src/app_images/app_images.dart';
import 'package:tick_task/src/core/routes/router.dart';
import 'splash_cubit/splash_cubit.dart';

// Main splash screen widget that displays animated logo
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

// State class that handles animations using TickerProvider
class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Initialize animations when widget is first created
    final splashCubit = context.read<SplashCubit>();
    splashCubit.initializeAnimations(this);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      // Listen for animation completion and navigate to home
      listener: (context, state) {
        if (state is SplashAnimationComplete) {
          GoRouter.of(context).go(AppRouter.homeRoute);
        }
      },
      child: Scaffold(
        body: Center(
          child: AnimatedBuilder(
            // Rebuild widget when animation values change
            animation: context.read<SplashCubit>().animationController,
            builder: (context, child) {
              final cubit = context.read<SplashCubit>();
              return Transform.rotate(
                // Apply rotation animation
                angle: cubit.rotationAnimation.value,
                child: Transform.scale(
                  // Apply scale animation
                  scale: cubit.scaleAnimation.value,
                  child: Opacity(
                    // Apply fade animation
                    opacity: cubit.opacityAnimation.value,
                    child: SizedBox.square(
                      // Set logo size relative to screen width
                      dimension: MediaQuery.of(context).size.width * 0.25,
                      child: SvgPicture.asset(
                        AppImages.splashImage,
                        height: MediaQuery.of(context).size.height * 0.25,
                        width: MediaQuery.of(context).size.width * 0.25,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
