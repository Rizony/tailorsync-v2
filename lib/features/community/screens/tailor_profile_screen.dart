import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/core/auth/providers/profile_provider.dart';
import 'package:needlix/core/utils/snackbar_util.dart';
import 'package:needlix/features/community/providers/community_provider.dart';
import 'package:needlix/features/community/repositories/community_repository.dart';

class TailorProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  final String userName;

  const TailorProfileScreen({super.key, required this.userId, required this.userName});

  @override
  ConsumerState<TailorProfileScreen> createState() => _TailorProfileScreenState();
}

class _TailorProfileScreenState extends ConsumerState<TailorProfileScreen> {
  bool get _isSelf {
    final currentUser = Supabase.instance.client.auth.currentUser;
    return currentUser != null && currentUser.id == widget.userId;
  }

  void _showRatingDialog() {
    int rating = 5;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateBuilder) {
            return AlertDialog(
              title: Text('Rate ${widget.userName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: () {
                          setStateBuilder(() => rating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Write a review (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final review = reviewController.text.trim();
                    final currentUser = Supabase.instance.client.auth.currentUser;
                    if (currentUser == null) return;

                    Navigator.pop(ctx);

                    try {
                      await ref.read(communityRepositoryProvider).rateUser(
                        widget.userId,
                        currentUser.id,
                        rating,
                        review.isNotEmpty ? review : null,
                        null,
                      );
                      if (!context.mounted) return;
                      showSuccessSnackBar(context, 'Rating submitted!');
                      ref.read(userRatingsProvider(widget.userId).notifier).refresh();
                    } catch (e) {
                      if (!context.mounted) return;
                      showErrorSnackBar(context, 'Failed to submit rating: $e');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final ratingsAsync = ref.watch(userRatingsProvider(widget.userId));
    final profileAsync = ref.watch(publicProfileProvider(widget.userId));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userName}\'s Profile'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: profileAsync.when(
        data: (profile) {
          return ratingsAsync.when(
            data: (ratings) {
              final totalReviews = ratings.length;
              final averageRating = totalReviews > 0 
                  ? ratings.fold<int>(0, (sum, r) => sum + r.rating) / totalReviews 
                  : 0.0;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- PROFILE HEADER ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            backgroundImage: (profile?.logoUrl != null && profile!.logoUrl!.isNotEmpty) 
                                ? NetworkImage(profile.logoUrl!) 
                                : null,
                            child: (profile?.logoUrl == null || profile!.logoUrl!.isEmpty)
                                ? Text(
                                    widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                                    style: TextStyle(fontSize: 48, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(profile?.shopName ?? widget.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          if (profile?.shopName != null && profile!.shopName != widget.userName)
                            Text(widget.userName, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(height: 12),
                          // Stats & Rating
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      averageRating > 0 ? averageRating.toStringAsFixed(1) : 'No Ratings',
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (profile?.yearsOfExperience != null && profile!.yearsOfExperience > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${profile.yearsOfExperience} yrs exp',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          if (!_isSelf)
                            SizedBox(
                              width: 200,
                              child: ElevatedButton.icon(
                                onPressed: _showRatingDialog,
                                icon: const Icon(Icons.star_rate),
                                label: const Text('Rate this Tailor'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // --- ABOUT / BIO ---
                    if (profile?.bio != null && profile!.bio!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(profile.bio!, style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87)),
                          ],
                        ),
                      ),

                    // --- SPECIALTIES ---
                    if (profile?.specialties != null && profile!.specialties.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Specialties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: profile.specialties.map((s) => Chip(
                                label: Text(s, style: const TextStyle(fontSize: 12)),
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              )).toList(),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    const SizedBox(height: 24),
                    
                    // --- PORTFOLIO / SHOWROOM ---
                    if (profile?.portfolioUrls != null && profile!.portfolioUrls.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text('Portfolio / Showroom', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: profile.portfolioUrls.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  width: 250,
                                  margin: const EdgeInsets.only(right: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(profile.portfolioUrls[i]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.0),
                            child: Text('Tap to view full work in Marketplace', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),
                    const Divider(),
                    
                    // --- REVIEWS LIST ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                      child: Text('Reviews ($totalReviews)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    
                    if (totalReviews == 0)
                       Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text('No reviews yet for ${widget.userName}.', style: const TextStyle(color: Colors.grey)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ratings.length,
                        itemBuilder: (context, index) {
                          final r = ratings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                            elevation: 0,
                            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundImage: r.raterLogoUrl != null ? NetworkImage(r.raterLogoUrl!) : null,
                                        child: r.raterLogoUrl == null ? Text(r.raterName?.substring(0, 1).toUpperCase() ?? '?', style: const TextStyle(fontSize: 10)) : null,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(r.raterName ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                                      Text(DateFormat.yMMMd().format(r.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: List.generate(5, (i) => Icon(
                                      i < r.rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    )),
                                  ),
                                  if (r.review != null && r.review!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(r.review!, style: const TextStyle(fontSize: 14, height: 1.4)),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error loading reviews: $e')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }
}
