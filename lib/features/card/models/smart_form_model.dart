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

enum SmartFormIncludedField {
  name,
  email,
  phone,
  company,
  message,
  budget,
  date,
}

SmartFormIncludedField? _includedFieldFromString(String? value) {
  return switch (value) {
    'name' => SmartFormIncludedField.name,
    'email' => SmartFormIncludedField.email,
    'phone' => SmartFormIncludedField.phone,
    'company' => SmartFormIncludedField.company,
    'message' => SmartFormIncludedField.message,
    'budget' => SmartFormIncludedField.budget,
    'date' => SmartFormIncludedField.date,
    _ => null,
  };
}

extension SmartFormIncludedFieldX on SmartFormIncludedField {
  String get label => switch (this) {
    SmartFormIncludedField.name => 'Nombre',
    SmartFormIncludedField.email => 'Email',
    SmartFormIncludedField.phone => 'Teléfono',
    SmartFormIncludedField.company => 'Empresa',
    SmartFormIncludedField.message => 'Mensaje',
    SmartFormIncludedField.budget => 'Presupuesto',
    SmartFormIncludedField.date => 'Fecha',
  };

  String get placeholder => switch (this) {
    SmartFormIncludedField.name => 'Tu nombre',
    SmartFormIncludedField.email => 'tu@email.com',
    SmartFormIncludedField.phone => '+52 000 000 0000',
    SmartFormIncludedField.company => 'Empresa',
    SmartFormIncludedField.message => 'Cuéntanos qué necesitas',
    SmartFormIncludedField.budget => 'Presupuesto estimado',
    SmartFormIncludedField.date => 'Fecha deseada',
  };

  SmartFormFieldType get fieldType => switch (this) {
    SmartFormIncludedField.email => SmartFormFieldType.email,
    SmartFormIncludedField.phone => SmartFormFieldType.phone,
    SmartFormIncludedField.message => SmartFormFieldType.textarea,
    SmartFormIncludedField.budget => SmartFormFieldType.number,
    SmartFormIncludedField.name ||
    SmartFormIncludedField.company ||
    SmartFormIncludedField.date => SmartFormFieldType.text,
  };
}

const List<SmartFormIncludedField> smartFormIncludedFieldOrder = [
  SmartFormIncludedField.name,
  SmartFormIncludedField.email,
  SmartFormIncludedField.phone,
  SmartFormIncludedField.company,
  SmartFormIncludedField.message,
  SmartFormIncludedField.budget,
  SmartFormIncludedField.date,
];

List<SmartFormIncludedField> _includedFieldsFromJson(
  Object? raw,
  List<SmartFormFieldModel> legacyFields,
) {
  final parsed = raw is List
      ? raw
            .map((value) => _includedFieldFromString(value as String?))
            .whereType<SmartFormIncludedField>()
            .toSet()
      : <SmartFormIncludedField>{};
  if (parsed.isNotEmpty) {
    return smartFormIncludedFieldOrder
        .where((field) => parsed.contains(field))
        .toList();
  }

  final legacy = <SmartFormIncludedField>{};
  for (final field in legacyFields) {
    final normalized = field.label.toLowerCase();
    if (normalized.contains('nombre')) legacy.add(SmartFormIncludedField.name);
    if (normalized.contains('mail') || normalized.contains('correo')) {
      legacy.add(SmartFormIncludedField.email);
    }
    if (normalized.contains('tel') || normalized.contains('cel')) {
      legacy.add(SmartFormIncludedField.phone);
    }
    if (normalized.contains('empresa')) {
      legacy.add(SmartFormIncludedField.company);
    }
    if (normalized.contains('mensaje')) {
      legacy.add(SmartFormIncludedField.message);
    }
    if (normalized.contains('presupuesto')) {
      legacy.add(SmartFormIncludedField.budget);
    }
    if (normalized.contains('fecha')) legacy.add(SmartFormIncludedField.date);
  }
  return smartFormIncludedFieldOrder
      .where((field) => legacy.contains(field))
      .toList();
}

List<SmartFormFieldModel> _fieldsFromIncludedFields(
  String formId,
  List<SmartFormIncludedField> includedFields,
) {
  return includedFields.asMap().entries.map((entry) {
    final field = entry.value;
    return SmartFormFieldModel(
      id: '${formId}_${field.name}',
      formId: formId,
      fieldType: field.fieldType,
      label: field.label,
      placeholder: field.placeholder,
      isRequired: true,
      sortOrder: entry.key,
    );
  }).toList();
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
  final String? description;
  final String successMessage;
  final bool isActive;
  final List<SmartFormIncludedField> includedFields;
  final List<SmartFormFieldModel> fields;

  const SmartFormModel({
    required this.id,
    required this.cardId,
    required this.name,
    this.description,
    this.successMessage = 'Gracias, recibimos tu información.',
    this.isActive = true,
    this.includedFields = const [],
    this.fields = const [],
  });

  factory SmartFormModel.fromJson(
    Map<String, dynamic> json, {
    List<SmartFormFieldModel> fields = const [],
  }) {
    final includedFields = _includedFieldsFromJson(
      json['included_fields'],
      fields,
    );
    final resolvedFields = includedFields.isNotEmpty
        ? _fieldsFromIncludedFields(json['id'] as String, includedFields)
        : fields;
    return SmartFormModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String,
      name: json['name'] as String? ?? 'Formulario',
      description: json['description'] as String?,
      successMessage:
          json['success_message'] as String? ??
          'Gracias, recibimos tu información.',
      isActive: json['is_active'] as bool? ?? true,
      includedFields: includedFields,
      fields: resolvedFields,
    );
  }

  Map<String, dynamic> toJson({String? cardId}) => {
    if (cardId != null) 'card_id': cardId,
    'name': name,
    'description': description,
    'success_message': successMessage,
    'included_fields': includedFields.map((field) => field.name).toList(),
    'is_active': isActive,
  };

  SmartFormModel copyWith({
    String? id,
    String? cardId,
    String? name,
    String? description,
    String? successMessage,
    bool? isActive,
    List<SmartFormIncludedField>? includedFields,
    List<SmartFormFieldModel>? fields,
  }) {
    final nextIncludedFields = includedFields ?? this.includedFields;
    final nextId = id ?? this.id;
    return SmartFormModel(
      id: nextId,
      cardId: cardId ?? this.cardId,
      name: name ?? this.name,
      description: description ?? this.description,
      successMessage: successMessage ?? this.successMessage,
      isActive: isActive ?? this.isActive,
      includedFields: nextIncludedFields,
      fields: fields ?? _fieldsFromIncludedFields(nextId, nextIncludedFields),
    );
  }
}
