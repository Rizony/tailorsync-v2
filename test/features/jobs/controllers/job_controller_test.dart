
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tailorsync_v2/features/jobs/controllers/job_controller.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';

// Mock the repository class directly - much easier now!
class MockJobRepository extends Mock implements JobRepository {}

void main() {
  late MockJobRepository mockRepository;
  late ProviderContainer container;

  // Helpers
  final testJob = JobModel(
    id: '1',
    userId: 'user1',
    customerId: 'cust1',
    title: 'Test Suit',
    price: 10000,
    dueDate: DateTime.now(),
    status: JobModel.statusQuote,
    items: [],
    images: [],
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockJobRepository();
    container = ProviderContainer(
      overrides: [
        jobRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
    
    // Register fallback values
    registerFallbackValue(testJob);
  });

  tearDown(() {
    container.dispose();
  });

  test('JobController.build fetches job from repository', () async {
    when(() => mockRepository.getJob('1')).thenAnswer((_) async => Right(testJob));

    // Read the controller (this triggers build)
    final job = await container.read(jobControllerProvider('1').future);

    expect(job, testJob);
    verify(() => mockRepository.getJob('1')).called(1);
  });

  test('updateStatus calls repository and updates state', () async {
    when(() => mockRepository.getJob('1')).thenAnswer((_) async => Right(testJob));
    when(() => mockRepository.updateJob(any())).thenAnswer((_) async => const Right(unit));

    // initialize
    await container.read(jobControllerProvider('1').future);
    
    // Act
    await container.read(jobControllerProvider('1').notifier).updateStatus(JobModel.statusInProgress);

    // Assert
    verify(() => mockRepository.updateJob(any(that: isA<JobModel>()
      .having((j) => j.status, 'status', JobModel.statusInProgress)
    ))).called(1);

    // State should be updated
    final newState = container.read(jobControllerProvider('1'));
    expect(newState.value?.status, JobModel.statusInProgress);
  });

  test('convertQuoteToOrder updates status and balance', () async {
    when(() => mockRepository.getJob('1')).thenAnswer((_) async => Right(testJob));
    when(() => mockRepository.updateJob(any())).thenAnswer((_) async => const Right(unit));

    // initialize
    await container.read(jobControllerProvider('1').future);
    
    // Act: Deposit 2000, Total 10000 -> Balance 8000
    await container.read(jobControllerProvider('1').notifier).convertQuoteToOrder(2000, 10000);

    // Assert
    verify(() => mockRepository.updateJob(any(that: isA<JobModel>()
      .having((j) => j.status, 'status', JobModel.statusPending)
      .having((j) => j.balanceDue, 'balanceDue', 8000)
    ))).called(1);
  });
}
