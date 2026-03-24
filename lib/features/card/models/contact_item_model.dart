enum ContactType { phone, whatsapp, email, address, website }

ContactType _contactTypeFromString(String s) {
  switch (s) {
    case 'whatsapp':
      return ContactType.whatsapp;
    case 'email':
      return ContactType.email;
    case 'address':
      return ContactType.address;
    case 'website':
      return ContactType.website;
    default:
      return ContactType.phone;
  }
}

class ContactItemModel {
  final String id;
  final ContactType type;
  final String value;
  final String? label;
  final bool isVisible;
  final int sortOrder;

  const ContactItemModel({
    required this.id,
    required this.type,
    required this.value,
    this.label,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  factory ContactItemModel.fromJson(Map<String, dynamic> json) {
    return ContactItemModel(
      id: json['id'] as String,
      type: _contactTypeFromString(json['type'] as String? ?? 'phone'),
      value: json['value'] as String? ?? '',
      label: json['label'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({String? cardId}) => {
    if (cardId != null) 'card_id': cardId,
    'type': type.name,
    'value': value,
    if (label != null) 'label': label,
    'is_visible': isVisible,
    'sort_order': sortOrder,
  };

  String get defaultLabel {
    switch (type) {
      case ContactType.phone:
        return 'Teléfono';
      case ContactType.whatsapp:
        return 'WhatsApp';
      case ContactType.email:
        return 'Email';
      case ContactType.address:
        return 'Dirección';
      case ContactType.website:
        return 'Sitio web';
    }
  }

  String get displayLabel => label ?? defaultLabel;

  ContactItemModel copyWith({
    String? id,
    ContactType? type,
    String? value,
    String? label,
    bool? isVisible,
    int? sortOrder,
  }) {
    return ContactItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      value: value ?? this.value,
      label: label ?? this.label,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
