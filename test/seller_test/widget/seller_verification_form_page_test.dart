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

    Future<void> pumpFormPage(WidgetTester tester, {bool settle = true}) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/sellerDashboard': (_) => const Scaffold(body: Text('Seller Dashboard')),
            '/sellerStoreDetails': (_) => const Scaffold(body: Text('Seller Store Details')),
          },
          home: BlocProvider<SellerProfilePageBloc>.value(
            value: mockBloc,
            child: const SellerVerificationFormPage(),
          ),
        ),
      );
      if (settle) {
        await tester.pumpAndSettle();
      } else {
        await tester.pump();
      }
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
      expect(find.text('Save & Continue to Store Details'), findsOneWidget);
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

    testWidgets('shows mandatory alert below each missing KYC document when Save & Continue is pressed without uploads', (tester) async {
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
        fssaiCertificateUrl: null,
        gstCertificateUrl: null,
        panCardUrl: null,
        bankChequeUrl: null,
      ));

      await pumpFormPage(tester);

      await tester.enterText(find.byKey(const ValueKey('verification_store_name')), 'Spice Garden');
      await tester.enterText(find.byKey(const ValueKey('verification_address')), '45 Anna Nagar, Chennai');
      await tester.enterText(find.byKey(const ValueKey('verification_email')), 'spice@garden.com');
      await tester.enterText(find.byKey(const ValueKey('verification_phone')), '9876543210');
      await tester.enterText(find.byKey(const ValueKey('verification_gst')), '33ABCDE1234F1Z5');
      await tester.enterText(find.byKey(const ValueKey('verification_pan')), 'ABCDE1234F');
      await tester.enterText(find.byKey(const ValueKey('verification_fssai')), '12345678901234');
      await tester.enterText(find.byKey(const ValueKey('verification_bank')), '123456789012');
      await tester.enterText(find.byKey(const ValueKey('verification_ifsc')), 'HDFC0001234');

      await tester.ensureVisible(find.byKey(const ValueKey('verification_tax')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('verification_tax')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('18% GST').last);
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const ValueKey('verification_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('verification_submit_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('kyc_error_alert_fssai_certificate')), findsOneWidget);
      expect(find.byKey(const ValueKey('kyc_error_alert_gst_certificate')), findsOneWidget);
      expect(find.byKey(const ValueKey('kyc_error_alert_pan_card')), findsOneWidget);
      expect(find.byKey(const ValueKey('kyc_error_alert_bank_cheque')), findsOneWidget);

      expect(find.text('All 4 certificate documents are mandatory. Please upload all missing certificates below to proceed.'), findsOneWidget);

      verifyNever(() => mockBloc.add(any(that: isA<SubmitVerificationForm>())));
      verifyNever(() => mockBloc.add(any(that: isA<SubmitSellerKycDocuments>())));
      expect(find.text('Seller Store Details'), findsNothing);
    });

    testWidgets('submitting a valid form with all 4 KYC documents dispatches SubmitVerificationForm and SubmitSellerKycDocuments and navigates', (tester) async {
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
        fssaiCertificateUrl: 'https://storage.googleapis.com/fssai.jpg',
        gstCertificateUrl: 'https://storage.googleapis.com/gst.jpg',
        panCardUrl: 'https://storage.googleapis.com/pan.jpg',
        bankChequeUrl: 'https://storage.googleapis.com/cheque.jpg',
      ));

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

      await tester.ensureVisible(find.byKey(const ValueKey('verification_submit_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('verification_submit_button')));
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

      expect(find.text('Seller Store Details'), findsOneWidget);
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

    testWidgets('tapping document upload button presents cross-platform upload options', (tester) async {
      await pumpFormPage(tester);

      await tester.ensureVisible(find.text('Upload').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Upload').first);
      await tester.pumpAndSettle();

      expect(find.text('Upload FSSAI Food License Certificate'), findsOneWidget);
      expect(find.text('Take Photo (Camera)'), findsOneWidget);
      expect(find.text('Photo Gallery'), findsOneWidget);
      expect(find.text('Browse Files (Image / PDF)'), findsOneWidget);
    });

    testWidgets('renders uploaded state with preview button and allows preview modal', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Spice Garden',
        email: 'spice@garden.com',
        phone: '9876543210',
        address: '45 Anna Nagar, Chennai',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        kycStatus: 'approved',
        fssaiCertificateUrl: 'https://storage.googleapis.com/fssai.jpg',
      ));

      await pumpFormPage(tester);

      expect(find.text('Document Uploaded'), findsOneWidget);
      expect(find.text('Re-upload'), findsOneWidget);
      expect(find.byTooltip('Preview Document'), findsOneWidget);
      expect(find.byKey(const ValueKey('kyc_thumbnail_fssai_certificate')), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Preview Document').first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Preview Document').first);
      await tester.pumpAndSettle();

      expect(find.text('FSSAI Food License Certificate'), findsWidgets);
      expect(find.text('Uploaded Certificate Document'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Tip: Pinch or double-tap image to zoom in/out'), findsOneWidget);
    });

    testWidgets('tapping the left-side thumbnail preview opens the interactive zoomable photo modal', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Spice Garden',
        email: 'spice@garden.com',
        phone: '9876543210',
        address: '45 Anna Nagar, Chennai',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        kycStatus: 'in_review',
        fssaiCertificateUrl: 'https://storage.googleapis.com/fssai.jpg',
        gstCertificateUrl: 'https://storage.googleapis.com/gst.jpg',
        panCardUrl: 'https://storage.googleapis.com/pan.jpg',
        bankChequeUrl: 'https://storage.googleapis.com/cheque.jpg',
      ));

      await pumpFormPage(tester);

      // Verify all 4 documents show 'Document Uploaded'
      expect(find.text('Document Uploaded'), findsNWidgets(4));
      expect(find.text('Tap to view'), findsNWidgets(4));

      // Tap on PAN card left thumbnail
      final panThumb = find.byKey(const ValueKey('kyc_thumbnail_pan_card'));
      expect(panThumb, findsOneWidget);
      await tester.ensureVisible(panThumb);
      await tester.pumpAndSettle();
      await tester.tap(panThumb);
      await tester.pumpAndSettle();

      expect(find.text('PAN Card Certificate'), findsWidgets);
      expect(find.text('Uploaded Certificate Document'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Close modal
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // Tap on Bank Cheque left thumbnail
      final chequeThumb = find.byKey(const ValueKey('kyc_thumbnail_bank_cheque'));
      expect(chequeThumb, findsOneWidget);
      await tester.ensureVisible(chequeThumb);
      await tester.pumpAndSettle();
      await tester.tap(chequeThumb);
      await tester.pumpAndSettle();

      expect(find.text('Bank Cancelled Cheque / Passbook'), findsWidgets);
      expect(find.byType(InteractiveViewer), findsOneWidget);
    });

    testWidgets('renders PDF thumbnail badge and PDF document info when a PDF file is uploaded', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'Spice Garden',
        email: 'spice@garden.com',
        phone: '9876543210',
        address: '45 Anna Nagar, Chennai',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: true,
        kycStatus: 'approved',
        gstCertificateUrl: 'https://storage.googleapis.com/documents/gst_cert.pdf',
      ));

      await pumpFormPage(tester);

      final gstThumb = find.byKey(const ValueKey('kyc_thumbnail_gst_certificate'));
      expect(gstThumb, findsOneWidget);
      expect(find.text('PDF'), findsOneWidget);

      await tester.ensureVisible(gstThumb);
      await tester.pumpAndSettle();
      await tester.tap(gstThumb);
      await tester.pumpAndSettle();

      expect(find.text('PDF document format uploaded successfully'), findsOneWidget);
      expect(find.text('GST Registration Certificate'), findsWidgets);
    });

    testWidgets('renders loading spinner in thumbnail when document upload is in progress', (tester) async {
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
        isKycUploading: true,
      ));

      await pumpFormPage(tester, settle: false);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('populates initial/restored store name arun foods and allows manual editing', (tester) async {
      when(() => mockBloc.state).thenReturn(ProfileLoaded(
        storeName: 'arun foods',
        email: 'arun@foods.com',
        phone: '9876543210',
        address: '45 Anna Nagar, Chennai',
        profileImageUrl: '',
        notificationsEnabled: true,
        role: 'seller',
        createdAt: DateTime(2025, 1, 1),
        isVerified: false,
        kycStatus: 'pending',
      ));

      await pumpFormPage(tester);

      expect(find.text('arun foods'), findsOneWidget);
      expect(find.text('arun@foods.com'), findsOneWidget);

      final storeNameField = find.byType(TextFormField).first;
      await tester.enterText(storeNameField, 'arun gourmet foods');
      await tester.pumpAndSettle();

      expect(find.text('arun gourmet foods'), findsOneWidget);
    });
  });
}