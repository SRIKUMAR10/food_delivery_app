import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- SERVICE ---
class DetailsPageService {
  Future<Map<String, dynamic>> fetchDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (id == 'error') {
      throw Exception('Failed to fetch details');
    }
    return {'id': id, 'name': 'Delicious Burger', 'price': 10.99};
  }
}

// --- REPOSITORY ---
class DetailsPageRepository {
  final DetailsPageService service;

  DetailsPageRepository({required this.service});

  Future<Map<String, dynamic>> getDetails(String id) async {
    try {
      return await service.fetchDetails(id);
    } catch (e) {
      rethrow;
    }
  }
}

// --- EVENTS ---
abstract class DetailsPageEvent {}

class LoadDetailsEvent extends DetailsPageEvent {
  final String id;
  LoadDetailsEvent(this.id);
}

// --- STATES ---
abstract class DetailsPageState {}

class DetailsInitial extends DetailsPageState {}

class DetailsLoading extends DetailsPageState {}

class DetailsLoaded extends DetailsPageState {
  final Map<String, dynamic> data;
  DetailsLoaded(this.data);
}

class DetailsError extends DetailsPageState {
  final String message;
  DetailsError(this.message);
}

// --- BLOC ---
class DetailsPageBloc extends Bloc<DetailsPageEvent, DetailsPageState> {
  final DetailsPageRepository repository;

  DetailsPageBloc({required this.repository}) : super(DetailsInitial()) {
    on<LoadDetailsEvent>((event, emit) async {
      emit(DetailsLoading());
      try {
        final data = await repository.getDetails(event.id);
        emit(DetailsLoaded(data));
      } catch (e) {
        emit(DetailsError(e.toString()));
      }
    });
  }
}

// --- UI WIDGET ---
class DetailsPage extends StatelessWidget {
  final String itemId;

  const DetailsPage({Key? key, required this.itemId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details Page')),
      body: BlocBuilder<DetailsPageBloc, DetailsPageState>(
        builder: (context, state) {
          if (state is DetailsInitial) {
            return const Center(child: Text('Initial State'));
          } else if (state is DetailsLoading) {
            return const Center(child: CircularProgressIndicator(key: Key('loading_indicator')));
          } else if (state is DetailsLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${state.data['name']}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Price: \$${state.data['price']}', style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else if (state is DetailsError) {
            return Center(child: Text('Error: ${state.message}', key: const Key('error_text')));
          }
          return Container();
        },
      ),
    );
  }
}
