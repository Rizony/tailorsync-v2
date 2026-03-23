import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:needlix/features/community/models/community_post.dart';
import 'package:needlix/features/community/models/community_application.dart';
import 'package:needlix/features/community/models/community_comment.dart';
import 'package:needlix/features/community/models/community_rating.dart';
import 'package:needlix/features/community/repositories/community_repository.dart';

part 'community_provider.g.dart';

// --- POST FEED ---
@riverpod
class CommunityFeed extends _$CommunityFeed {
  @override
  FutureOr<List<CommunityPost>> build(String filterType) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.fetchPosts(filterType: filterType);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.watch(communityRepositoryProvider).fetchPosts(filterType: filterType));
  }
}

// --- COMMENTS FOR A POST ---
@riverpod
class PostComments extends _$PostComments {
  @override
  FutureOr<List<CommunityComment>> build(String postId) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.fetchComments(postId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.watch(communityRepositoryProvider).fetchComments(postId));
  }
}

// --- APPLICATIONS FOR A POST ---
@riverpod
class PostApplications extends _$PostApplications {
  @override
  FutureOr<List<CommunityApplication>> build(String postId) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.fetchApplications(postId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.watch(communityRepositoryProvider).fetchApplications(postId));
  }
}

// --- USER RATINGS ---
@riverpod
class UserRatings extends _$UserRatings {
  @override
  FutureOr<List<CommunityRating>> build(String userId) async {
    final repo = ref.watch(communityRepositoryProvider);
    return repo.fetchUserRatings(userId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ref.watch(communityRepositoryProvider).fetchUserRatings(userId));
  }
}
