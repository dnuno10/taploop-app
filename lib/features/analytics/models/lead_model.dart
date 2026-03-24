enum LeadStatus { hot, warm, cold }

enum LeadAction {
  visitedProfile,
  clickedLinkedIn,
  clickedWebsite,
  clickedWhatsApp,
  downloadedContact,
  filledForm,
}

class LeadActionEvent {
  final LeadAction action;
  final DateTime timestamp;
  final String? customLabel;

  const LeadActionEvent({
    required this.action,
    required this.timestamp,
    this.customLabel,
  });

  int get points {
    switch (action) {
      case LeadAction.visitedProfile:
        return 10;
      case LeadAction.clickedLinkedIn:
        return 10;
      case LeadAction.clickedWebsite:
        return 15;
      case LeadAction.clickedWhatsApp:
        return 25;
      case LeadAction.downloadedContact:
        return 40;
      case LeadAction.filledForm:
        return 70;
    }
  }

  String get label {
    if (customLabel != null && customLabel!.trim().isNotEmpty) {
      return customLabel!;
    }
    switch (action) {
      case LeadAction.visitedProfile:
        return 'Visitó el perfil';
      case LeadAction.clickedLinkedIn:
        return 'Click en LinkedIn';
      case LeadAction.clickedWebsite:
        return 'Click en sitio web';
      case LeadAction.clickedWhatsApp:
        return 'Abrió WhatsApp';
      case LeadAction.downloadedContact:
        return 'Descargó contacto';
      case LeadAction.filledForm:
        return 'Llenó formulario';
    }
  }

  factory LeadActionEvent.fromJson(Map<String, dynamic> json) {
    final action = _actionFromString(json['action'] as String? ?? '');
    final ts = json['timestamp'] as String?;
    return LeadActionEvent(
      action: action,
      timestamp: ts != null
          ? (DateTime.tryParse(ts)?.toLocal() ?? DateTime.now())
          : DateTime.now(),
      customLabel: json['label'] as String?,
    );
  }
}

LeadAction _actionFromString(String s) {
  switch (s) {
    case 'clickedLinkedIn':
      return LeadAction.clickedLinkedIn;
    case 'clickedWebsite':
      return LeadAction.clickedWebsite;
    case 'clickedWhatsApp':
      return LeadAction.clickedWhatsApp;
    case 'downloadedContact':
      return LeadAction.downloadedContact;
    case 'filledForm':
      return LeadAction.filledForm;
    default:
      return LeadAction.visitedProfile;
  }
}

class LeadModel {
  final String id;
  final String? cardId;
  final String? orgId;
  final String? name;
  final String? company;
  final String? location;
  final String? avatarUrl;
  final List<LeadActionEvent> actions;
  final DateTime firstSeen;
  final DateTime lastSeen;
  bool isConverted;
  final int? dbScore;
  final String pipelineStage;
  final Map<String, dynamic>? formData;
  final String? formType;

  LeadModel({
    required this.id,
    this.cardId,
    this.orgId,
    this.name,
    this.company,
    this.location,
    this.avatarUrl,
    this.actions = const [],
    required this.firstSeen,
    required this.lastSeen,
    this.isConverted = false,
    this.dbScore,
    this.pipelineStage = 'newLead',
    this.formData,
    this.formType,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: json['id'] as String,
      cardId: json['card_id'] as String?,
      orgId: json['org_id'] as String?,
      name: json['name'] as String?,
      company: json['company'] as String?,
      location: json['location'] as String?,
      firstSeen: json['first_seen'] != null
          ? (DateTime.tryParse(json['first_seen'] as String)?.toLocal() ??
                DateTime.now())
          : DateTime.now(),
      lastSeen: json['last_seen'] != null
          ? (DateTime.tryParse(json['last_seen'] as String)?.toLocal() ??
                DateTime.now())
          : DateTime.now(),
      isConverted: json['is_converted'] as bool? ?? false,
      dbScore: (json['score'] as num?)?.toInt(),
      pipelineStage: json['pipeline_stage'] as String? ?? 'newLead',
      formData: json['form_data'] as Map<String, dynamic>?,
      formType: json['form_type'] as String?,
    );
  }

  LeadModel copyWith({
    String? id,
    String? cardId,
    String? orgId,
    String? name,
    String? company,
    String? location,
    String? avatarUrl,
    List<LeadActionEvent>? actions,
    DateTime? firstSeen,
    DateTime? lastSeen,
    bool? isConverted,
    int? dbScore,
    String? pipelineStage,
    Map<String, dynamic>? formData,
    String? formType,
  }) {
    return LeadModel(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      orgId: orgId ?? this.orgId,
      name: name ?? this.name,
      company: company ?? this.company,
      location: location ?? this.location,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      actions: actions ?? this.actions,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      isConverted: isConverted ?? this.isConverted,
      dbScore: dbScore ?? this.dbScore,
      pipelineStage: pipelineStage ?? this.pipelineStage,
      formData: formData ?? this.formData,
      formType: formType ?? this.formType,
    );
  }

  int get score => dbScore ?? actions.fold(0, (sum, a) => sum + a.points);

  LeadStatus get status {
    if (score >= 70) return LeadStatus.hot;
    if (score >= 30) return LeadStatus.warm;
    return LeadStatus.cold;
  }

  String get displayName => name ?? 'Visitante anónimo';

  String get statusLabel {
    switch (status) {
      case LeadStatus.hot:
        return 'Lead caliente 🔥';
      case LeadStatus.warm:
        return 'Lead tibio';
      case LeadStatus.cold:
        return 'Lead frío';
    }
  }

  String get aiSummary {
    final visits = actions
        .where((a) => a.action == LeadAction.visitedProfile)
        .length;
    final hasWhatsapp = actions.any(
      (a) => a.action == LeadAction.clickedWhatsApp,
    );
    final hasSaved = actions.any(
      (a) => a.action == LeadAction.downloadedContact,
    );
    final parts = <String>[];
    if (visits > 1) parts.add('visitó el perfil $visits veces');
    if (hasWhatsapp) parts.add('abrió WhatsApp');
    if (hasSaved) parts.add('guardó el contacto');
    final summary = parts.isNotEmpty ? ', ${parts.join(', ')}' : '';
    return 'Lead Score $score%, interés ${status == LeadStatus.hot
        ? 'alto'
        : score >= 30
        ? 'medio'
        : 'bajo'}$summary.';
  }
}
