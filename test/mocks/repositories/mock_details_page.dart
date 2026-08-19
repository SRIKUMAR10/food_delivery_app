import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ─── Events ──────────────────────────────────────────────────────────────────

abstract class DetailsPageEvent extends Equatable {
  const DetailsPageEvent();

  @override
  List<Object> get props => [];
}

class LoadDetailsEvent extends DetailsPageEvent {
  final String itemId;

  const LoadDetailsEvent(this.itemId);

  @override
  List<Object> get props => [itemId];
}

// ─── States ──────────────────────────────────────────────────────────────────

abstract class DetailsPageState extends Equatable {
  const DetailsPageState();

  @override
  List<Object> get props => [];
}

class DetailsPageInitial extends DetailsPageState {}

class DetailsPageLoading extends DetailsPageState {}

class DetailsPageLoaded extends DetailsPageState {
  final String name;
  final double price;

  const DetailsPageLoaded({required this.name, required this.price});

  @override
  List<Object> get props => [name, price];
}

class DetailsPageError extends DetailsPageState {
  final String message;

  const DetailsPageError({required this.message});

  @override
  List<Object> get props => [message];
}

// ─── Service ─────────────────────────────────────────────────────────────────

class DetailsPageService {
  Future<Map<String, dynamic>> fetchDetails(String itemId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (itemId == 'error') {
      throw Exception('Failed to fetch details');
    }
    return {
      'id': itemId,
      'name': 'Delicious Burger',
      'price': 10.99,
    };
  }
}

// ─── Repository ──────────────────────────────────────────────────────────────

class DetailsPageRepository {
  final DetailsPageService service;

  DetailsPageRepository({required this.service});

  Future<Map<String, dynamic>> getDetails(String itemId) {
    return service.fetchDetails(itemId);
  }
}

// ─── BLoC ────────────────────────────────────────────────────────────────────

class DetailsPageBloc extends Bloc<DetailsPageEvent, DetailsPageState> {
  final DetailsPageRepository repository;

  DetailsPageBloc({required this.repository}) : super(DetailsPageInitial()) {
    on<LoadDetailsEvent>(_onLoadDetails);
  }

  Future<void> _onLoadDetails(
    LoadDetailsEvent event,
    Emitter<DetailsPageState> emit,
  ) async {
    emit(DetailsPageLoading());
    try {
      final data = await repository.getDetails(event.itemId);
      emit(DetailsPageLoaded(
        name: data['name'] as String,
        price: (data['price'] as num).toDouble(),
      ));
    } catch (e) {
      emit(DetailsPageError(message: 'Error: $e'));
    }
  }
}

// ─── Page Widget ─────────────────────────────────────────────────────────────

class DetailsPage extends StatelessWidget {
  final String itemId;

  const DetailsPage({super.key, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DetailsPageBloc, DetailsPageState>(
      builder: (context, state) {
        if (state is DetailsPageInitial) {
          return const Scaffold(
            body: Center(child: Text('Initial State')),
          );
        } else if (state is DetailsPageLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is DetailsPageLoaded) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Name: ${state.name}'),
                  Text('Price: \$${state.price.toStringAsFixed(2)}'),
                ],
              ),
            ),
          );
        } else if (state is DetailsPageError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        }
        return const Scaffold(
          body: Center(child: Text('Unknown state')),
        );
      },
    );
  }
}
