import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hive_ce/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:tailorsync_v2/core/errors/failures.dart';
import 'package:tailorsync_v2/core/utils/error_handler_util.dart';
import 'package:tailorsync_v2/core/sync/models/sync_action.dart';
import 'package:tailorsync_v2/core/sync/sync_manager.dart';
import '../models/job_model.dart';

part 'job_repository.g.dart';

@riverpod
JobRepository jobRepository(Ref ref) => JobRepository(Supabase.instance.client, ref);

class JobRepository {
  final SupabaseClient _supabase;
  final Ref _ref;
  late Box<JobModel> _jobBox;
  late Box<SyncAction> _syncBox;

  JobRepository(this._supabase, this._ref) {
    _jobBox = Hive.box<JobModel>('jobs');
    _syncBox = Hive.box<SyncAction>('sync_queue');
  }

  Future<Either<Failure, JobModel?>> getJob(String id) async {
    // 1. Check local cache
    final cached = _jobBox.get(id);
    if (cached != null) return Right(cached);

    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .eq('id', id)
          .single();
      
      final job = JobModel.fromJson(response);
      await _jobBox.put(id, job); // Update cache
      return Right(job);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getRecentJobs({int limit = 10}) async {
    // 1. Return cached data immediately if available
    final cached = _jobBox.values
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    if (cached.isNotEmpty) {
      // Background fetch
      _fetchRecentRemote(limit);
      return Right(cached.take(limit).toList());
    }

    return _fetchRecentRemote(limit);
  }

  Future<Either<Failure, List<JobModel>>> _fetchRecentRemote(int limit) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      final jobs = (response as List).map((e) => JobModel.fromJson(e)).toList();
      
      // Update cache (Merge instead of clear to avoid losing offline-created jobs not yet synced)
      for (var job in jobs) {
        await _jobBox.put(job.id, job);
      }
      
      return Right(jobs);
    } catch (e, stack) {
      // If we have any cache, return it
      if (_jobBox.isNotEmpty) {
        return Right(_jobBox.values.toList());
      }
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Map<String, int>>> getStats() async {
    // Local stats for offline use
    final activeCount = _jobBox.values
        .where((j) => JobModel.activeStatuses.contains(j.status))
        .length;
    final completedCount = _jobBox.values
        .where((j) => [JobModel.statusCompleted, JobModel.statusDelivered].contains(j.status))
        .length;

    // We can still try to fetch remote stats in the background if needed, 
    // but for offline mode, local stats are what matter.
    return Right({
      'active': activeCount,
      'completed': completedCount,
    });
  }

  Future<Either<Failure, Unit>> createJob(JobModel job) async {
    try {
      final id = const Uuid().v4();
      final newJob = job.copyWith(
        id: id,
        userId: _supabase.auth.currentUser!.id,
        createdAt: DateTime.now(),
      );

      // 1. Save to local cache
      await _jobBox.put(id, newJob);
      
      // 2. Push to sync outbox
      await _pushSyncAction(
        SyncAction.actionCreate,
        'jobs',
        newJob.toJson(),
        id,
      );

      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByStatuses(List<String> statuses) async {
    // 1. Check local cache
    final cached = _jobBox.values
        .where((j) => statuses.contains(j.status))
        .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (cached.isNotEmpty) {
      _fetchByStatusesRemote(statuses);
      return Right(cached);
    }

    return _fetchByStatusesRemote(statuses);
  }

  Future<Either<Failure, List<JobModel>>> _fetchByStatusesRemote(List<String> statuses) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .inFilter('status', statuses)
          .order('created_at', ascending: false);
      
      final jobs = (response as List).map((e) => JobModel.fromJson(e)).toList();
      
      for (var job in jobs) {
        await _jobBox.put(job.id, job);
      }
      
      return Right(jobs);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByCustomerId(String customerId) async {
    final cached = _jobBox.values
        .where((j) => j.customerId == customerId)
        .toList();
    
    if (cached.isNotEmpty) return Right(cached);

    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      
      final jobs = (response as List).map((e) => JobModel.fromJson(e)).toList();
      return Right(jobs);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Unit>> updateJob(JobModel job) async {
    try {
      // 1. Save to local cache
      await _jobBox.put(job.id, job);
      
      // 2. Push to sync outbox
      await _pushSyncAction(
        SyncAction.actionUpdate,
        'jobs',
        job.toJson(),
        job.id,
      );

      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<void> _pushSyncAction(String type, String endpoint, Map<String, dynamic> payload, String targetId) async {
    final action = SyncAction(
      id: const Uuid().v4(),
      actionType: type,
      endpoint: endpoint,
      payload: payload,
      createdAt: DateTime.now(),
    );
    await _syncBox.add(action);
    
    // Trigger SyncManager
    _ref.read(syncManagerProvider).processQueue();
  }
}

@riverpod
Future<List<JobModel>> recentJobs(Ref ref) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getRecentJobs();
  return result.fold(
    (failure) => throw failure,
    (jobs) => jobs,
  );
}

@riverpod
Future<List<JobModel>> jobsByStatuses(Ref ref, List<String> statuses) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobsByStatuses(statuses);
  return result.fold(
    (failure) => throw failure,
    (jobs) => jobs,
  );
}

@riverpod
Future<List<JobModel>> jobsByCustomer(Ref ref, String customerId) async {
  final repository = ref.watch(jobRepositoryProvider);
  final result = await repository.getJobsByCustomerId(customerId);
  return result.fold(
    (failure) => throw failure,
    (jobs) => jobs,
  );
}
