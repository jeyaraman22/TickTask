import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class LoaderEvent extends Equatable {
  const LoaderEvent();

  @override
  List<Object?> get props => [];
}

class ShowLoader extends LoaderEvent {}

class HideLoader extends LoaderEvent {}

// State
class LoaderState extends Equatable {
  final bool isLoading;

  const LoaderState({this.isLoading = false});

  @override
  List<Object?> get props => [isLoading];
}

// Bloc
class LoaderBloc extends Bloc<LoaderEvent, LoaderState> {
  LoaderBloc() : super(const LoaderState()) {
    on<ShowLoader>((event, emit) => emit(const LoaderState(isLoading: true)));
    on<HideLoader>((event, emit) => emit(const LoaderState(isLoading: false)));
  }
}
