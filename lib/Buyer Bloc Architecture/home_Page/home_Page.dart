// lib/Buyer Bloc Architecture/home_Page/home_Page.dart
//
// Barrel re-export file for backward compatibility.
// Any file that previously imported home_Page.dart will continue to work
// without needing to update its import path.
//
// The actual implementation is split across:
//   • home_page_models.dart — FoodCategory, FoodItem data classes
//   • home_Page_Event.dart  — BLoC events
//   • home_Page_State.dart  — BLoC states
//   • home_Page_Bloc.dart   — business logic
//   • home_Page_UI.dart     — UI widgets

export 'home_page_models.dart';
export 'home_Page_Bloc.dart';
export 'home_Page_UI.dart';
