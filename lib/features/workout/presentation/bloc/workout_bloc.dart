import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

abstract class WorkoutEvent {}

class WorkoutStarted extends WorkoutEvent {}

abstract class WorkoutState {}

class WorkoutInitial extends WorkoutState {}

@injectable
class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  WorkoutBloc() : super(WorkoutInitial()) {
    on<WorkoutStarted>((event, emit) {});
  }
}
