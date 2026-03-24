import '../../services/supabase_service.dart';
import '../../../features/card/models/digital_card_model.dart';
import '../../../features/card/models/contact_item_model.dart';
import '../../../features/card/models/social_link_model.dart';
import '../../../features/card/models/smart_form_model.dart';

class CardRepository {
  CardRepository._();

  static final _db = SupabaseService.client;

  // ─── Fetch card with contacts & social links ─────────────────────────────

  static Future<DigitalCardModel?> fetchCard(String cardId) async {
    final cardData = await _db
        .from('digital_cards')
        .select()
        .eq('id', cardId)
        .single();

    final contacts = await _db
        .from('contact_items')
        .select()
        .eq('card_id', cardId)
        .order('sort_order');

    final socials = await _db
        .from('social_links')
        .select()
        .eq('card_id', cardId)
        .order('sort_order');

    return DigitalCardModel.fromJson(
      cardData,
      contactItems: (contacts as List)
          .map((e) => ContactItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialLinks: (socials as List)
          .map((e) => SocialLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── Fetch public card by slug (no auth required) ────────────────────────

  static Future<DigitalCardModel?> fetchBySlug(String slug) async {
    final rows = await _db
        .from('digital_cards')
        .select()
        .eq('public_slug', slug)
        .eq('is_active', true)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return _fetchWithItems(rows.first);
  }

  // ─── Fetch public card by user_id (permanent NFC URL) ────────────────────
  // This never breaks even if the user changes their slug.

  static Future<DigitalCardModel?> fetchByUserId(String userId) async {
    final rows = await _db
        .from('digital_cards')
        .select()
        .eq('user_id', userId)
        .eq('is_active', true)
        .limit(1);

    if ((rows as List).isEmpty) return null;
    return _fetchWithItems(rows.first);
  }

  // ─── Check NFC serial status ─────────────────────────────────────────────
  // Returns: 'assigned' | 'unassigned' | 'not_found'

  static Future<String> checkNfcSerial(String serial) async {
    final rows = await _db
        .from('nfc_cards')
        .select('is_assigned')
        .eq('serial', serial)
        .limit(1);
    if ((rows as List).isEmpty) return 'not_found';
    final assigned = rows.first['is_assigned'] as bool? ?? false;
    return assigned ? 'assigned' : 'unassigned';
  }

  // ─── Fetch public card by NFC serial (pre-manufactured cards) ────────────

  static Future<DigitalCardModel?> fetchByNfcSerial(String serial) async {
    final result = await _db.rpc(
      'get_user_id_by_nfc_serial',
      params: {'p_serial': serial},
    );
    final userId = result as String?;
    if (userId == null || userId.isEmpty) return null;
    return fetchByUserId(userId);
  }

  // ─── Activate NFC card (link serial → current user) ──────────────────────

  static Future<bool> activateNfcCard(String serial) async {
    final res = await _db
        .from('nfc_cards')
        .update({
          'user_id': _db.auth.currentUser!.id,
          'is_assigned': true,
          'assigned_at': DateTime.now().toIso8601String(),
        })
        .eq('serial', serial)
        .eq('is_assigned', false)
        .select();
    return (res as List).isNotEmpty;
  }

  // ─── Shared helper ────────────────────────────────────────────────────────

  static Future<DigitalCardModel> _fetchWithItems(
    Map<String, dynamic> cardJson,
  ) async {
    final cardId = cardJson['id'] as String;

    final contacts = await _db
        .from('contact_items')
        .select()
        .eq('card_id', cardId)
        .eq('is_visible', true)
        .order('sort_order');

    final socials = await _db
        .from('social_links')
        .select()
        .eq('card_id', cardId)
        .eq('is_visible', true)
        .order('sort_order');

    return DigitalCardModel.fromJson(
      cardJson,
      contactItems: (contacts as List)
          .map((e) => ContactItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      socialLinks: (socials as List)
          .map((e) => SocialLinkModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // ─── Save card fields ─────────────────────────────────────────────────────

  static Future<void> saveCard(DigitalCardModel card) async {
    await _db.from('digital_cards').update(card.toJson()).eq('id', card.id);
  }

  // ─── Contact items ────────────────────────────────────────────────────────

  static Future<ContactItemModel> addContactItem(
    String cardId,
    ContactItemModel item,
  ) async {
    final last = await _db
        .from('contact_items')
        .select('sort_order')
        .eq('card_id', cardId)
        .order('sort_order', ascending: false)
        .limit(1);
    final nextOrder = (last as List).isEmpty
        ? 0
        : ((last.first['sort_order'] as num?)?.toInt() ?? 0) + 1;

    final data = await _db
        .from('contact_items')
        .insert(item.copyWith(sortOrder: nextOrder).toJson(cardId: cardId))
        .select()
        .single();
    return ContactItemModel.fromJson(data);
  }

  static Future<void> updateContactItem(ContactItemModel item) async {
    await _db.from('contact_items').update(item.toJson()).eq('id', item.id);
  }

  static Future<void> deleteContactItem(String itemId) async {
    await _db.from('contact_items').delete().eq('id', itemId);
  }

  static Future<void> reorderContactItems(List<ContactItemModel> items) async {
    for (var i = 0; i < items.length; i++) {
      await _db
          .from('contact_items')
          .update({'sort_order': i})
          .eq('id', items[i].id);
    }
  }

  // ─── Social links ─────────────────────────────────────────────────────────

  static Future<SocialLinkModel> addSocialLink(
    String cardId,
    SocialLinkModel link,
  ) async {
    final last = await _db
        .from('social_links')
        .select('sort_order')
        .eq('card_id', cardId)
        .order('sort_order', ascending: false)
        .limit(1);
    final nextOrder = (last as List).isEmpty
        ? 0
        : ((last.first['sort_order'] as num?)?.toInt() ?? 0) + 1;

    final data = await _db
        .from('social_links')
        .insert(link.copyWith(sortOrder: nextOrder).toJson(cardId: cardId))
        .select()
        .single();
    return SocialLinkModel.fromJson(data);
  }

  static Future<void> updateSocialLink(SocialLinkModel link) async {
    await _db.from('social_links').update(link.toJson()).eq('id', link.id);
  }

  static Future<void> deleteSocialLink(String linkId) async {
    await _db.from('social_links').delete().eq('id', linkId);
  }

  static Future<void> reorderSocialLinks(List<SocialLinkModel> links) async {
    for (var i = 0; i < links.length; i++) {
      await _db
          .from('social_links')
          .update({'sort_order': i})
          .eq('id', links[i].id);
    }
  }

  // ─── Smart forms ──────────────────────────────────────────────────────────

  static Future<List<SmartFormModel>> fetchSmartForms(String cardId) async {
    final formsRows = await _db
        .from('smart_forms')
        .select()
        .eq('card_id', cardId)
        .order('created_at');

    final forms = <SmartFormModel>[];
    for (final row in (formsRows as List)) {
      final formId = row['id'] as String;
      final fieldsRows = await _db
          .from('smart_form_fields')
          .select()
          .eq('form_id', formId)
          .order('sort_order');
      final fields = (fieldsRows as List)
          .map((e) => SmartFormFieldModel.fromJson(e as Map<String, dynamic>))
          .toList();
      forms.add(
        SmartFormModel.fromJson(row as Map<String, dynamic>, fields: fields),
      );
    }
    return forms;
  }

  static Future<SmartFormModel> createSmartForm(
    String cardId,
    String name,
  ) async {
    final data = await _db
        .from('smart_forms')
        .insert({'card_id': cardId, 'name': name, 'is_active': true})
        .select()
        .single();
    return SmartFormModel.fromJson(data, fields: const []);
  }

  static Future<void> updateSmartForm(SmartFormModel form) async {
    await _db.from('smart_forms').update(form.toJson()).eq('id', form.id);
  }

  static Future<void> deleteSmartForm(String formId) async {
    await _db.from('smart_form_fields').delete().eq('form_id', formId);
    await _db.from('smart_forms').delete().eq('id', formId);
  }

  static Future<SmartFormFieldModel> addSmartFormField(
    String formId,
    SmartFormFieldModel field,
  ) async {
    final last = await _db
        .from('smart_form_fields')
        .select('sort_order')
        .eq('form_id', formId)
        .order('sort_order', ascending: false)
        .limit(1);
    final nextOrder = (last as List).isEmpty
        ? 0
        : ((last.first['sort_order'] as num?)?.toInt() ?? 0) + 1;

    final data = await _db
        .from('smart_form_fields')
        .insert(field.copyWith(sortOrder: nextOrder).toJson(formId: formId))
        .select()
        .single();
    return SmartFormFieldModel.fromJson(data);
  }

  static Future<void> updateSmartFormField(SmartFormFieldModel field) async {
    await _db
        .from('smart_form_fields')
        .update(field.toJson())
        .eq('id', field.id);
  }

  static Future<void> deleteSmartFormField(String fieldId) async {
    await _db.from('smart_form_fields').delete().eq('id', fieldId);
  }

  static Future<void> reorderSmartFormFields(
    List<SmartFormFieldModel> fields,
  ) async {
    for (var i = 0; i < fields.length; i++) {
      await _db
          .from('smart_form_fields')
          .update({'sort_order': i})
          .eq('id', fields[i].id);
    }
  }
}
