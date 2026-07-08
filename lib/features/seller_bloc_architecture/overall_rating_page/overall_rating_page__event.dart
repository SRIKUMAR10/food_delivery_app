import 'package:equatable/equatable.dart';

abstract class OverallRatingEvent extends Equatable {
  const OverallRatingEvent();

  @override
  List<Object> get props => [];
}

class LoadOverallRatingEvent extends OverallRatingEvent {}

class RefreshOverallRatingEvent extends OverallRatingEvent {}
