import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/job_model.dart';

part 'job_repository.g.dart';

@riverpod
class JobRepository extends _$JobRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<JobModel>> build() async {
    return getRecentJobs();
  }

  Future<List<JobModel>> getRecentJobs({int limit = 10}) async {
    final response = await _supabase
        .from('jobs')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    
    return (response as List).map((e) => JobModel.fromJson(e)).toList();
  }

  Future<Map<String, int>> getStats() async {
    // This is a simplified way to get stats. 
    // For large datasets, you might replacing with a .count() query or a database function.
    
    final activeCount = await _supabase
        .from('jobs')
        .count(CountOption.exact)
        .inFilter('status', JobModel.activeStatuses);
        
    final completedCount = await _supabase
        .from('jobs')
        .count(CountOption.exact)
        .inFilter('status', [JobModel.statusCompleted, JobModel.statusDelivered]);

    return {
      'active': activeCount,
      'completed': completedCount,
    };
  }

  Future<void> createJob(JobModel job) async {
    await _supabase.from('jobs').insert(job.toJson()..remove('id')); // Let DB generate ID
    ref.invalidateSelf();
  }
  Future<List<JobModel>> getJobsByStatuses(List<String> statuses) async {
    final response = await _supabase
        .from('jobs')
        .select()
        .inFilter('status', statuses)
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => JobModel.fromJson(e)).toList();
  }

  Future<List<JobModel>> getJobsByCustomerId(String customerId) async {
    final response = await _supabase
        .from('jobs')
        .select()
        .eq('customer_id', customerId)
        .order('created_at', ascending: false);
    
    return (response as List).map((e) => JobModel.fromJson(e)).toList();
  }

  Future<void> updateJob(JobModel job) async {
    await _supabase
        .from('jobs')
        .update(job.toJson()..remove('id')..remove('created_at'))
        .eq('id', job.id);
        
    ref.invalidateSelf();
  }
}

@riverpod
@riverpod
Future<List<JobModel>> jobsByStatuses(Ref ref, List<String> statuses) async {
  final repository = ref.watch(jobRepositoryProvider.notifier);
  return repository.getJobsByStatuses(statuses);
}

@riverpod
Future<List<JobModel>> jobsByCustomer(Ref ref, String customerId) async {
  final repository = ref.watch(jobRepositoryProvider.notifier);
  return repository.getJobsByCustomerId(customerId);
}
