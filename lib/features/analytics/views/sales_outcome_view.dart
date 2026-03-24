import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/data/app_state.dart';
import '../../../core/data/repositories/lead_repository.dart';
import '../models/lead_model.dart';

class SalesOutcomeView extends StatefulWidget {
  const SalesOutcomeView({super.key});

  @override
  State<SalesOutcomeView> createState() => _SalesOutcomeViewState();
}

class _SalesOutcomeViewState extends State<SalesOutcomeView> {
  final Set<String> _confirming = {};
  List<LeadModel> _allLeads = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeads();
  }

  Future<void> _loadLeads() async {
    final cardId = appState.currentCard?.id;
    if (cardId == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    try {
      final data = await LeadRepository.fetchLeadsForCard(cardId);
      if (mounted) {
        setState(() {
          _allLeads = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<LeadModel> get _convertedLeads =>
      _allLeads.where((l) => l.isConverted).toList();

  List<LeadModel> get _pendingLeads =>
      _allLeads.where((l) => !l.isConverted).toList();

  double get _conversionRate {
    final total = _allLeads.length;
    if (total == 0) return 0;
    return _convertedLeads.length / total;
  }

  void _markAsSale(LeadModel lead) async {
    setState(() => _confirming.add(lead.id));
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      final idx = _allLeads.indexWhere((l) => l.id == lead.id);
      if (idx != -1) _allLeads[idx].isConverted = true;
      _confirming.remove(lead.id);
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Lead convertido correctamente',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      );
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ventas',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: context.textPrimary,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_convertedLeads.length} cierres confirmados de ${_allLeads.length} leads totales',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: context.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MetricBlock(
                        label: 'Total leads',
                        value: '${_allLeads.length}',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 52,
                      color: context.borderColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _MetricBlock(
                        label: 'Ventas cerradas',
                        value: '${_convertedLeads.length}',
                        accent: true,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 52,
                      color: context.borderColor,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    Expanded(
                      child: _MetricBlock(
                        label: 'Conversión',
                        value: '${(_conversionRate * 100).toStringAsFixed(0)}%',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Divider(color: context.borderColor, height: 1),
        ),
        if (_convertedLeads.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'CONFIRMADAS',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _ConvertedRow(
                lead: _convertedLeads[i],
                showDivider: i < _convertedLeads.length - 1,
              ),
              childCount: _convertedLeads.length,
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(color: context.borderColor, height: 1),
          ),
        ],
        if (_pendingLeads.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                'PENDIENTES',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: context.textMuted,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _PendingRow(
                lead: _pendingLeads[i],
                isConfirming: _confirming.contains(_pendingLeads[i].id),
                showDivider: i < _pendingLeads.length - 1,
                onMark: () => _markAsSale(_pendingLeads[i]),
              ),
              childCount: _pendingLeads.length,
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ─── Metric Block ────────────────────────────────────────────────────────────────

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _MetricBlock({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: context.isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.dmSans(fontSize: 11, color: context.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: accent ? AppColors.primary : context.textPrimary,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Converted Row ───────────────────────────────────────────────────────────────

class _ConvertedRow extends StatelessWidget {
  final LeadModel lead;
  final bool showDivider;
  const _ConvertedRow({required this.lead, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    if (lead.company != null)
                      Text(
                        lead.company!,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    Text(
                      'Venta confirmada',
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
        ),
        if (showDivider)
          Divider(
            color: context.borderColor,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

// ─── Pending Row ────────────────────────────────────────────────────────────────

class _PendingRow extends StatelessWidget {
  final LeadModel lead;
  final bool isConfirming;
  final bool showDivider;
  final VoidCallback onMark;

  const _PendingRow({
    required this.lead,
    required this.isConfirming,
    required this.showDivider,
    required this.onMark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lead.displayName,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.textPrimary,
                      ),
                    ),
                    Text(
                      'Última actividad: ${_timeAgo(lead.lastSeen)}',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MouseRegion(
                cursor: isConfirming
                    ? SystemMouseCursors.basic
                    : SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: isConfirming ? null : onMark,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: isConfirming
                          ? const Color(0xFF15803D).withValues(alpha: 0.08)
                          : context.isDark
                          ? const Color(0xFF15803D).withValues(alpha: 0.1)
                          : const Color(0xFF15803D).withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      width: 118,
                      child: Center(
                        child: isConfirming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF15803D),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.attach_money_rounded,
                                    size: 14,
                                    color: Color(0xFF15803D),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Marcar venta',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            color: context.borderColor,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}

String _timeAgo(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  return '${diff.inDays}d';
}
