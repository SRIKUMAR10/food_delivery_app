import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_setting_page/seller_setting_page__ui.dart';

class TestSellerSettingRepository implements SellerSettingRepository {
  SellerSettingState _state = const SellerSettingState();

  @override
  Future<SellerSettingState> loadSettings() async {
    return _state;
  }

  @override
  Future<void> saveSettings(SellerSettingState state) async {
    _state = state;
  }
}

void main() {
  testWidgets('Seller Setting Page Flow Test', (WidgetTester tester) async {
    final repository = TestSellerSettingRepository();
    final bloc = SellerSettingBloc(repository: repository);
    // Initially load settings
    bloc.add(LoadSellerSettings());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<SellerSettingBloc>.value(
          value: bloc,
          child: const SellerSettingPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify initial switches
    final pushNotificationSwitch = find
        .byWidgetPredicate(
          (widget) =>
              widget is Switch && widget.value == true, // true by default
        )
        .first;

    expect(pushNotificationSwitch, findsOneWidget);

    // Tap switch
    await tester.tap(pushNotificationSwitch);
    await tester.pumpAndSettle();

    // Verify state was updated
    expect(bloc.state.pushNotifications, false);
  });
}
