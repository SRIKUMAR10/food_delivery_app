import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/chat_support_page_/chat_support_page_ui.dart';

class MockChatSupportBloc extends Mock implements ChatSupportBloc {}

void main() {
  group('ChatSupportPage Golden Tests', () {
    late MockChatSupportBloc mockBloc;

    setUp(() async {
      mockBloc = MockChatSupportBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
    });

    testGoldens('Chat Support page layout matches golden file', (tester) async {
      await loadAppFonts();

      when(() => mockBloc.state).thenReturn(ChatSupportLoaded(activeSessions: []));

      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone, Device.iphone11])
        ..addScenario(
          name: 'Chat Support Empty State',
          widget: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: BlocProvider<ChatSupportBloc>.value(
              value: mockBloc,
              child: const ChatSupportView(),
            ),
          ),
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'chat_support_page_golden');
    });
  });
}
