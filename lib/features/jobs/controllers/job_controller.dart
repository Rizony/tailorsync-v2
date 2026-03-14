
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';

part 'job_controller.g.dart';

@riverpod
class JobController extends _$JobController {
  @override
  Future<JobModel?> build(String jobId) async {
    // Fetch the specific job by ID
    final result = await ref.read(jobRepositoryProvider).getJob(jobId);
    return result.fold(
      (failure) => throw failure,
      (job) => job,
    );
  }

  Future<void> updateStatus(String newStatus) async {
    final currentJob = state.valueOrNull;
    if (currentJob == null) return;

    // Optimistic update or waiting?
    // Let's set loading state
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedJob = currentJob.copyWith(status: newStatus);
      final result = await ref.read(jobRepositoryProvider).updateJob(updatedJob);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedJob,
      );
    });
  }

  Future<void> recordPayment(double amount, {String? note, String? paymentMethod}) async {
    final currentJob = state.valueOrNull;
    if (currentJob == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final newPayment = Payment(
        amount: amount,
        date: DateTime.now(),
        note: note,
        paymentMethod: paymentMethod,
      );

      final updatedJob = currentJob.copyWith(
        payments: [...currentJob.payments, newPayment],
        balanceDue: (currentJob.balanceDue - amount).clamp(0, double.infinity),
      );

      final result = await ref.read(jobRepositoryProvider).updateJob(updatedJob);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedJob,
      );
    });
  }

  Future<void> updateFabricStatus(String status, {String? source}) async {
    final currentJob = state.valueOrNull;
    if (currentJob == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedJob = currentJob.copyWith(
        fabricStatus: status,
        fabricSource: source ?? currentJob.fabricSource,
      );
      final result = await ref.read(jobRepositoryProvider).updateJob(updatedJob);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedJob,
      );
    });
  }

  Future<void> convertQuoteToOrder(double deposit, double total) async {
    final currentJob = state.valueOrNull;
    if (currentJob == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final initialPayment = Payment(
        amount: deposit,
        date: DateTime.now(),
        note: 'Initial Deposit (Converted from Quote)',
      );

      final updatedJob = currentJob.copyWith(
        status: JobModel.statusPending,
        price: total,
        balanceDue: (total - deposit).clamp(0, double.infinity),
        payments: [...currentJob.payments, initialPayment],
      );
      final result = await ref.read(jobRepositoryProvider).updateJob(updatedJob);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedJob,
      );
    });
  }
}
