import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tailorsync_v2/core/utils/snackbar_util.dart';
import 'package:tailorsync_v2/features/community/models/community_post.dart';
import 'package:tailorsync_v2/features/community/providers/community_provider.dart';
import 'package:tailorsync_v2/features/community/repositories/community_repository.dart';
import 'package:tailorsync_v2/features/community/screens/tailor_profile_screen.dart';

class PostDetailsScreen extends ConsumerStatefulWidget {
  final CommunityPost post;

  const PostDetailsScreen({super.key, required this.post});

  @override
  ConsumerState<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends ConsumerState<PostDetailsScreen> {
  final _commentController = TextEditingController();
  final _applicationController = TextEditingController();
  bool _isSubmitting = false;

  late CommunityPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _applicationController.dispose();
    super.dispose();
  }

  bool get _isJob => _post.postType == 'job_offer';
  bool get _isAuthor {
    final currentUser = Supabase.instance.client.auth.currentUser;
    return currentUser != null && currentUser.id == _post.userId;
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('Not signed in');

      await ref.read(communityRepositoryProvider).addComment(_post.id, user.id, text);
      _commentController.clear();
      
      // Refresh comments
      ref.read(postCommentsProvider(_post.id).notifier).refresh();
      if (!mounted) return;
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error adding comment: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _applyForJob() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final coverLetter = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController();
        return AlertDialog(
          title: const Text('Apply for Job'),
          content: TextField(
            controller: ctrl,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Introduce yourself and state why you are the best tailor for this job...',
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Submit Application'),
            ),
          ],
        );
      },
    );

    if (coverLetter == null || coverLetter.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(communityRepositoryProvider).applyToJob(_post.id, user.id, coverLetter);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Application submitted successfully!');
      // Refresh applications if needed
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Error submitting application: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _updateApplicationStatus(String applicationId, String status) async {
    try {
      await ref.read(communityRepositoryProvider).updateApplicationStatus(applicationId, status);
      if (!mounted) return;
      showSuccessSnackBar(context, 'Application $status!');
      ref.invalidate(postApplicationsProvider(_post.id));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, 'Failed to update status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isJob ? 'Job Details' : 'Discussion'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- POST HEADER ---
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TailorProfileScreen(
                                userId: _post.userId,
                                userName: _post.authorName ?? 'Unknown Tailor',
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                          backgroundImage: _post.authorLogoUrl != null ? NetworkImage(_post.authorLogoUrl!) : null,
                          child: _post.authorLogoUrl == null
                              ? Text(
                                  _post.authorName != null && _post.authorName!.isNotEmpty ? _post.authorName![0].toUpperCase() : '?',
                                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TailorProfileScreen(
                                  userId: _post.userId,
                                  userName: _post.authorName ?? 'Unknown Tailor',
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_post.authorName ?? 'Unknown Tailor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(DateFormat.yMMMd().format(_post.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // --- POST CONTENT ---
                  Text(_post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  if (_isJob && _post.budget > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.payments, size: 20, color: Colors.green),
                          const SizedBox(width: 8),
                          Text('Budget: ₦${_post.budget.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(_post.content, style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  const Divider(),
                  
                  // --- ACTIONS (APPLY OR VIEW APPLICANTS) ---
                  if (_isJob) ...[
                    if (_isAuthor)
                      _buildApplicantsList()
                    else
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _applyForJob,
                          icon: const Icon(Icons.send),
                          label: const Text('Apply for this Job'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    const Divider(),
                  ],

                  // --- COMMENTS SECTION ---
                  const Text('Discussion Thread', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildCommentsList(),
                ],
              ),
            ),
          ),
          
          // --- COMMENT INPUT BAR ---
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 12, bottom: MediaQuery.of(context).padding.bottom + 12
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: _isSubmitting 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                      : const Icon(Icons.send, color: Color(0xFF1E78D2)),
                  onPressed: _isSubmitting ? null : _submitComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantsList() {
    final appsAsync = ref.watch(postApplicationsProvider(_post.id));
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Job Applicants', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        appsAsync.when(
          data: (apps) {
            if (apps.isEmpty) {
              return const Padding(padding: EdgeInsets.all(16.0), child: Text('No applications yet.', style: TextStyle(color: Colors.grey)));
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: apps.length,
              itemBuilder: (context, index) {
                final app = apps[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TailorProfileScreen(
                              userId: app.applicantId,
                              userName: app.applicantName ?? 'Unknown Tailor',
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundImage: app.applicantLogoUrl != null ? NetworkImage(app.applicantLogoUrl!) : null,
                        child: app.applicantLogoUrl == null ? Text(app.applicantName?.substring(0, 1).toUpperCase() ?? '?') : null,
                      ),
                    ),
                    title: Text(app.applicantName ?? 'Unknown Tailor'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(app.coverLetter, maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (app.status != 'pending')
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text('Status: ${app.status.toUpperCase()}', style: TextStyle(
                              color: app.status == 'accepted' ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            )),
                          ),
                      ],
                    ),
                    trailing: app.status == 'pending' ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                          onPressed: () => _updateApplicationStatus(app.id, 'accepted'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                          onPressed: () => _updateApplicationStatus(app.id, 'rejected'),
                        ),
                      ],
                    ) : null,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text('Application from ${app.applicantName}'),
                          content: Text(app.coverLetter),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (err, stack) => Text('Error loading applications: $err'),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    final commentsAsync = ref.watch(postCommentsProvider(_post.id));
    
    return commentsAsync.when(
      data: (comments) {
        if (comments.isEmpty) return const Text('No comments yet. Be the first to reply!');
        
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TailorProfileScreen(
                            userId: comment.userId,
                            userName: comment.authorName ?? 'Unknown Tailor',
                          ),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: comment.authorLogoUrl != null ? NetworkImage(comment.authorLogoUrl!) : null,
                      child: comment.authorLogoUrl == null
                          ? Text(comment.authorName?.substring(0, 1).toUpperCase() ?? '?', style: const TextStyle(fontSize: 12))
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12).copyWith(topLeft: Radius.zero),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TailorProfileScreen(
                                        userId: comment.userId,
                                        userName: comment.authorName ?? 'Unknown Tailor',
                                      ),
                                    ),
                                  );
                                },
                                child: Text(comment.authorName ?? 'Unknown Tailor', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Text(DateFormat.yMd().add_jm().format(comment.createdAt), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(comment.content, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }
}
