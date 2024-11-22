import 'package:tick_task/src/core/di/dependency.dart';
import 'loader_bloc.dart';

mixin LoaderMixin {
  void showLoader() {
    SL.getIt<LoaderBloc>().add(ShowLoader());
  }

  void hideLoader() {
    SL.getIt<LoaderBloc>().add(HideLoader());
  }
}
