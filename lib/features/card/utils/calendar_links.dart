import 'dart:convert';

enum CalendarProviderType { calendly, googleCalendar, microsoftTeams }

extension CalendarProviderTypeX on CalendarProviderType {
  String get key => switch (this) {
    CalendarProviderType.calendly => 'calendly',
    CalendarProviderType.googleCalendar => 'google_calendar',
    CalendarProviderType.microsoftTeams => 'microsoft_teams',
  };

  String get label => switch (this) {
    CalendarProviderType.calendly => 'Calendly',
    CalendarProviderType.googleCalendar => 'Google Calendar',
    CalendarProviderType.microsoftTeams => 'Microsoft Teams',
  };

  String get hint => switch (this) {
    CalendarProviderType.calendly => 'https://calendly.com/tu-usuario',
    CalendarProviderType.googleCalendar =>
      'https://calendar.app.google/... o enlace de cita',
    CalendarProviderType.microsoftTeams =>
      'https://teams.microsoft.com/... o Bookings',
  };
}

Map<CalendarProviderType, String> parseCalendarLinks(String? raw) {
  if (raw == null || raw.trim().isEmpty) return {};
  final value = raw.trim();

  if (value.startsWith('{')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final out = <CalendarProviderType, String>{};
        for (final provider in CalendarProviderType.values) {
          final v = decoded[provider.key];
          if (v is String && v.trim().isNotEmpty) {
            out[provider] = normalizeCalendarUrl(v);
          }
        }
        return out;
      }
    } catch (_) {
      // Fall through to legacy URL parsing.
    }
  }

  final normalized = normalizeCalendarUrl(value);
  if (normalized.contains('calendly.com')) {
    return {CalendarProviderType.calendly: normalized};
  }
  if (normalized.contains('calendar.google.com') ||
      normalized.contains('calendar.app.google')) {
    return {CalendarProviderType.googleCalendar: normalized};
  }
  if (normalized.contains('teams.microsoft.com') ||
      normalized.contains('bookings')) {
    return {CalendarProviderType.microsoftTeams: normalized};
  }
  return {CalendarProviderType.calendly: normalized};
}

String encodeCalendarLinks(Map<CalendarProviderType, String> links) {
  final clean = <String, String>{};
  for (final entry in links.entries) {
    final url = entry.value.trim();
    if (url.isNotEmpty) {
      clean[entry.key.key] = normalizeCalendarUrl(url);
    }
  }
  if (clean.isEmpty) return '';
  return jsonEncode(clean);
}

String normalizeCalendarUrl(String url) {
  final value = url.trim();
  if (value.isEmpty) return value;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return 'https://$value';
}
