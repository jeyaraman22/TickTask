import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/app_preferences_service.dart';

part 'splash_state.dart';

// Cubit to manage splash screen animations and state
class SplashCubit extends Cubit<SplashState> {
  // Animation controllers and animations
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> opacityAnimation;
  late Animation<double> rotationAnimation;

  // Constructor with app preferences dependency
  SplashCubit({required AppPreferencesService appPreferencesService})
      : super(SplashInitial());

  // Initialize all animations with their curves and durations
  void initializeAnimations(TickerProvider vsync) {
    // Main animation controller with 2 second duration
    animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    );

    // Scale animation with elastic curve
    scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Opacity animation with ease-in curve
    opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Rotation animation with elastic curve
    rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Add listener for animation status changes
    animationController.addStatusListener(_onAnimationStatusChanged);
    animationController.forward();
  }

  // Handle animation status changes
  void _onAnimationStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      // Emit completion state after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        emit(SplashAnimationComplete());
      });
    }
  }

  // Clean up resources when cubit is disposed
  void dispose() {
    animationController.removeStatusListener(_onAnimationStatusChanged);
    animationController.dispose();
  }

  // Helper getter to check if animation is complete
  bool get isAnimationComplete =>
      animationController.status == AnimationStatus.completed;
}
