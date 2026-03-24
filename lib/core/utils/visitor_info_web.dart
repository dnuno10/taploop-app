import 'dart:convert';
import 'dart:html' as html;
import 'dart:math';

const _visitorIdKey = 'taploop.visitor_id';
const _leadSubmittedPrefix = 'taploop.lead_submitted';

String _localSubmissionKey({required String cardId, required String formId}) {
  final vid = html.window.localStorage[_visitorIdKey] ?? 'unknown';
  return '$_leadSubmittedPrefix.$cardId.$formId.$vid';
}

String _generateVisitorId() {
  final now = DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  final rnd = Random().nextInt(0x7fffffff).toRadixString(16);
  return 'v$now$rnd';
}

Future<String?> getStableVisitorId() async {
  try {
    final existing = html.window.localStorage[_visitorIdKey];
    if (existing != null && existing.isNotEmpty) return existing;
    final id = _generateVisitorId();
    html.window.localStorage[_visitorIdKey] = id;
    return id;
  } catch (_) {
    return null;
  }
}

Future<bool> hasLocalLeadSubmission({
  required String cardId,
  required String formId,
}) async {
  try {
    await getStableVisitorId();
    return html.window.localStorage[_localSubmissionKey(
          cardId: cardId,
          formId: formId,
        )] ==
        '1';
  } catch (_) {
    return false;
  }
}

Future<void> markLocalLeadSubmission({
  required String cardId,
  required String formId,
}) async {
  try {
    await getStableVisitorId();
    html.window.localStorage[_localSubmissionKey(
          cardId: cardId,
          formId: formId,
        )] =
        '1';
  } catch (_) {}
}

/// Web implementation: detects device type from userAgent and fetches
/// IP-based geolocation from ipapi.co (free tier, CORS-enabled).
Future<Map<String, String?>> collectVisitorInfo() async {
  final ua = html.window.navigator.userAgent;
  final lc = ua.toLowerCase();
  final visitorId = await getStableVisitorId();
  final tz = DateTime.now().timeZoneName;
  final offset = DateTime.now().timeZoneOffset.inMinutes;

  final String device;
  if (lc.contains('iphone') ||
      (lc.contains('android') && lc.contains('mobile'))) {
    device = 'Móvil';
  } else if (lc.contains('ipad') || lc.contains('tablet')) {
    device = 'Tablet';
  } else {
    device = 'Escritorio';
  }

  String? ip, city, country;
  try {
    final req = await html.HttpRequest.request(
      'https://ipapi.co/json/',
      method: 'GET',
    );
    if (req.status == 200 && req.responseText != null) {
      final data = json.decode(req.responseText!) as Map<String, dynamic>;
      ip = data['ip'] as String?;
      city = data['city'] as String?;
      country = data['country_name'] as String?;
    }
  } catch (_) {}

  final descriptor = [
    device,
    if (visitorId != null) 'cid:$visitorId',
    'tz:$tz',
    'offset:$offset',
  ].join('|');

  return {
    'device': descriptor,
    'ip': ip,
    'city': city,
    'country': country,
    'visitor_id': visitorId,
    'timezone_name': tz,
    'timezone_offset_min': '$offset',
  };
}
