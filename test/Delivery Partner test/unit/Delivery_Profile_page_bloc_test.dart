import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_bloc.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_event.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_state.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_repository.dart';
import 'package:food_delivery_app/features/Delivery%20Partner%20Bloc%20Architecture/Delivery_Profile_page/Delivery_Profile_page_service.dart';

class MockDeliveryProfileRepository extends Mock
    implements DeliveryProfileRepositoryBase {}

class MockDeliveryProfileService extends Mock
    implements DeliveryProfileServiceBase {}

/// Loaded profile fixture consistent with the completion engine and
/// checklist builder so that bloc-recomputed values match exactly.
DeliveryProfileState defaultLoaded() {
  const base = DeliveryProfileState(
    status: DeliveryProfileStatus.loaded,
    fullName: 'Ravi Kumar',
    phone: '+91 98765 43210',
    email: 'ravi@test.com',
    dob: '15-08-1995',
    vehicleType: 'scooter',
    licenseNumber: 'TN07 20010012345',
    verificationStatuses: DeliveryProfileRepository.defaultVerificationStatuses,
    documents: DeliveryProfileRepository.defaultDocuments,
  );
  return base.copyWith(
    completionPercentage: 50,
    checklist: DeliveryProfileRepository.buildDefaultChecklist(profile: base),
  );
}

void main() {
  late MockDeliveryProfileRepository mockRepository;
  late MockDeliveryProfileService mockService;

  List<DeliveryProfileDocument> docsWithInsurance(
    DeliveryProfileDocumentStatus status,
    double progress,
  ) {
    return [
      for (final d in DeliveryProfileRepository.defaultDocuments)
        d.id == 'insurance'
            ? d.copyWith(status: status, progress: progress)
            : d,
    ];
  }

  setUp(() {
    mockRepository = MockDeliveryProfileRepository();
    mockService = MockDeliveryProfileService();
    registerFallbackValue(const DeliveryProfileState());
  });

  group('DeliveryProfileBloc Unit Tests', () {
    test(
      'initial state starts at initial status with default profile data',
      () {
        final bloc = DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
        expect(bloc.state.status, DeliveryProfileStatus.initial);
        expect(bloc.state.fullName, '');
        expect(bloc.state.completionPercentage, 0);
        expect(bloc.state.documents, isEmpty);
        expect(bloc.state.verificationStatuses['phone'], isFalse);
        bloc.close();
      },
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits loading then loaded state on InitEvent success',
      build: () {
        when(
          () => mockRepository.fetchProfile(),
        ).thenAnswer((_) async => defaultLoaded());
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileInitEvent()),
      expect: () => [
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
        defaultLoaded(),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits error state when InitEvent fails',
      build: () {
        when(
          () => mockRepository.fetchProfile(),
        ).thenThrow(Exception('Network down'));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileInitEvent()),
      expect: () => [
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
        const DeliveryProfileState(
          status: DeliveryProfileStatus.error,
          errorMessage: 'Network down',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits empty state when profile has no data',
      build: () {
        when(() => mockRepository.fetchProfile()).thenAnswer(
          (_) async => const DeliveryProfileState(
            status: DeliveryProfileStatus.loaded,
            fullName: '',
            phone: '',
            email: '',
          ),
        );
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      act: (b) => b.add(const DeliveryProfileInitEvent()),
      expect: () => [
        const DeliveryProfileState(status: DeliveryProfileStatus.loading),
        const DeliveryProfileState(
          status: DeliveryProfileStatus.empty,
          fullName: '',
          phone: '',
          email: '',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'recalculates completion percentage when a field is updated',
      build: () =>
          DeliveryProfileBloc(repository: mockRepository, service: mockService),
      seed: defaultLoaded,
      act: (b) => b.add(
        const DeliveryProfileUpdateFieldEvent(
          field: 'vehicleNumber',
          value: 'TN 01 AB 1234',
        ),
      ),
      expect: () => [
        defaultLoaded().copyWith(
          vehicleNumber: 'TN 01 AB 1234',
          completionPercentage: 58,
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'completes vehicle checklist when all vehicle fields are filled',
      build: () =>
          DeliveryProfileBloc(repository: mockRepository, service: mockService),
      seed: defaultLoaded,
      act: (b) {
        b.add(
          const DeliveryProfileUpdateFieldEvent(
            field: 'vehicleNumber',
            value: 'TN 01 AB 1234',
          ),
        );
        b.add(
          const DeliveryProfileUpdateFieldEvent(
            field: 'licenseValidTill',
            value: '12-09-2030',
          ),
        );
      },
      expect: () => [
        defaultLoaded().copyWith(
          vehicleNumber: 'TN 01 AB 1234',
          completionPercentage: 58,
        ),
        defaultLoaded().copyWith(
          vehicleNumber: 'TN 01 AB 1234',
          licenseValidTill: '12-09-2030',
          completionPercentage: 67,
          checklist: const [
            DeliveryProfileChecklistItem(
              id: 'personalDetails',
              label: 'Personal details completed',
              isComplete: true,
            ),
            DeliveryProfileChecklistItem(
              id: 'vehicleInfo',
              label: 'Vehicle information provided',
              isComplete: true,
            ),
            DeliveryProfileChecklistItem(
              id: 'drivingLicense',
              label: 'Driving license uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'vehicleRc',
              label: 'Vehicle RC uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'insurance',
              label: 'Insurance uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'panCard',
              label: 'PAN card uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'documentVerification',
              label: 'Document verification approved',
              isComplete: false,
            ),
          ],
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'updates avatar path on PickImageEvent',
      build: () {
        when(
          () => mockRepository.pickProfileImage(),
        ).thenAnswer((_) async => '/tmp/avatar.png');
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: defaultLoaded,
      act: (b) => b.add(const DeliveryProfilePickImageEvent()),
      expect: () => [defaultLoaded().copyWith(avatarPath: '/tmp/avatar.png')],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'uploads a document via chunked stream and marks it uploaded',
      build: () {
        when(
          () => mockService.chunkedUpload('insurance'),
        ).thenAnswer((_) => Stream.fromIterable([1.0]));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: defaultLoaded,
      act: (b) => b.add(const DeliveryProfileUploadDocumentEvent('insurance')),
      expect: () => [
        defaultLoaded().copyWith(
          documents: docsWithInsurance(
            DeliveryProfileDocumentStatus.uploading,
            0.0,
          ),
          uploadProgress: 0.0,
        ),
        defaultLoaded().copyWith(
          documents: docsWithInsurance(
            DeliveryProfileDocumentStatus.uploading,
            1.0,
          ),
          uploadProgress: 1.0,
        ),
        defaultLoaded().copyWith(
          documents: docsWithInsurance(
            DeliveryProfileDocumentStatus.uploaded,
            1.0,
          ),
          uploadProgress: 1.0,
          completionPercentage: 58,
          checklist: const [
            DeliveryProfileChecklistItem(
              id: 'personalDetails',
              label: 'Personal details completed',
              isComplete: true,
            ),
            DeliveryProfileChecklistItem(
              id: 'vehicleInfo',
              label: 'Vehicle information provided',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'drivingLicense',
              label: 'Driving license uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'vehicleRc',
              label: 'Vehicle RC uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'insurance',
              label: 'Insurance uploaded',
              isComplete: true,
            ),
            DeliveryProfileChecklistItem(
              id: 'panCard',
              label: 'PAN card uploaded',
              isComplete: false,
            ),
            DeliveryProfileChecklistItem(
              id: 'documentVerification',
              label: 'Document verification approved',
              isComplete: false,
            ),
          ],
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'reverts document to pending when upload throws',
      build: () {
        when(
          () => mockService.chunkedUpload('insurance'),
        ).thenThrow(Exception('Upload failed'));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: defaultLoaded,
      act: (b) => b.add(const DeliveryProfileUploadDocumentEvent('insurance')),
      expect: () => [
        defaultLoaded().copyWith(
          documents: docsWithInsurance(
            DeliveryProfileDocumentStatus.uploading,
            0.0,
          ),
          uploadProgress: 0.0,
        ),
        defaultLoaded().copyWith(
          documents: docsWithInsurance(
            DeliveryProfileDocumentStatus.notUploaded,
            0.0,
          ),
          errorMessage: 'Upload failed: Upload failed',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'saves profile and emits saved saveStatus on SaveEvent',
      build: () {
        when(() => mockRepository.saveProfile(any())).thenAnswer((_) async {});
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: defaultLoaded,
      act: (b) => b.add(const DeliveryProfileSaveEvent()),
      expect: () => [
        defaultLoaded().copyWith(saveStatus: DeliveryProfileSaveStatus.saving),
        defaultLoaded().copyWith(saveStatus: DeliveryProfileSaveStatus.saved),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'emits failed saveStatus when save throws',
      build: () {
        when(
          () => mockRepository.saveProfile(any()),
        ).thenThrow(Exception('Disk full'));
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: defaultLoaded,
      act: (b) => b.add(const DeliveryProfileSaveEvent()),
      expect: () => [
        defaultLoaded().copyWith(saveStatus: DeliveryProfileSaveStatus.saving),
        defaultLoaded().copyWith(
          saveStatus: DeliveryProfileSaveStatus.failed,
          errorMessage: 'Disk full',
        ),
      ],
    );

    blocTest<DeliveryProfileBloc, DeliveryProfileState>(
      'reloads the profile when RetryEvent is dispatched',
      build: () {
        when(
          () => mockRepository.fetchProfile(),
        ).thenAnswer((_) async => defaultLoaded());
        return DeliveryProfileBloc(
          repository: mockRepository,
          service: mockService,
        );
      },
      seed: () => defaultLoaded().copyWith(status: DeliveryProfileStatus.error),
      act: (b) => b.add(const DeliveryProfileRetryEvent()),
      expect: () => [
        defaultLoaded().copyWith(status: DeliveryProfileStatus.loading),
        defaultLoaded(),
      ],
    );
  });
}
