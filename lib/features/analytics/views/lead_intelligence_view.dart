import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/data/app_state.dart';
import '../../../core/data/repositories/lead_repository.dart';
import '../models/lead_model.dart';

// ─── Simulated timeline events ────────────────────────────────────────────────

class _TimelineEvent {
  final DateTime timestamp;
  final String time;
  final String date;
  final String label;
  final IconData icon;
  final bool isFormEvent;
  const _TimelineEvent({
    required this.timestamp,
    required this.time,
    required this.date,
    required this.label,
    required this.icon,
    this.isFormEvent = false,
  });
}

String _formTitle(String? formType) {
  switch (formType) {
    case 'cotizacion':
      return 'Solicitar cotización';
    case 'demo':
      return 'Agendar demo';
    case 'catalogo':
      return 'Descargar catálogo';
    case 'contacto':
      return 'Formulario de contacto';
    case 'propuesta':
      return 'Solicitar propuesta';
    default:
      return 'Formulario';
  }
}

String _verboseEventLabel(LeadActionEvent action, LeadModel lead) {
  if (action.action == LeadAction.filledForm) {
    return 'Hizo el llenado de ${_formTitle(lead.formType)}';
  }

  if (action.customLabel != null && action.customLabel!.trim().isNotEmpty) {
    final raw = action.customLabel!.trim();
    final lower = raw.toLowerCase();
    if (lower.contains('email') || lower.contains('correo')) {
      return 'Hizo click en Email';
    }
    if (lower.startsWith('hizo ') ||
        lower.startsWith('visit') ||
        lower.startsWith('descarg')) {
      return raw;
    }
    return 'Hizo click en $raw';
  }

  switch (action.action) {
    case LeadAction.visitedProfile:
      return 'Visitó el perfil digital';
    case LeadAction.clickedLinkedIn:
      return 'Hizo click en LinkedIn';
    case LeadAction.clickedWebsite:
      return 'Hizo click en Sitio web';
    case LeadAction.clickedWhatsApp:
      return 'Hizo click en WhatsApp';
    case LeadAction.downloadedContact:
      return 'Descargó el contacto';
    case LeadAction.filledForm:
      return 'Hizo el llenado de ${_formTitle(lead.formType)}';
  }
}

List<_TimelineEvent> _buildTimeline(LeadModel lead) {
  final fromActions = lead.actions.map((a) {
    IconData icon;
    final label = a.label.toLowerCase();
    if (label.contains('nfc')) {
      icon = Icons.nfc_outlined;
    } else if (label.contains('perfil')) {
      icon = Icons.person_outline_rounded;
    } else {
      switch (a.action) {
        case LeadAction.clickedLinkedIn:
          icon = Icons.work_outline_rounded;
          break;
        case LeadAction.clickedWhatsApp:
          icon = Icons.chat_bubble_outline_rounded;
          break;
        case LeadAction.clickedWebsite:
          icon = Icons.language_rounded;
          break;
        case LeadAction.downloadedContact:
          icon = Icons.download_outlined;
          break;
        case LeadAction.filledForm:
          icon = Icons.assignment_outlined;
          break;
        default:
          icon = Icons.touch_app_outlined;
      }
    }
    return _TimelineEvent(
      timestamp: a.timestamp,
      time: _fmt(a.timestamp),
      date: _fmtDay(a.timestamp),
      label: _verboseEventLabel(a, lead),
      icon: icon,
      isFormEvent: a.action == LeadAction.filledForm,
    );
  }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final deduped = <_TimelineEvent>[];
  const dedupWindow = Duration(seconds: 8);
  for (final ev in fromActions) {
    final hasNearbySameLabel = deduped.any((prev) {
      if (prev.label.trim().toLowerCase() != ev.label.trim().toLowerCase()) {
        return false;
      }
      final diff = ev.timestamp.difference(prev.timestamp).inSeconds.abs();
      return diff <= dedupWindow.inSeconds;
    });
    if (!hasNearbySameLabel) {
      deduped.add(ev);
    }
  }

  if (deduped.isNotEmpty) return deduped;

  final base = lead.firstSeen;
  return [
    _TimelineEvent(
      timestamp: base,
      time: _fmt(base),
      date: _fmtDay(base),
      label: 'Escaneó NFC',
      icon: Icons.nfc_outlined,
    ),
    _TimelineEvent(
      timestamp: base.add(const Duration(minutes: 1)),
      time: _fmt(base.add(const Duration(minutes: 1))),
      date: _fmtDay(base.add(const Duration(minutes: 1))),
      label: 'Abrió perfil',
      icon: Icons.person_outline_rounded,
    ),
  ];
}

String _fmt(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _fmtDate(DateTime dt) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'hoy ${_fmt(dt)}';
  if (diff.inDays == 1) return 'ayer ${_fmt(dt)}';
  return '${dt.day} ${months[dt.month - 1]} ${_fmt(dt)}';
}

String _fmtDay(DateTime dt) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  return '${dt.day} ${months[dt.month - 1]}';
}

class LeadIntelligenceView extends StatefulWidget {
  const LeadIntelligenceView({super.key});

  @override
  State<LeadIntelligenceView> createState() => _LeadIntelligenceViewState();
}

class _LeadIntelligenceViewState extends State<LeadIntelligenceView> {
  List<LeadModel> _allLeads = [];
  bool _loading = true;
  String? _loadedCardId;
  final TextEditingController _searchCtrl = TextEditingController();
  String _search = '';

  @override
  void initState() {
    super.initState();
    appState.addListener(_onAppStateChanged);
    _load();
  }

  @override
  void dispose() {
    appState.removeListener(_onAppStateChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    final cardId = appState.currentCard?.id;
    if (cardId == null || cardId == _loadedCardId) return;
    if (!mounted) return;
    setState(() => _loading = true);
    _load();
  }

  Future<void> _load() async {
    final cardId = appState.currentCard?.id;
    if (cardId == null) {
      _loadedCardId = null;
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final data = await LeadRepository.fetchLeadsForCard(cardId);
      if (mounted) {
        setState(() {
          _loadedCardId = cardId;
          _allLeads = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadedCardId = cardId;
          _loading = false;
        });
      }
    }
  }

  List<LeadModel> get _leads {
    final list = [..._allLeads]
      ..sort((a, b) => b.lastSeen.compareTo(a.lastSeen));
    if (_search.trim().isEmpty) return list;
    final q = _search.trim().toLowerCase();
    return list.where((lead) {
      final name = lead.displayName.toLowerCase();
      final company = (lead.company ?? '').toLowerCase();
      return name.contains(q) || company.contains(q);
    }).toList();
  }

  Future<void> _markAsConverted(LeadModel lead) async {
    try {
      await LeadRepository.markConverted(lead.id, true);
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      final idx = _allLeads.indexWhere((l) => l.id == lead.id);
      if (idx != -1) _allLeads[idx].isConverted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final leads = _leads;
    final convertedCount = _allLeads.where((l) => l.isConverted).length;
    final tapsCount = _allLeads.length - convertedCount;
    final interactionSeries = _buildInteractionSeries(_allLeads);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Taps',
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: context.textPrimary,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Timeline de acciones reales de cada contacto, ordenado por la actividad más reciente.',
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: context.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 760;
                      if (isNarrow) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 16,
                              runSpacing: 8,
                              children: [
                                _BigMetric(
                                  label: 'Taps',
                                  value: '$tapsCount',
                                  color: context.textPrimary,
                                ),
                                _BigMetric(
                                  label: 'Convertidos',
                                  value: '$convertedCount',
                                  color: AppColors.success,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _InteractionSparkChart(values: interactionSeries),
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _BigMetric(
                            label: 'Taps',
                            value: '$tapsCount',
                            color: context.textPrimary,
                          ),
                          const SizedBox(width: 18),
                          _BigMetric(
                            label: 'Convertidos',
                            value: '$convertedCount',
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: _InteractionSparkChart(
                              values: interactionSeries,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: context.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o empresa...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: context.textMuted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: context.textMuted,
                      ),
                      suffixIcon: _search.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: context.textMuted,
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                            ),
                      filled: true,
                      fillColor: context.isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : Colors.white.withValues(alpha: 0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 6)),
          if (_loading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (leads.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'No hay interacciones para este filtro todavía.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: context.textMuted,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _LeadTimelineCard(
                  lead: leads[i],
                  showDivider: i < leads.length - 1,
                  onConverted: () => _markAsConverted(leads[i]),
                ),
                childCount: leads.length,
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

List<int> _buildInteractionSeries(List<LeadModel> leads) {
  final now = DateTime.now();
  final days = List<int>.filled(7, 0);
  for (final lead in leads) {
    for (final action in lead.actions) {
      final diff = now.difference(action.timestamp).inDays;
      if (diff >= 0 && diff < 7) {
        final bucket = 6 - diff;
        days[bucket] += 1;
      }
    }
  }
  if (days.every((v) => v == 0)) {
    for (var i = 0; i < days.length; i++) {
      days[i] = i.isEven ? 1 : 2;
    }
  }
  return days;
}

class _BigMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _BigMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: color,
            height: 0.9,
          ),
        ),
        const SizedBox(width: 6),
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: context.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InteractionSparkChart extends StatelessWidget {
  final List<int> values;
  const _InteractionSparkChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final total = values.fold(0, (sum, value) => sum + value);
    return Container(
      height: 74,
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interacciones 7d · $total',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: CustomPaint(
              painter: _SparklinePainter(
                values: values,
                lineColor: AppColors.primary,
                fillColor: AppColors.primary.withValues(alpha: 0.12),
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color lineColor;
  final Color fillColor;

  const _SparklinePainter({
    required this.values,
    required this.lineColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minVal = values.reduce((a, b) => a < b ? a : b).toDouble();
    final range = (maxVal - minVal).abs() < 0.001 ? 1.0 : maxVal - minVal;
    final stepX = values.length == 1 ? 0.0 : size.width / (values.length - 1);

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final normalized = (values[i] - minVal) / range;
      final x = stepX * i;
      final y = size.height - (normalized * (size.height - 2)) - 1;
      points.add(Offset(x, y));
    }

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final midX = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(midX, prev.dy, midX, curr.dy, curr.dx, curr.dy);
    }

    final areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    final fillPaint = Paint()..color = fillColor;
    canvas.drawPath(areaPath, fillPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(linePath, linePaint);

    final dotPaint = Paint()..color = lineColor;
    canvas.drawCircle(points.last, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.fillColor != fillColor;
  }
}

// ─── Lead Row ─────────────────────────────────────────────────────────────────

class _LeadTimelineCard extends StatefulWidget {
  final LeadModel lead;
  final bool showDivider;
  final VoidCallback onConverted;

  const _LeadTimelineCard({
    required this.lead,
    required this.showDivider,
    required this.onConverted,
  });

  @override
  State<_LeadTimelineCard> createState() => _LeadTimelineCardState();
}

class _LeadTimelineCardState extends State<_LeadTimelineCard> {
  bool _showAllTimeline = false;

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final timeline = _buildTimeline(lead);
    final visibleTimeline = _showAllTimeline
        ? timeline
        : timeline.take(4).toList();
    final hasMoreTimeline = timeline.length > 4;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: context.isDark
              ? Colors.white.withValues(alpha: 0.03)
              : Colors.white.withValues(alpha: 0.62),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lead.displayName,
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: context.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              [
                                if (lead.company != null &&
                                    lead.company!.isNotEmpty)
                                  lead.company!,
                                'Último: ${_fmtDate(lead.lastSeen)}',
                              ].join(' · '),
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        'Timeline',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...visibleTimeline.asMap().entries.map((entry) {
                    final i = entry.key;
                    final ev = entry.value;
                    final isLast = i == visibleTimeline.length - 1;
                    return _TimelineEventRow(
                      event: ev,
                      isLast: isLast,
                      formData: lead.formData,
                      formType: lead.formType,
                    );
                  }),
                  if (hasMoreTimeline) ...[
                    const SizedBox(height: 4),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => setState(
                          () => _showAllTimeline = !_showAllTimeline,
                        ),
                        child: Text(
                          _showAllTimeline
                              ? 'Ver menos'
                              : 'Ver todos los eventos',
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (!lead.isConverted)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: widget.onConverted,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: context.isDark
                                ? const Color(0xFF16A34A).withValues(alpha: 0.1)
                                : const Color(
                                    0xFF16A34A,
                                  ).withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.attach_money_rounded,
                                size: 14,
                                color: const Color(0xFF16A34A),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Marcar como venta',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      'Venta confirmada',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.showDivider)
              Divider(
                color: context.borderColor,
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Timeline Event Row ───────────────────────────────────────────────────────

class _TimelineEventRow extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;
  final Map<String, dynamic>? formData;
  final String? formType;

  const _TimelineEventRow({
    required this.event,
    required this.isLast,
    this.formData,
    this.formType,
  });

  @override
  Widget build(BuildContext context) {
    final lineColor = context.borderColor.withValues(alpha: 0.9);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 2 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: Column(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 28,
                    margin: const EdgeInsets.only(top: 4),
                    color: lineColor,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            event.time,
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.label,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color: context.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.date,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: context.textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(event.icon, size: 14, color: context.textMuted),
                  ],
                ),
                if (event.isFormEvent &&
                    formData != null &&
                    formData!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: _FormEventButton(
                      formData: formData!,
                      formType: formType,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormEventButton extends StatelessWidget {
  final Map<String, dynamic> formData;
  final String? formType;

  const _FormEventButton({required this.formData, this.formType});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No fue posible abrir la acción.')),
      );
    }
  }

  Future<void> _saveLeadSummary(BuildContext context) async {
    final buffer = StringBuffer();
    buffer.writeln('Formulario: ${_formTitle(formType)}');
    for (final entry in formData.entries) {
      final key = entry.key;
      final value = (entry.value ?? '').toString().trim();
      if (key.startsWith('_') || value.isEmpty) continue;
      buffer.writeln('$key: $value');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Información copiada para guardar contacto.'),
        ),
      );
    }
  }

  bool _isEmailField(String key, String value) {
    final mailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    final lowerKey = key.toLowerCase();
    return mailRegex.hasMatch(value) ||
        ((lowerKey.contains('correo') || lowerKey.contains('email')) &&
            value.contains('@'));
  }

  bool _isPhoneField(String key, String value) {
    final phoneRegex = RegExp(r'\+?\d[\d\s\-\(\)]{7,}');
    final lowerKey = key.toLowerCase();
    return phoneRegex.hasMatch(value) ||
        lowerKey.contains('telefono') ||
        lowerKey.contains('teléfono') ||
        lowerKey.contains('phone') ||
        lowerKey.contains('whatsapp');
  }

  Future<void> _copyField(BuildContext context, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Dato copiado.')));
    }
  }

  void _show(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ctx.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 16, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.assignment_ind_outlined,
                      size: 22,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _formTitle(formType),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: ctx.textPrimary,
                        ),
                      ),
                    ),
                    _FollowUpIconAction(
                      onTap: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marcado para seguimiento.'),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      color: ctx.textMuted,
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Divider(color: ctx.borderColor, height: 1),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  shrinkWrap: true,
                  children: [
                    for (final entry in formData.entries)
                      if (!(entry.key.startsWith('_')) &&
                          ((entry.value as String?)?.isNotEmpty ?? false))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Builder(
                            builder: (_) {
                              final key = entry.key;
                              final value = (entry.value ?? '') as String;
                              final isEmail = _isEmailField(key, value);
                              final isPhone = _isPhoneField(key, value);
                              final cleanPhone = value.replaceAll(
                                RegExp(r'[^0-9+]'),
                                '',
                              );

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          key,
                                          style: GoogleFonts.dmSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: ctx.textMuted,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      if (isEmail)
                                        _FieldCornerAction(
                                          icon: Icons.alternate_email_rounded,
                                          color: AppColors.primary,
                                          onTap: () =>
                                              _launch(context, 'mailto:$value'),
                                        ),
                                      if (isPhone)
                                        _FieldCornerAction(
                                          icon: Icons.call_outlined,
                                          color: const Color(0xFF16A34A),
                                          onTap: () => _launch(
                                            context,
                                            'tel:$cleanPhone',
                                          ),
                                        ),
                                      if (isPhone)
                                        _FieldCornerAction(
                                          icon:
                                              Icons.chat_bubble_outline_rounded,
                                          color: const Color(0xFF16A34A),
                                          onTap: () => _launch(
                                            context,
                                            'https://wa.me/$cleanPhone',
                                          ),
                                        ),
                                      _FieldCornerAction(
                                        icon: Icons.content_copy_rounded,
                                        color: context.textSecondary,
                                        onTap: () => _copyField(context, value),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ctx.bgSubtle,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: ctx.borderColor,
                                      ),
                                    ),
                                    child: Text(
                                      value,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13,
                                        color: ctx.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _DialogPrimaryAction(
                    icon: Icons.save_alt_rounded,
                    label: 'Guardar contacto',
                    onTap: () => _saveLeadSummary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: context.isDark
                ? const Color(0xFF1D4ED8).withValues(alpha: 0.1)
                : const Color(0xFF1D4ED8).withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 13,
                color: const Color(0xFF1D4ED8),
              ),
              const SizedBox(width: 5),
              Text(
                'Ver formulario',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D4ED8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogPrimaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DialogPrimaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowUpIconAction extends StatelessWidget {
  final VoidCallback onTap;
  const _FollowUpIconAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 28,
          height: 28,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            color: context.isDark
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.bookmark_add_outlined,
            size: 16,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class _FieldCornerAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FieldCornerAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.isDark
                  ? color.withValues(alpha: 0.1)
                  : color.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 13, color: color),
          ),
        ),
      ),
    );
  }
}
