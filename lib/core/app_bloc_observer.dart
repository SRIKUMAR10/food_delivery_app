import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('${bloc.runtimeType}: state changed');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('${bloc.runtimeType}: ${transition.event.runtimeType} -> ${transition.nextState.runtimeType}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('${bloc.runtimeType} $error');

    if (!kIsWeb) {
      try {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'Exception in ${bloc.runtimeType}',
          fatal: false,
        );
      } catch (e) {
        debugPrint('Crashlytics record error skipped: $e');
      }
    }

    super.onError(bloc, error, stackTrace);
  }
}
