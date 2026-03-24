import 'link_stat_model.dart';
import 'visit_event_model.dart';

class AnalyticsSummaryModel {
  final int totalVisits;
  final int totalTaps;
  final int totalQrScans;
  final int totalClicks;
  final int visitsThisWeek;
  final int visitsLastWeek;
  final List<LinkStatModel> linkStats;
  final List<VisitEventModel> recentEvents;
  final List<int> visitsByDay; // last 7 days, index 0 = oldest

  const AnalyticsSummaryModel({
    required this.totalVisits,
    required this.totalTaps,
    required this.totalQrScans,
    required this.totalClicks,
    required this.visitsThisWeek,
    required this.visitsLastWeek,
    required this.linkStats,
    required this.recentEvents,
    required this.visitsByDay,
  });

  double get weeklyGrowthPercent {
    if (visitsLastWeek == 0) return 100;
    return ((visitsThisWeek - visitsLastWeek) / visitsLastWeek) * 100;
  }

  bool get isGrowing => visitsThisWeek >= visitsLastWeek;
}
