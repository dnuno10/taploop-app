class LinkStatModel {
  final String linkId;
  final String label;
  final String platform; // instagram, linkedin, website...
  final int clicks;
  final double percentage; // 0.0 - 1.0

  const LinkStatModel({
    required this.linkId,
    required this.label,
    required this.platform,
    required this.clicks,
    required this.percentage,
  });

  factory LinkStatModel.fromJson(
    Map<String, dynamic> json, {
    int totalClicks = 1,
  }) {
    final clickCount = (json['clicks'] as num?)?.toInt() ?? 0;
    return LinkStatModel(
      linkId: json['id'] as String,
      label: json['label'] as String? ?? json['platform'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      clicks: clickCount,
      percentage: totalClicks > 0 ? clickCount / totalClicks : 0,
    );
  }
}
