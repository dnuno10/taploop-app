enum SmartFormFieldType { text, email, phone, textarea, number }

SmartFormFieldType _fieldTypeFromString(String s) {
  switch (s) {
    case 'email':
      return SmartFormFieldType.email;
    case 'phone':
      return SmartFormFieldType.phone;
    case 'textarea':
      return SmartFormFieldType.textarea;
    case 'number':
      return SmartFormFieldType.number;
    case 'select':
      return SmartFormFieldType.text;
    default:
      return SmartFormFieldType.text;
  }
}

class SmartFormFieldModel {
  final String id;
  final String formId;
  final SmartFormFieldType fieldType;
  final String label;
  final String? placeholder;
  final bool isRequired;
  final int sortOrder;
  final Map<String, dynamic>? options;

  const SmartFormFieldModel({
    required this.id,
    required this.formId,
    required this.fieldType,
    required this.label,
    this.placeholder,
    this.isRequired = false,
    this.sortOrder = 0,
    this.options,
  });

  factory SmartFormFieldModel.fromJson(Map<String, dynamic> json) {
    return SmartFormFieldModel(
      id: json['id'] as String,
      formId: json['form_id'] as String,
      fieldType: _fieldTypeFromString(json['field_type'] as String? ?? 'text'),
      label: json['label'] as String? ?? '',
      placeholder: json['placeholder'] as String?,
      isRequired: json['is_required'] as bool? ?? false,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      options: (json['options'] as Map?)?.cast<String, dynamic>(),
    );
  }

  Map<String, dynamic> toJson({String? formId}) => {
    if (formId != null) 'form_id': formId,
    'field_type': fieldType.name,
    'label': label,
    if (placeholder != null) 'placeholder': placeholder,
    'is_required': isRequired,
    'sort_order': sortOrder,
    if (options != null) 'options': options,
  };

  SmartFormFieldModel copyWith({
    String? id,
    String? formId,
    SmartFormFieldType? fieldType,
    String? label,
    String? placeholder,
    bool? isRequired,
    int? sortOrder,
    Map<String, dynamic>? options,
  }) {
    return SmartFormFieldModel(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      fieldType: fieldType ?? this.fieldType,
      label: label ?? this.label,
      placeholder: placeholder ?? this.placeholder,
      isRequired: isRequired ?? this.isRequired,
      sortOrder: sortOrder ?? this.sortOrder,
      options: options ?? this.options,
    );
  }
}

class SmartFormModel {
  final String id;
  final String cardId;
  final String name;
  final bool isActive;
  final List<SmartFormFieldModel> fields;

  const SmartFormModel({
    required this.id,
    required this.cardId,
    required this.name,
    this.isActive = true,
    this.fields = const [],
  });

  factory SmartFormModel.fromJson(
    Map<String, dynamic> json, {
    List<SmartFormFieldModel> fields = const [],
  }) {
    return SmartFormModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      name: json['name'] as String? ?? 'Formulario',
      isActive: json['is_active'] as bool? ?? true,
      fields: fields,
    );
  }

  Map<String, dynamic> toJson({String? cardId}) => {
    if (cardId != null) 'card_id': cardId,
    'name': name,
    'is_active': isActive,
  };

  SmartFormModel copyWith({
    String? id,
    String? cardId,
    String? name,
    bool? isActive,
    List<SmartFormFieldModel>? fields,
  }) {
    return SmartFormModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
      fields: fields ?? this.fields,
    );
  }
}
