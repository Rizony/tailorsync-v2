import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:needlix/features/community/models/community_post.dart';
import 'package:needlix/features/community/models/community_application.dart';
import 'package:needlix/features/community/models/community_rating.dart';
import 'package:needlix/features/community/models/community_comment.dart';

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepository(Supabase.instance.client);
});

class CommunityRepository {
  final SupabaseClient _supabase;

  CommunityRepository(this._supabase);

  // --- POSTS ---
  Future<List<CommunityPost>> fetchPosts({String? filterType}) async {
    var query = _supabase.from('community_posts').select('''
      *,
      profiles:user_id(full_name, shop_name, logo_url)
    ''');

    if (filterType != null && filterType != 'all') {
      if (filterType == 'jobs') {
        query = query.eq('post_type', 'job_offer');
      } else if (filterType == 'discussions') {
        query = query.eq('post_type', 'discussion');
      } else if (filterType == 'marketplace') {
        query = query.eq('post_type', 'showroom');
      }
    }

    final data = await query.order('created_at', ascending: false) as List<dynamic>;
    return data.map((json) {
      final post = CommunityPost.fromJson(json as Map<String, dynamic>);
      // Extract author name from auth_user relation if available
      final meta = json['profiles'];
      final String? name = meta is Map<String, dynamic> 
          ? (meta['shop_name'] ?? meta['full_name']) as String? 
          : null;
      final String? logoUrl = meta is Map<String, dynamic> 
          ? meta['logo_url'] as String? 
          : null;
      return post.copyWith(authorName: name, authorLogoUrl: logoUrl);
    }).toList();
  }

  Future<CommunityPost> createPost(CommunityPost post) async {
    final insertData = post.toJson()
      ..remove('id')
      ..remove('created_at');

    final data = await _supabase
        .from('community_posts')
        .insert(insertData)
        .select()
        .single();
    return CommunityPost.fromJson(data);
  }
  
  Future<void> deletePost(String postId) async {
    await _supabase.from('community_posts').delete().eq('id', postId);
  }

  // --- APPLICATIONS ---
  Future<List<CommunityApplication>> fetchApplications(String postId) async {
    final data = await _supabase.from('community_applications').select('''
      *,
      profiles:applicant_id(full_name, shop_name, logo_url)
    ''').eq('post_id', postId).order('created_at', ascending: true) as List<dynamic>;

    return data.map((json) {
      final app = CommunityApplication.fromJson(json as Map<String, dynamic>);
      final meta = json['profiles'];
      final String? name = meta is Map<String, dynamic> 
          ? (meta['shop_name'] ?? meta['full_name']) as String? 
          : null;
      final String? logoUrl = meta is Map<String, dynamic> 
          ? meta['logo_url'] as String? 
          : null;
      return app.copyWith(applicantName: name, applicantLogoUrl: logoUrl);
    }).toList();
  }

  Future<void> applyToJob(String postId, String applicantId, String coverLetter) async {
    await _supabase.from('community_applications').insert({
      'post_id': postId,
      'applicant_id': applicantId,
      'cover_letter': coverLetter,
      'status': 'pending',
    });
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _supabase
        .from('community_applications')
        .update({'status': status})
        .eq('id', applicationId);
  }

  // --- COMMENTS ---
  Future<List<CommunityComment>> fetchComments(String postId) async {
    final data = await _supabase.from('community_comments').select('''
      *,
      profiles:user_id(full_name, shop_name, logo_url)
    ''').eq('post_id', postId).order('created_at', ascending: true) as List<dynamic>;

    return data.map((json) {
      final comment = CommunityComment.fromJson(json as Map<String, dynamic>);
      final meta = json['profiles'];
      final String? name = meta is Map<String, dynamic> 
          ? (meta['shop_name'] ?? meta['full_name']) as String? 
          : null;
      final String? logoUrl = meta is Map<String, dynamic> 
          ? meta['logo_url'] as String? 
          : null;
      return comment.copyWith(authorName: name, authorLogoUrl: logoUrl);
    }).toList();
  }

  Future<void> addComment(String postId, String userId, String content) async {
    await _supabase.from('community_comments').insert({
      'post_id': postId,
      'user_id': userId,
      'content': content,
    });
  }

  // --- RATINGS ---
  Future<void> rateUser(String rateeId, String raterId, int rating, String? review, String? postId) async {
    try {
      await _supabase.from('community_ratings').insert({
        'rater_id': raterId,
        'ratee_id': rateeId,
        'post_id': postId,
        'rating': rating,
        'review': review,
      });
    } catch (e) {
      // If it's a unique constraint violation, update instead
      if (e is PostgrestException && e.code == '23505') {
        await _supabase.from('community_ratings')
            .update({'rating': rating, 'review': review})
            .match({
              'rater_id': raterId,
              'ratee_id': rateeId,
              if (postId != null) 'post_id': postId,
            });
      } else {
        rethrow;
      }
    }
  }

  Future<List<CommunityRating>> fetchUserRatings(String userId) async {
    final data = await _supabase.from('community_ratings').select('''
        *,
        profiles:rater_id(full_name, shop_name, logo_url)
      ''').eq('ratee_id', userId).order('created_at', ascending: false) as List<dynamic>;

    return data.map((json) {
      final rating = CommunityRating.fromJson(json as Map<String, dynamic>);
      final meta = json['profiles'];
      final String? name = meta is Map<String, dynamic> 
          ? (meta['shop_name'] ?? meta['full_name']) as String? 
          : null;
      final String? logoUrl = meta is Map<String, dynamic> 
          ? meta['logo_url'] as String? 
          : null;
      return rating.copyWith(raterName: name, raterLogoUrl: logoUrl);
    }).toList();
  }
}
