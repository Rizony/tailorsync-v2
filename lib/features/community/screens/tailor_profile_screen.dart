import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';
import 'package:tailorsync_v2/features/community/providers/community_provider.dart';
import 'package:tailorsync_v2/features/community/repositories/community_repository.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tailor Profile'),
      ),
      body: ratingsAsync.when(
        data: (ratings) {
          final totalReviews = ratings.length;
          final averageRating = totalReviews > 0 
              ? ratings.fold<int>(0, (sum, r) => sum + r.rating) / totalReviews 
              : 0.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                // --- PROFILE HEADER ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                          style: const TextStyle(fontSize: 36, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(widget.userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Stars
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 4),
                          Text(
                            averageRating > 0 ? averageRating.toStringAsFixed(1) : 'No Ratings',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          if (totalReviews > 0)
                            Text('  ($totalReviews reviews)', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!_isSelf)
                        ElevatedButton.icon(
                          onPressed: _showRatingDialog,
                          icon: const Icon(Icons.star_rate),
                          label: const Text('Leave a Review'),
                        ),
                    ],
                  ),
                ),
                
                // --- REVIEWS LIST ---
                if (totalReviews == 0)
                   Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text('No reviews yet for ${widget.userName}.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ratings.length,
                    itemBuilder: (context, index) {
                      final r = ratings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(r.raterName ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(DateFormat.yMMMd().format(r.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (i) => Icon(
                                  i < r.rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                )),
                              ),
                              if (r.review != null && r.review!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                Text(r.review!, style: const TextStyle(fontSize: 14)),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
