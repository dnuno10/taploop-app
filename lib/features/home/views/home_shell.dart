import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/data/app_state.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/taploop_logo.dart';
import '../../admin/views/admin_view.dart';
import '../../analytics/views/analytics_dashboard_view.dart';
import '../../analytics/views/team_performance_view.dart';
import '../../campaigns/views/campaigns_view.dart';
import '../../card/views/edit_card_view.dart';
import '../../card/views/share_card_view.dart';
import 'dashboard_view.dart';
import 'settings_view.dart';

const _shellFrame = Color(0xFFF5F5F3);
const _shellPanel = Color(0xFFFFFFFF);
const _shellPanelSoft = Color(0xFFFFFFFF);
const _shellBorder = Color(0xFFE8E8E3);
const _shellInk = Color(0xFF171412);
const _shellMuted = Color(0xFF6F6A64);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _loadCardIfMissing();
  }

  void _loadCardIfMissing() async {
    if (appState.currentCard == null && appState.currentUser != null) {
      final card = await AuthService.fetchUserCard(appState.currentUser!.id);
      if (mounted) appState.setCard(card);
    }
  }

  List<Widget> get _views => [
    DashboardView(onNavigate: (i) => setState(() => _index = i)),
    const EditCardView(),
    const AnalyticsDashboardView(),
    const TeamPerformanceView(),
    const CampaignsView(),
    const AdminView(),
    const ShareCardView(),
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
      icon: Icons.share_outlined,
      activeIcon: Icons.share_rounded,
      label: 'Compartir',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final views = _views;

    if (isDesktop) {
      return _DesktopShell(
        index: _index,
        views: views,
        onTap: (value) => setState(() => _index = value),
      );
    }

    return _MobileShell(
      index: _index,
      views: views,
      onTap: (value) => setState(() => _index = value),
    );
  }
}

class _DesktopShell extends StatelessWidget {
  final int index;
  final List<Widget> views;
  final ValueChanged<int> onTap;

  const _DesktopShell({
    required this.index,
    required this.views,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final user = appState.currentUser;
    final jobTitle = user?.jobTitle?.trim();

    return Scaffold(
      backgroundColor: _shellFrame,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 248,
                decoration: BoxDecoration(
                  color: _shellPanel,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: _shellBorder),
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
                        color: _shellPanelSoft,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          _AvatarBadge(
                            initials: user?.initials ?? 'TL',
                            photoUrl: user?.photoUrl,
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
                                    color: _shellInk,
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
                                    color: _shellMuted,
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
                    const SizedBox(height: 22),
                    Text(
                      'MENÚ',
                      style: GoogleFonts.dmSans(
                        color: _shellMuted,
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
                          const SizedBox(height: 12),
                          _DesktopNavTile(
                            item: const _NavItem(
                              icon: Icons.settings_outlined,
                              activeIcon: Icons.settings_rounded,
                              label: 'Ajustes',
                            ),
                            active: index == 7,
                            onTap: () => onTap(7),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _shellPanelSoft,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TapLoop',
                            style: GoogleFonts.outfit(
                              color: _shellInk,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Interfaz clara, ligera y enfocada en el trabajo diario.',
                            style: GoogleFonts.dmSans(
                              color: _shellMuted,
                              fontSize: 12,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () async {
                        await AuthService.signOut();
                        appState.clear();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _shellMuted,
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
                    color: _shellPanel,
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: _shellBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
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
  final ValueChanged<int> onTap;

  const _MobileShell({
    required this.index,
    required this.views,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _shellFrame,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Container(
            decoration: BoxDecoration(
              color: _shellPanel,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              border: Border.all(color: _shellBorder),
            ),
            clipBehavior: Clip.antiAlias,
            child: IndexedStack(index: index, children: views),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: _shellPanel,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _shellBorder),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: BottomNavigationBar(
            currentIndex: index,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: _shellMuted,
            selectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: GoogleFonts.dmSans(
              fontSize: 11,
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
            color: active ? const Color(0xFFF0EFEC) : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                active ? item.activeIcon : item.icon,
                size: 18,
                color: active ? AppColors.primary : _shellMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: GoogleFonts.dmSans(
                    color: active ? _shellInk : _shellMuted,
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
      backgroundColor: const Color(0xFFF0EFEC),
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : Text(
              initials,
              style: GoogleFonts.outfit(
                color: _shellInk,
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
