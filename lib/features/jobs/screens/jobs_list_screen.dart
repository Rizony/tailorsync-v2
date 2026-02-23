import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tailorsync_v2/features/jobs/models/job_model.dart';
import 'package:tailorsync_v2/features/jobs/repositories/job_repository.dart';
import 'package:tailorsync_v2/features/jobs/screens/create_job_screen.dart';
import 'package:tailorsync_v2/features/jobs/screens/job_details_screen.dart';
import 'package:tailorsync_v2/core/auth/providers/profile_provider.dart';

class JobsListScreen extends ConsumerStatefulWidget {
  const JobsListScreen({super.key});

  @override
  ConsumerState<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends ConsumerState<JobsListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Orders or Customers',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(onPressed: () => setState(() => _searchController.clear()), icon: const Icon(Icons.clear))
                  : null,
              ),
              onChanged: (val) => setState(() {}),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _JobsList(statuses: JobModel.activeStatuses, searchQuery: _searchController.text),
                _JobsList(statuses: const [JobModel.statusQuote], searchQuery: _searchController.text),
                _JobsList(statuses: const [JobModel.statusCompleted, JobModel.statusDelivered], searchQuery: _searchController.text),
                _JobsList(statuses: const [JobModel.statusCanceled], searchQuery: _searchController.text),
              ],
            ),
          ),
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
  final String searchQuery;
  const _JobsList({required this.statuses, required this.searchQuery});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsFuture = ref.watch(jobsByStatusesProvider(statuses));
    final profile = ref.watch(profileNotifierProvider).valueOrNull;

    return jobsFuture.when(
      data: (jobs) {
        final filteredJobs = jobs.where((job) {
           final query = searchQuery.toLowerCase();
           final titleMatch = job.title.toLowerCase().contains(query);
           final customerMatch = job.customerName?.toLowerCase().contains(query) ?? false;
           return titleMatch || customerMatch;
        }).toList();

        if (filteredJobs.isEmpty) {
          return const Center(child: Text('No orders found'));
        }
        return ListView.builder(
          itemCount: filteredJobs.length,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 80), // Added bottom padding for FAB
          itemBuilder: (context, index) {
            final job = filteredJobs[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: ListTile(
                  title: Text(job.title, style: Theme.of(context).textTheme.titleMedium),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (job.customerName != null) 
                         Text(job.customerName!, style: Theme.of(context).textTheme.bodyMedium),
                      Text(DateFormat.yMMMd().format(job.createdAt), style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      _buildStatusChip(context, job.status),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${profile?.currencySymbol ?? '₦'}${job.price}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                      if (statuses.contains(JobModel.statusPending) || 
                          statuses.contains(JobModel.statusInProgress))
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Due: ${DateFormat.MMMd().format(job.dueDate)}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _isOverdue(job) ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
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

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color;
    switch (status) {
      case JobModel.statusPending: color = Colors.orange; break;
      case JobModel.statusInProgress: color = Theme.of(context).colorScheme.primary; break;
      case JobModel.statusFitting: color = Colors.purple; break;
      case JobModel.statusAdjustment: color = Colors.amber; break;
      case JobModel.statusCompleted: color = Theme.of(context).colorScheme.secondary; break; // Use secondary (Orange) or Green? User said SuccessColor exists now.
      case JobModel.statusDelivered: color = Colors.grey; break;
      case JobModel.statusCanceled: color = Theme.of(context).colorScheme.error; break;
      case JobModel.statusQuote: color = Colors.cyan; break;
      default: color = Colors.grey;
    }

    if (status == JobModel.statusCompleted) {
         color = const Color(0xFF43A047); 
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
