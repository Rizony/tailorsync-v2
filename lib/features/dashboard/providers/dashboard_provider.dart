import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/core/auth/models/app_user.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import '../models/dashboard_data.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardStats(Ref ref) async {
  // Fetch data in parallel
  final jobsFuture = ref.watch(jobRepositoryProvider.future);
  final customersFuture = ref.watch(customerRepositoryProvider.future);
  final profileFuture = ref.watch(profileNotifierProvider.future);

  final results = await Future.wait([
    jobsFuture,
    customersFuture,
    profileFuture,
  ]);
  
  final jobs = results[0] as List; // List<JobModel>
  final customers = results[1] as List; // List<Customer>
  final profile = results[2] as AppUser?;

  // Calculate stats
  final activeJobs = jobs.where((job) => job.status == 'pending').length;
  final completedJobs = jobs.where((job) => job.status == 'completed').length;
  final totalRevenue = jobs
      .where((job) => job.status == 'completed') // Assuming only completed count towards realized revenue? Or all? Usually completed.
      .fold(0.0, (sum, job) => sum + (job.price ?? 0));

  // Get recent 5
  final recentJobs = jobs.take(5).toList();

  return DashboardData(
    activeJobs: activeJobs,
    completedJobs: completedJobs,
    totalCustomers: customers.length,
    totalRevenue: totalRevenue,
    recentJobs: List.from(recentJobs), // specific cast if needed
    userName: profile?.fullName ?? 'Tailor',
  );
}
