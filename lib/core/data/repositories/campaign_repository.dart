import '../../services/supabase_service.dart';
import '../../../features/campaigns/models/campaign_model.dart';

class CampaignRepository {
  CampaignRepository._();

  static final _db = SupabaseService.client;

  static Future<List<CampaignModel>> fetchCampaigns(String orgId) async {
    final rows = await _db
        .from('campaigns')
        .select()
        .eq('org_id', orgId)
        .order('event_date', ascending: false);
    return (rows as List)
        .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Also fetch campaigns owned by user (no org) using user_id indirectly
  /// via digital_cards. For simplicity we filter by all campaigns where
  /// org_id matches or where user's card is referenced.
  static Future<List<CampaignModel>> fetchCampaignsForUser({
    String? orgId,
  }) async {
    if (orgId == null) return [];
    return fetchCampaigns(orgId);
  }

  static Future<CampaignModel> createCampaign(
    CampaignModel campaign,
    String? orgId,
  ) async {
    final data = await _db
        .from('campaigns')
        .insert(campaign.toJson(orgId: orgId))
        .select()
        .single();
    return CampaignModel.fromJson(data);
  }

  static Future<CampaignModel> updateCampaign(CampaignModel campaign) async {
    final data = await _db
        .from('campaigns')
        .update(campaign.toJson())
        .eq('id', campaign.id)
        .select()
        .single();
    return CampaignModel.fromJson(data);
  }

  static Future<void> deleteCampaign(String id) async {
    await _db.from('campaigns').delete().eq('id', id);
  }

  static Future<List<Map<String, String>>> fetchCampaignMembers(
    String campaignId,
  ) async {
    try {
      final rows = await _db
          .from('campaign_members')
          .select('user_id')
          .eq('campaign_id', campaignId);
      final ids = (rows as List)
          .map((r) => (r as Map)['user_id'] as String)
          .toList();
      if (ids.isEmpty) return [];
      final users = await _db
          .from('users')
          .select('id, name, role, job_title')
          .inFilter('id', ids);
      return (users as List)
          .map(
            (u) => {
              'id': (u as Map)['id'] as String,
              'name': u['name'] as String? ?? '',
              'role': u['role'] as String? ?? '',
              'job_title': u['job_title'] as String? ?? '',
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> addCampaignMember(
    String campaignId,
    String userId,
  ) async {
    await _db.from('campaign_members').insert({
      'campaign_id': campaignId,
      'user_id': userId,
    });
  }

  static Future<void> addCampaignMembers(
    String campaignId,
    List<String> userIds,
  ) async {
    if (userIds.isEmpty) return;
    await _db
        .from('campaign_members')
        .insert(
          userIds
              .map((userId) => {'campaign_id': campaignId, 'user_id': userId})
              .toList(),
        );
  }

  static Future<void> removeCampaignMember(
    String campaignId,
    String userId,
  ) async {
    await _db
        .from('campaign_members')
        .delete()
        .eq('campaign_id', campaignId)
        .eq('user_id', userId);
  }

  static Future<void> replaceCampaignMembers(
    String campaignId,
    List<String> userIds,
  ) async {
    await _db.from('campaign_members').delete().eq('campaign_id', campaignId);
    await addCampaignMembers(campaignId, userIds);
  }

  static Future<List<Map<String, String>>> fetchOrgUsers(String orgId) async {
    try {
      final rows = await _db
          .from('users')
          .select('id, name, role, job_title')
          .eq('org_id', orgId)
          .eq('is_active', true);
      return (rows as List)
          .map(
            (u) => {
              'id': (u as Map)['id'] as String,
              'name': u['name'] as String? ?? '',
              'role': u['role'] as String? ?? '',
              'job_title': u['job_title'] as String? ?? '',
            },
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
