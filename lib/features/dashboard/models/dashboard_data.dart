import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';

part 'dashboard_data.freezed.dart';

@freezed
class DashboardData with _$DashboardData {
  const factory DashboardData({
    required int activeJobs,
    required int completedJobs,
    required int totalCustomers,
    required double totalRevenue,
    required List<JobModel> recentJobs,
    required String userName,
  }) = _DashboardData;
}
