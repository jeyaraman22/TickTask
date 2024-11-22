part of 'splash_cubit.dart';

// Base state class for splash screen states
abstract class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object> get props => [];
}

// Initial state when splash screen is first shown
class SplashInitial extends SplashState {}

// State when splash screen animations are complete
class SplashAnimationComplete extends SplashState {}
