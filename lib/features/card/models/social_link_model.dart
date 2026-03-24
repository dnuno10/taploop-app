enum SocialPlatform {
  linkedin,
  instagram,
  facebook,
  tiktok,
  twitter,
  youtube,
  calendly,
  github,
  custom,
}

SocialPlatform _platformFromString(String s) {
  switch (s) {
    case 'instagram':
      return SocialPlatform.instagram;
    case 'facebook':
      return SocialPlatform.facebook;
    case 'tiktok':
      return SocialPlatform.tiktok;
    case 'twitter':
      return SocialPlatform.twitter;
    case 'youtube':
      return SocialPlatform.youtube;
    case 'calendly':
      return SocialPlatform.calendly;
    case 'github':
      return SocialPlatform.github;
    case 'custom':
      return SocialPlatform.custom;
    default:
      return SocialPlatform.linkedin;
  }
}

class SocialLinkModel {
  final String id;
  final SocialPlatform platform;
  final String url;
  final String? customLabel;
  final bool isVisible;
  final int sortOrder;

  const SocialLinkModel({
    required this.id,
    required this.platform,
    required this.url,
    this.customLabel,
    this.isVisible = true,
    this.sortOrder = 0,
  });

  factory SocialLinkModel.fromJson(Map<String, dynamic> json) {
    return SocialLinkModel(
      id: json['id'] as String,
      platform: _platformFromString(json['platform'] as String? ?? 'custom'),
      url: json['url'] as String? ?? '',
      customLabel: json['custom_label'] as String?,
      isVisible: json['is_visible'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson({String? cardId}) => {
    if (cardId != null) 'card_id': cardId,
    'platform': platform.name,
    'url': url,
    if (customLabel != null) 'custom_label': customLabel,
    'is_visible': isVisible,
    'sort_order': sortOrder,
  };

  String get label {
    if (customLabel != null && customLabel!.isNotEmpty) return customLabel!;
    switch (platform) {
      case SocialPlatform.linkedin:
        return 'LinkedIn';
      case SocialPlatform.instagram:
        return 'Instagram';
      case SocialPlatform.facebook:
        return 'Facebook';
      case SocialPlatform.tiktok:
        return 'TikTok';
      case SocialPlatform.twitter:
        return 'X / Twitter';
      case SocialPlatform.youtube:
        return 'YouTube';
      case SocialPlatform.calendly:
        return 'Calendly';
      case SocialPlatform.github:
        return 'GitHub';
      case SocialPlatform.custom:
        return 'Enlace';
    }
  }

  String get iconAsset {
    switch (platform) {
      case SocialPlatform.linkedin:
        return 'linkedin';
      case SocialPlatform.instagram:
        return 'instagram';
      case SocialPlatform.facebook:
        return 'facebook';
      case SocialPlatform.tiktok:
        return 'tiktok';
      case SocialPlatform.twitter:
        return 'twitter';
      case SocialPlatform.youtube:
        return 'youtube';
      case SocialPlatform.calendly:
        return 'calendly';
      case SocialPlatform.github:
        return 'github';
      case SocialPlatform.custom:
        return 'link';
    }
  }

  SocialLinkModel copyWith({
    String? id,
    SocialPlatform? platform,
    String? url,
    String? customLabel,
    bool? isVisible,
    int? sortOrder,
  }) {
    return SocialLinkModel(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      url: url ?? this.url,
      customLabel: customLabel ?? this.customLabel,
      isVisible: isVisible ?? this.isVisible,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
