import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/data/app_state.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/card_initial_setup_state.dart';
import '../../../core/widgets/taploop_logo.dart';
import '../../admin/views/admin_view.dart';
import '../../analytics/views/analytics_dashboard_view.dart';
import '../../analytics/views/team_performance_view.dart';
import '../../campaigns/views/campaigns_view.dart';
import '../../card/models/digital_card_model.dart';
import '../../card/views/edit_card_view.dart';
import '../../card/views/share_card_view.dart';
import 'dashboard_view.dart';
import 'settings_view.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  bool _creatingCard = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadCardsIfMissing();
    });
  }

  void _loadCardsIfMissing() async {
    final user = appState.currentUser;
    if (appState.loadingCard || user == null || appState.userCards.isNotEmpty) {
      return;
    }

    appState.setLoadingCard(true);
    try {
      final cards = await AuthService.fetchUserCards(user.id);
      if (mounted) appState.setCards(cards);
    } finally {
      if (mounted) appState.setLoadingCard(false);
    }
  }

  Future<void> _createCard() async {
    final user = appState.currentUser;
    if (user == null || _creatingCard) return;

    setState(() => _creatingCard = true);
    try {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: CardInitialSetupState(
              createNewCardOnLink: true,
              onLinked: () {
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                if (mounted) {
                  setState(() => _index = 1);
                }
              },
            ),
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar la vinculación de la tarjeta.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _creatingCard = false);
    }
  }

  List<Widget> get _views => [
    DashboardView(onNavigate: (i) => setState(() => _index = i)),
    const EditCardView(),
    const ShareCardView(),
    const AnalyticsDashboardView(),
    const TeamPerformanceView(),
    const CampaignsView(),
    const AdminView(),
    const SettingsView(),
  ];

  static const _navItems = [
    _NavItem(
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
      label: 'Inicio',
    ),
    _NavItem(
      icon: Icons.badge_outlined,
      activeIcon: Icons.badge_rounded,
      label: 'Tarjeta',
    ),
    _NavItem(
      icon: Icons.share_outlined,
      activeIcon: Icons.share_rounded,
      label: 'Compartir',
    ),
    _NavItem(
      icon: Icons.query_stats_outlined,
      activeIcon: Icons.query_stats_rounded,
      label: 'Analíticas',
    ),
    _NavItem(
      icon: Icons.groups_outlined,
      activeIcon: Icons.groups_rounded,
      label: 'Equipo',
    ),
    _NavItem(
      icon: Icons.campaign_outlined,
      activeIcon: Icons.campaign_rounded,
      label: 'Campañas',
    ),
    _NavItem(
      icon: Icons.admin_panel_settings_outlined,
      activeIcon: Icons.admin_panel_settings_rounded,
      label: 'Administración',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Configuración',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final isDesktop = Responsive.isDesktop(context);
        final views = _views;

        if (isDesktop) {
          return _DesktopShell(
            index: _index,
            views: views,
            cards: appState.userCards,
            currentCard: appState.currentCard,
            creatingCard: _creatingCard,
            onTap: (value) => setState(() => _index = value),
            onSelectCard: appState.selectCardById,
            onCreateCard: _createCard,
          );
        }

        return _MobileShell(
          index: _index,
          views: views,
          cards: appState.userCards,
          currentCard: appState.currentCard,
          creatingCard: _creatingCard,
          onTap: (value) => setState(() => _index = value),
          onSelectCard: appState.selectCardById,
          onCreateCard: _createCard,
        );
      },
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final int index;
  final List<Widget> views;
  final List<DigitalCardModel> cards;
  final DigitalCardModel? currentCard;
  final bool creatingCard;
  final ValueChanged<int> onTap;
  final ValueChanged<String> onSelectCard;
  final Future<void> Function() onCreateCard;

  const _DesktopShell({
    required this.index,
    required this.views,
    required this.cards,
    required this.currentCard,
    required this.creatingCard,
    required this.onTap,
    required this.onSelectCard,
    required this.onCreateCard,
  });

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final profilePhotoUrl =
        currentCard?.profilePhotoUrl?.trim().isNotEmpty == true
        ? currentCard!.profilePhotoUrl
        : user?.photoUrl;
    final jobTitle = user?.jobTitle?.trim();

    return Scaffold(
      backgroundColor: context.bgSubtle,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 268,
                decoration: BoxDecoration(
                  color: context.bgCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: context.borderStrongSoft,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: TapLoopLogo(height: 34, showText: false),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: context.bgSubtle,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          _AvatarBadge(
                            initials: user?.initials ?? 'TL',
                            photoUrl: profilePhotoUrl,
                            radius: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name
                                      : 'Equipo TapLoop',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.outfit(
                                    color: context.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  (jobTitle != null && jobTitle.isNotEmpty)
                                      ? jobTitle
                                      : 'Espacio principal',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.dmSans(
                                    color: context.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (cards.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      _CardWorkspaceSection(
                        cards: cards,
                        currentCard: currentCard,
                        creatingCard: creatingCard,
                        onSelectCard: onSelectCard,
                        onCreateCard: onCreateCard,
                      ),
                    ],
                    const SizedBox(height: 22),
                    Text(
                      'MENÚ',
                      style: GoogleFonts.dmSans(
                        color: context.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          ..._HomeShellState._navItems.asMap().entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: _DesktopNavTile(
                                item: entry.value,
                                active: index == entry.key,
                                onTap: () => onTap(entry.key),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await AuthService.signOut();
                        appState.clear();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: context.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: Text(
                        'Cerrar sesión',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.bgCard,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(
                      color: context.borderStrongSoft,
                      width: 1.5,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: IndexedStack(index: index, children: views),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  final int index;
  final List<Widget> views;
  final List<DigitalCardModel> cards;
  final DigitalCardModel? currentCard;
  final bool creatingCard;
  final ValueChanged<int> onTap;
  final ValueChanged<String> onSelectCard;
  final Future<void> Function() onCreateCard;

  const _MobileShell({
    required this.index,
    required this.views,
    required this.cards,
    required this.currentCard,
    required this.creatingCard,
    required this.onTap,
    required this.onSelectCard,
    required this.onCreateCard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgSubtle,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Container(
            decoration: BoxDecoration(
              color: context.bgCard,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: context.borderStrongSoft, width: 1.5),
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                if (cards.isNotEmpty)
                  _MobileCardToolbar(
                    cards: cards,
                    currentCard: currentCard,
                    creatingCard: creatingCard,
                    onSelectCard: onSelectCard,
                    onCreateCard: onCreateCard,
                  ),
                Expanded(
                  child: IndexedStack(index: index, children: views),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: context.bgCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: context.borderStrongSoft, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: context.textSecondary,
            selectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            items: _HomeShellState._navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon, size: 20),
                    activeIcon: Icon(item.activeIcon, size: 20),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _CardWorkspaceSection extends StatelessWidget {
  final List<DigitalCardModel> cards;
  final DigitalCardModel? currentCard;
  final bool creatingCard;
  final ValueChanged<String> onSelectCard;
  final Future<void> Function() onCreateCard;

  const _CardWorkspaceSection({
    required this.cards,
    required this.currentCard,
    required this.creatingCard,
    required this.onSelectCard,
    required this.onCreateCard,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCard = currentCard ?? cards.first;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.bgSubtle,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.borderStrongSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TARJETA ACTIVA',
            style: GoogleFonts.dmSans(
              color: context.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          if (cards.length > 1)
            _CardDropdown(
              cards: cards,
              currentCard: selectedCard,
              onSelectCard: onSelectCard,
            )
          else
            _SelectedCardSummary(card: selectedCard),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: creatingCard ? null : onCreateCard,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: creatingCard
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.add_card_rounded, size: 18),
              label: Text(
                'Agregar tarjeta',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileCardToolbar extends StatelessWidget {
  final List<DigitalCardModel> cards;
  final DigitalCardModel? currentCard;
  final bool creatingCard;
  final ValueChanged<String> onSelectCard;
  final Future<void> Function() onCreateCard;

  const _MobileCardToolbar({
    required this.cards,
    required this.currentCard,
    required this.creatingCard,
    required this.onSelectCard,
    required this.onCreateCard,
  });

  @override
  Widget build(BuildContext context) {
    final selectedCard = currentCard ?? cards.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: context.bgCard,
        border: Border(bottom: BorderSide(color: context.borderStrongSoft)),
      ),
      child: Row(
        children: [
          Expanded(
            child: cards.length > 1
                ? _CardDropdown(
                    cards: cards,
                    currentCard: selectedCard,
                    onSelectCard: onSelectCard,
                    compact: true,
                  )
                : _SelectedCardSummary(card: selectedCard, compact: true),
          ),
          const SizedBox(width: 10),
          IconButton.filled(
            onPressed: creatingCard ? null : onCreateCard,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            icon: creatingCard
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.add_card_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

class _CardDropdown extends StatelessWidget {
  final List<DigitalCardModel> cards;
  final DigitalCardModel currentCard;
  final ValueChanged<String> onSelectCard;
  final bool compact;

  const _CardDropdown({
    required this.cards,
    required this.currentCard,
    required this.onSelectCard,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: currentCard.id,
      isExpanded: true,
      icon: Icon(Icons.keyboard_arrow_down, color: context.textSecondary),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: context.bgCard,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 10 : 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.borderColor),
        ),
      ),
      style: GoogleFonts.dmSans(
        color: context.textPrimary,
        fontSize: compact ? 12 : 13,
        fontWeight: FontWeight.w700,
      ),
      items: cards.asMap().entries.map((entry) {
        final card = entry.value;
        return DropdownMenuItem<String>(
          value: card.id,
          child: Text(
            _cardMenuLabel(card, entry.key),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onSelectCard(value);
      },
    );
  }
}

class _SelectedCardSummary extends StatelessWidget {
  final DigitalCardModel card;
  final bool compact;

  const _SelectedCardSummary({required this.card, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: context.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _cardTitle(card, 0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: context.textPrimary,
              fontSize: compact ? 15 : 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '@${card.publicSlug}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              color: context.textSecondary,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopNavTile extends StatelessWidget {
  final _NavItem item;
  final bool active;
  final VoidCallback onTap;

  const _DesktopNavTile({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: active
                ? (context.isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : const Color(0xFFF3F1ED))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size: 18,
                color: active ? AppColors.primary : context.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.dmSans(
                    color: active ? context.textPrimary : context.textSecondary,
                    fontSize: 14,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  final String initials;
  final String? photoUrl;
  final double radius;

  const _AvatarBadge({
    required this.initials,
    required this.photoUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = photoUrl?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    return CircleAvatar(
      radius: radius,
      backgroundColor: context.bgSubtle,
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : Text(
              initials,
              style: GoogleFonts.outfit(
                color: context.textPrimary,
                fontSize: radius * 0.82,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

String _cardTitle(DigitalCardModel card, int index) {
  final name = card.name.trim();
  if (name.isNotEmpty) return name;
  return 'Tarjeta ${index + 1}';
}

String _cardMenuLabel(DigitalCardModel card, int index) {
  final title = _cardTitle(card, index);
  if (card.publicSlug.trim().isEmpty) return title;
  return '$title · @${card.publicSlug}';
}
