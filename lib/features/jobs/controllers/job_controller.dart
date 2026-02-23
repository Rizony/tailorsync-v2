
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

  Future<void> convertQuoteToOrder(double deposit, double total) async {
    final currentJob = state.valueOrNull;
    if (currentJob == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final updatedJob = currentJob.copyWith(
        status: JobModel.statusPending,
        balanceDue: total - deposit,
        // In a real app, we might also record the deposit as a transaction here
        // or trigger another repository call.
      );
      final result = await ref.read(jobRepositoryProvider).updateJob(updatedJob);
      return result.fold(
        (failure) => throw failure,
        (_) => updatedJob,
      );
    });
  }
}
