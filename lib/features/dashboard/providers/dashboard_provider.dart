import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tailorsync_v2/core/auth/models/app_user.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';
import 'package:tailorsync_v2/features/customers/repositories/customer_repository.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import '../models/dashboard_data.dart';

part 'dashboard_provider.g.dart';

@riverpod
Future<DashboardData> dashboardStats(Ref ref) async {
  // Fetch data in parallel
  final jobsFuture = ref.watch(recentJobsProvider.future);
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

  // Calculate urgent jobs (due in less than 48 hours, active status check)
  final now = DateTime.now();
  final fortyEightHoursFromNow = now.add(const Duration(hours: 48));

  final urgentJobs = (jobs as List<JobModel>).where((job) {
    if (job.status == JobModel.statusCompleted || job.status == JobModel.statusDelivered || job.status == JobModel.statusCanceled) {
      return false;
    }
    return job.dueDate.isBefore(fortyEightHoursFromNow) && job.dueDate.isAfter(now.subtract(const Duration(days: 30)));
  }).toList();
  
  // Sort urgent jobs by due date
  urgentJobs.sort((a, b) => a.dueDate.compareTo(b.dueDate));

  // Get recent 5
  final recentJobs = jobs.take(5).toList();

  return DashboardData(
    activeJobs: activeJobs,
    completedJobs: completedJobs,
    totalCustomers: customers.length,
    totalRevenue: totalRevenue,
    recentJobs: List.from(recentJobs), // specific cast if needed
    urgentJobs: List.from(urgentJobs),
    userName: profile?.fullName ?? 'Tailor',
  );
}
