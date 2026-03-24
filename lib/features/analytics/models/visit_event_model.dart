class VisitEventModel {
  final String id;
  final String? cardId;
  final DateTime timestamp;
  final String? ip;
  final String? device;
  final String? city;
  final String? country;
  final String? source; // nfc, qr, link, contact, social, form
  final String? label;

  const VisitEventModel({
    required this.id,
    this.cardId,
    required this.timestamp,
    this.ip,
    this.device,
    this.city,
    this.country,
    this.source,
    this.label,
  });

  factory VisitEventModel.fromJson(Map<String, dynamic> json) {
    return VisitEventModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String?,
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'] as String)?.toLocal() ??
                DateTime.now())
          : DateTime.now(),
      ip: json['ip'] as String?,
      device: json['device'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      source: json['source'] as String?,
      label: json['label'] as String?,
    );
  }

  String get locationDisplay {
    if (city != null && country != null) return '$city, $country';
    if (city != null) return city!;
    if (country != null) return country!;
    return 'Desconocido';
  }

  // Backward-compatible alias used by some older views/widgets.
  String get location => locationDisplay;

  String get formattedTime {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String get formattedDate {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${timestamp.day} ${months[timestamp.month - 1]}';
  }
}
