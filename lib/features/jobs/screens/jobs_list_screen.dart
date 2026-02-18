import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import 'package:tailorsync_v2/features/jobs/screens/create_job_screen.dart';
import 'package:tailorsync_v2/features/jobs/screens/job_details_screen.dart';

class JobsListScreen extends ConsumerStatefulWidget {
  const JobsListScreen({super.key});

  @override
  ConsumerState<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends ConsumerState<JobsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Quotes'),
            Tab(text: 'Completed'),
            Tab(text: 'Canceled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _JobsList(statuses: JobModel.activeStatuses),
          _JobsList(statuses: [JobModel.statusQuote]),
          _JobsList(statuses: [JobModel.statusCompleted, JobModel.statusDelivered]),
          _JobsList(statuses: [JobModel.statusCanceled]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateJobScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _JobsList extends ConsumerWidget {
  final List<String> statuses;
  const _JobsList({required this.statuses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsFuture = ref.watch(jobsByStatusesProvider(statuses));

    return jobsFuture.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: jobs.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final job = jobs[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat.yMMMd().format(job.createdAt)),
                    const SizedBox(height: 4),
                    _buildStatusChip(job.status),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('₦${job.price}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (statuses.contains(JobModel.statusPending) || 
                        statuses.contains(JobModel.statusInProgress))
                    Text(
                      'Due: ${DateFormat.MMMd().format(job.dueDate)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: _isOverdue(job) ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
                onTap: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailsScreen(job: job),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  bool _isOverdue(JobModel job) {
    return job.status == JobModel.statusPending && 
           job.dueDate.isBefore(DateTime.now());
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case JobModel.statusPending: color = Colors.orange; break;
      case JobModel.statusInProgress: color = Colors.blue; break;
      case JobModel.statusFitting: color = Colors.purple; break;
      case JobModel.statusAdjustment: color = Colors.amber; break;
      case JobModel.statusCompleted: color = Colors.green; break;
      case JobModel.statusDelivered: color = Colors.grey; break;
      case JobModel.statusCanceled: color = Colors.red; break;
      case JobModel.statusQuote: color = Colors.cyan; break;
      default: color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10),
      ),
    );
  }
}
