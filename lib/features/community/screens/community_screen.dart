import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/features/monetization/models/subscription_tier.dart';
import 'package:needlix/features/monetization/screens/upgrade_screen.dart';
import 'package:needlix/features/community/providers/community_provider.dart';
import 'package:needlix/features/community/models/community_post.dart';
import 'package:needlix/features/community/screens/create_post_screen.dart';
import 'package:needlix/features/community/screens/post_details_screen.dart';
import 'package:needlix/features/community/screens/tailor_profile_screen.dart';
import 'package:needlix/features/marketplace/screens/marketplace_requests_screen.dart';
import 'package:needlix/features/marketplace/services/marketplace_notification_service.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filterType = 'all'; // 'all', 'discussions', 'jobs', 'showroom'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final isPremium =
        profileAsync.valueOrNull?.subscriptionTier == SubscriptionTier.premium;

    if (!isPremium) {
      return _buildLockedScreen(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Needlix Community'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            const Tab(icon: Icon(Icons.people_outline), text: 'Community'),
            Badge(
              label: ref.watch(pendingMarketplaceRequestsCountProvider) > 0 
                  ? Text(ref.watch(pendingMarketplaceRequestsCountProvider).toString()) 
                  : null,
              isLabelVisible: ref.watch(pendingMarketplaceRequestsCountProvider) > 0,
              offset: const Offset(0, 4),
              child: const Tab(icon: Icon(Icons.shopping_bag_outlined), text: 'Marketplace'),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CommunityFeedTab(
            filterType: _filterType,
            onFilterChanged: (f) => setState(() => _filterType = f),
          ),
          const MarketplaceRequestsScreen(),
        ],
      ),
      floatingActionButton: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          // Only show FAB on the Community tab
          if (_tabController.index != 0) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
              ref.read(communityFeedProvider(_filterType).notifier).refresh();
            },
            child: const Icon(Icons.edit),
          );
        },
      ),
    );
  }

  Widget _buildLockedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Community')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Premium Feature Only',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join the exclusive NEEDLIX community to share ideas, templates, and collaborate with top tailors worldwide.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UpgradeScreen()),
                  );
                },
                child: const Text('Upgrade to Premium'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Community Feed Tab ─────────────────────────────────────────────────────

class _CommunityFeedTab extends ConsumerWidget {
  final String filterType;
  final ValueChanged<String> onFilterChanged;

  const _CommunityFeedTab({
    required this.filterType,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(communityFeedProvider(filterType));

    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: filterType == 'all',
                  onTap: () => onFilterChanged('all'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Discussions',
                  isSelected: filterType == 'discussions',
                  onTap: () => onFilterChanged('discussions'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Order Offers',
                  isSelected: filterType == 'jobs',
                  onTap: () => onFilterChanged('jobs'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Showroom',
                  isSelected: filterType == 'showroom',
                  onTap: () => onFilterChanged('showroom'),
                ),
              ],
            ),
          ),
        ),

        // Feed
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async =>
                ref.read(communityFeedProvider(filterType).notifier).refresh(),
            child: postsAsync.when(
              data: (posts) {
                if (posts.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 100),
                      Center(
                        child: Text(
                            'No posts found. Be the first to start a discussion!'),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: posts.length,
                  itemBuilder: (context, index) =>
                      _PostCard(post: posts[index]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  Center(child: Text('Error loading feed: $err')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Shared Widgets ──────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      backgroundColor: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.surfaceContainerHighest,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onPressed: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent),
    );
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final isJob = post.postType == 'job_offer';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => PostDetailsScreen(post: post)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TailorProfileScreen(
                            userId: post.userId,
                            userName: post.authorName ?? 'Unknown Tailor',
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2),
                      backgroundImage: post.authorLogoUrl != null
                          ? NetworkImage(post.authorLogoUrl!)
                          : null,
                      child: post.authorLogoUrl == null
                          ? Text(
                              post.authorName != null &&
                                      post.authorName!.isNotEmpty
                                  ? post.authorName![0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.primary),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TailorProfileScreen(
                              userId: post.userId,
                              userName: post.authorName ?? 'Unknown Tailor',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(post.authorName ?? 'Unknown Tailor',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(DateFormat.yMMMd().format(post.createdAt),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ),
                  if (isJob)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: const Text('ORDER OFFER',
                          style: TextStyle(
                              color: Colors.orange,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  if (post.postType == 'showroom')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: const Text('SHOWROOM',
                          style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Content
              Text(post.title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                post.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),

              if (post.imageUrls.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.imageUrls.length,
                    itemBuilder: (context, i) {
                      return Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(post.imageUrls[i]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isJob && post.budget > 0)
                    Text('Budget: ₦${post.budget.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green))
                  else
                    const SizedBox.shrink(),
                  const Row(
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text('Discuss',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
