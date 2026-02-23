import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tailorsync_v2/core/errors/failures.dart';
import 'package:tailorsync_v2/core/utils/error_handler_util.dart';
import '../models/job_model.dart';

part 'job_repository.g.dart';

@riverpod
JobRepository jobRepository(Ref ref) => JobRepository(Supabase.instance.client);

class JobRepository {
  final SupabaseClient _supabase;

  JobRepository(this._supabase);

  Future<Either<Failure, JobModel?>> getJob(String id) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .eq('id', id)
          .single();
      
      return Right(JobModel.fromJson(response));
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getRecentJobs({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .order('created_at', ascending: false)
          .limit(limit);
      
      return Right((response as List).map((e) => JobModel.fromJson(e)).toList());
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Map<String, int>>> getStats() async {
    try {
      final activeCount = await _supabase
          .from('jobs')
          .count(CountOption.exact)
          .inFilter('status', JobModel.activeStatuses);
          
      final completedCount = await _supabase
          .from('jobs')
          .count(CountOption.exact)
          .inFilter('status', [JobModel.statusCompleted, JobModel.statusDelivered]);

      return Right({
        'active': activeCount,
        'completed': completedCount,
      });
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Unit>> createJob(JobModel job) async {
    try {
      await _supabase.from('jobs').insert(job.toJson()..remove('id'));
      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByStatuses(List<String> statuses) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select('*, customers(full_name)')
          .inFilter('status', statuses)
          .order('created_at', ascending: false);
      
      return Right((response as List).map((e) => JobModel.fromJson(e)).toList());
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, List<JobModel>>> getJobsByCustomerId(String customerId) async {
    try {
      final response = await _supabase
          .from('jobs')
          .select()
          .eq('customer_id', customerId)
          .order('created_at', ascending: false);
      
      return Right((response as List).map((e) => JobModel.fromJson(e)).toList());
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
  }

  Future<Either<Failure, Unit>> updateJob(JobModel job) async {
    try {
      await _supabase
          .from('jobs')
          .update(job.toJson()..remove('id')..remove('created_at'))
          .eq('id', job.id);
      return const Right(unit);
    } catch (e, stack) {
      return Left(ErrorHandler.handle(e, stack));
    }
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
