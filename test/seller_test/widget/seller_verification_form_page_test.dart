import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__bloc.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__event.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_profile_page__state.dart';
import 'package:food_delivery_app/features/seller_bloc_architecture/seller_profile_page/seller_verification_form_page.dart';

class MockSellerProfilePageBloc extends Mock implements SellerProfilePageBloc {}

void main() {
  group('SellerVerificationFormPage Widget Tests', () {
    late MockSellerProfilePageBloc mockBloc;

    setUpAll(() {
      registerFallbackValue(const SubmitVerificationForm(
        storeName: '',
        address: '',
        email: '',
        phone: '',
        gstNumber: '',
        taxConfiguration: '',
        fssaiLicense: '',
        bankAccountNumber: '',
        ifscCode: '',
      ));
      registerFallbackValue(const SubmitSellerKycDocuments(
        fssaiNumber: '',
        gstNumber: '',
        panNumber: '',
        bankAccountNumber: '',
        ifscCode: '',
      ));
      registerFallbackValue(UploadKycDocumentFileEvent(
        docType: '',
        fileName: '',
        fileBytes: Uint8List(0),
      ));
    });

    setUp(() {
      mockBloc = MockSellerProfilePageBloc();
      when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockBloc.close()).thenAnswer((_) async {});
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Spice Garden',
        email: 'spice@garden.com',
        phone: '9876543210',
        address: '45 Anna Nagar, Chennai',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: false,
        kycStatus: 'pending',
      ));
    });

    Future<void> pumpFormPage(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sellerDashboard': (_) => const Scaffold(body: Text('Seller Dashboard')),
          },
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const SellerVerificationFormPage(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('renders business, bank and KYC detail sections with GPS/map pickers on address', (tester) async {
      await pumpFormPage(tester);

      expect(find.text('Verify Account & KYC'), findsOneWidget);
      expect(find.text('KYC Pending'), findsOneWidget);
      expect(find.text('Business Details'), findsOneWidget);
      expect(find.text('Bank Account Details'), findsOneWidget);
      expect(find.text('KYC Document Certificates'), findsOneWidget);
      expect(find.byKey(const ValueKey('verification_address')), findsOneWidget);
      expect(find.byKey(const ValueKey('verification_gps_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('verification_map_button')), findsOneWidget);
    });

    testWidgets('tapping map picker opens the interactive Seller address dialog', (tester) async {
      await pumpFormPage(tester);

      await tester.ensureVisible(find.byKey(const ValueKey('verification_map_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('verification_map_button')));
      await tester.pumpAndSettle();

      expect(find.text('Set Restaurant Address'), findsOneWidget);
      expect(find.text('Search Address'), findsOneWidget);
      expect(find.text('Pick on Map'), findsOneWidget);
    });

    testWidgets('submitting a valid form dispatches SubmitVerificationForm and SubmitSellerKycDocuments', (tester) async {
      await pumpFormPage(tester);

      await tester.enterText(
        find.byKey(const ValueKey('verification_store_name')),
        'Spice Garden',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_address')),
        '45 Anna Nagar, Chennai',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_email')),
        'spice@garden.com',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_phone')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_gst')),
        '33ABCDE1234F1Z5',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_pan')),
        'ABCDE1234F',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_fssai')),
        '12345678901234',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_bank')),
        '123456789012',
      );
      await tester.enterText(
        find.byKey(const ValueKey('verification_ifsc')),
        'HDFC0001234',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('verification_tax')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('verification_tax')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18% GST').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit for Verification'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit for Verification'));
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          any(
            that: isA<SubmitVerificationForm>()
                .having((e) => e.address, 'address', '45 Anna Nagar, Chennai')
                .having((e) => e.taxConfiguration, 'taxConfiguration', '18%'),
          ),
        ),
      ).called(1);

      verify(
        () => mockBloc.add(
          any(
            that: isA<SubmitSellerKycDocuments>()
                .having((e) => e.panNumber, 'panNumber', 'ABCDE1234F')
                .having((e) => e.fssaiNumber, 'fssaiNumber', '12345678901234'),
          ),
        ),
      ).called(1);
    });

    testWidgets('renders correctly when bloc is passed via constructor parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SellerVerificationFormPage(bloc: mockBloc),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify Account & KYC'), findsOneWidget);
      expect(find.text('Spice Garden'), findsOneWidget);
      expect(find.text('45 Anna Nagar, Chennai'), findsOneWidget);
    });

    testWidgets('renders correctly without ProviderNotFoundException even when no bloc is in context', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SellerVerificationFormPage(),
        ),
      );
      await tester.pump();

      expect(find.text('Verify Account & KYC'), findsOneWidget);
      expect(find.text('Business Details'), findsOneWidget);
    });

    testWidgets('tapping document upload button dispatches UploadKycDocumentFileEvent', (tester) async {
      await pumpFormPage(tester);

      await tester.ensureVisible(find.text('Upload').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload').first);
      await tester.pumpAndSettle();

      verify(
        () => mockBloc.add(
          any(
            that: isA<UploadKycDocumentFileEvent>()
                .having((e) => e.docType, 'docType', 'fssai_certificate'),
          ),
        ),
      ).called(1);
    });
  });
}