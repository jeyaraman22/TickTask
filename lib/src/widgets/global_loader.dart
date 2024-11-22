import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/bloc/loader_bloc.dart';
import 'loading_overlay.dart';

// Widget that provides global loading overlay functionality
class GlobalLoader extends StatelessWidget {
  // Child widget to be wrapped with loader functionality
  final Widget child;

  const GlobalLoader({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Ensure consistent text direction
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          // Main content
          child,
          // Loading overlay that shows/hides based on loading state
          BlocBuilder<LoaderBloc, LoaderState>(
            builder: (context, state) {
              // Show loading overlay when isLoading is true
              if (state.isLoading) {
                return const LoadingOverlay();
              }
              // Hide loading overlay when not loading
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
