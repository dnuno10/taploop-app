import 'dart:convert';

enum CalendarProviderType { calendly, googleCalendar, microsoftTeams, custom }

class CalendarIntegrationLink {
  final CalendarProviderType provider;
  final String url;
  final String? customLabel;

  const CalendarIntegrationLink({
    required this.provider,
    required this.url,
    this.customLabel,
  });

  String get displayLabel {
    if (provider != CalendarProviderType.custom) return provider.label;
    final label = customLabel?.trim();
    return label == null || label.isEmpty ? 'Otra integración' : label;
  }
}

extension CalendarProviderTypeX on CalendarProviderType {
  String get key => switch (this) {
    CalendarProviderType.calendly => 'calendly',
    CalendarProviderType.googleCalendar => 'google_calendar',
    CalendarProviderType.microsoftTeams => 'microsoft_teams',
    CalendarProviderType.custom => 'custom',
  };

  String get label => switch (this) {
    CalendarProviderType.calendly => 'Calendly',
    CalendarProviderType.googleCalendar => 'Google Calendar',
    CalendarProviderType.microsoftTeams => 'Microsoft Teams',
    CalendarProviderType.custom => 'Otro',
  };

  String get hint => switch (this) {
    CalendarProviderType.calendly => 'https://calendly.com/tu-usuario',
    CalendarProviderType.googleCalendar =>
      'https://calendar.app.google/... o enlace de cita',
    CalendarProviderType.microsoftTeams =>
      'https://teams.microsoft.com/... o Bookings',
    CalendarProviderType.custom => 'https://tu-servicio.com/tu-enlace',
  };
}

Map<CalendarProviderType, String> parseCalendarLinks(String? raw) {
  final links = parseCalendarIntegrationLinks(raw);
  return {for (final link in links) link.provider: link.url};
}

List<CalendarIntegrationLink> parseCalendarIntegrationLinks(String? raw) {
  if (raw == null || raw.trim().isEmpty) return [];
  final value = raw.trim();

  if (value.startsWith('{')) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        final out = <CalendarIntegrationLink>[];
        for (final provider in CalendarProviderType.values) {
          final link = _parseIntegrationValue(provider, decoded[provider.key]);
          if (link != null) {
            out.add(link);
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
    return [
      CalendarIntegrationLink(
        provider: CalendarProviderType.calendly,
        url: normalized,
      ),
    ];
  }
  if (normalized.contains('calendar.google.com') ||
      normalized.contains('calendar.app.google')) {
    return [
      CalendarIntegrationLink(
        provider: CalendarProviderType.googleCalendar,
        url: normalized,
      ),
    ];
  }
  if (normalized.contains('teams.microsoft.com') ||
      normalized.contains('bookings')) {
    return [
      CalendarIntegrationLink(
        provider: CalendarProviderType.microsoftTeams,
        url: normalized,
      ),
    ];
  }
  return [
    CalendarIntegrationLink(
      provider: CalendarProviderType.custom,
      url: normalized,
      customLabel: 'Otra integración',
    ),
  ];
}

String? parseCustomCalendarLabel(String? raw) {
  for (final link in parseCalendarIntegrationLinks(raw)) {
    if (link.provider == CalendarProviderType.custom) {
      return link.displayLabel;
    }
  }
  return null;
}

String encodeCalendarLinks(
  Map<CalendarProviderType, String> links, {
  String? customLabel,
}) {
  final clean = <String, dynamic>{};
  for (final entry in links.entries) {
    final url = entry.value.trim();
    if (url.isNotEmpty) {
      if (entry.key == CalendarProviderType.custom) {
        clean[entry.key.key] = {
          'label': _normalizeCustomLabel(customLabel),
          'url': normalizeCalendarUrl(url),
        };
      } else {
        clean[entry.key.key] = normalizeCalendarUrl(url);
      }
    }
  }
  if (clean.isEmpty) return '';
  return jsonEncode(clean);
}

CalendarIntegrationLink? _parseIntegrationValue(
  CalendarProviderType provider,
  Object? value,
) {
  if (value is String && value.trim().isNotEmpty) {
    return CalendarIntegrationLink(
      provider: provider,
      url: normalizeCalendarUrl(value),
      customLabel: provider == CalendarProviderType.custom
          ? 'Otra integración'
          : null,
    );
  }
  if (value is Map<String, dynamic>) {
    final url = (value['url'] ?? value['value']) as String?;
    if (url == null || url.trim().isEmpty) return null;
    final label = value['label'] as String?;
    return CalendarIntegrationLink(
      provider: provider,
      url: normalizeCalendarUrl(url),
      customLabel: provider == CalendarProviderType.custom
          ? _normalizeCustomLabel(label)
          : null,
    );
  }
  return null;
}

String _normalizeCustomLabel(String? label) {
  final value = label?.trim();
  if (value == null || value.isEmpty) return 'Otra integración';
  return value;
}

String normalizeCalendarUrl(String url) {
  final value = url.trim();
  if (value.isEmpty) return value;
  if (value.startsWith('http://') || value.startsWith('https://')) {
    return value;
  }
  return 'https://$value';
}
