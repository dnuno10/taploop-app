import '../../features/card/models/digital_card_model.dart';
import '../../features/card/models/contact_item_model.dart';
import '../../features/card/models/social_link_model.dart';
import '../../features/analytics/models/analytics_summary_model.dart';
import '../../features/analytics/models/link_stat_model.dart';
import '../../features/analytics/models/visit_event_model.dart';
import '../../features/analytics/models/lead_model.dart';
import '../../features/analytics/models/team_member_model.dart';
import '../../features/campaigns/models/campaign_model.dart';

class MockData {
  MockData._();

  static final DigitalCardModel card = DigitalCardModel(
    id: '1',
    name: 'Juan García',
    jobTitle: 'Director Comercial',
    company: 'Empresa S.A.',
    bio:
        'Especialista en networking y desarrollo de negocios B2B. Conecto empresas con soluciones que generan resultados.',
    themeStyle: CardThemeStyle.white,
    publicSlug: 'juan-garcia',
    contactItems: [
      const ContactItemModel(
        id: 'c1',
        type: ContactType.phone,
        value: '+52 55 1234 5678',
      ),
      const ContactItemModel(
        id: 'c2',
        type: ContactType.whatsapp,
        value: '+52 55 1234 5678',
      ),
      const ContactItemModel(
        id: 'c3',
        type: ContactType.email,
        value: 'juan@empresa.com',
      ),
      const ContactItemModel(
        id: 'c4',
        type: ContactType.website,
        value: 'https://empresa.com',
      ),
    ],
    socialLinks: [
      const SocialLinkModel(
        id: 's1',
        platform: SocialPlatform.linkedin,
        url: 'https://linkedin.com/in/juangarcia',
      ),
      const SocialLinkModel(
        id: 's2',
        platform: SocialPlatform.instagram,
        url: 'https://instagram.com/juangarcia',
      ),
      const SocialLinkModel(
        id: 's3',
        platform: SocialPlatform.twitter,
        url: 'https://x.com/juangarcia',
      ),
      const SocialLinkModel(
        id: 's4',
        platform: SocialPlatform.tiktok,
        url: 'https://tiktok.com/@juangarcia',
      ),
      const SocialLinkModel(
        id: 's5',
        platform: SocialPlatform.youtube,
        url: 'https://youtube.com/@juangarcia',
      ),
    ],
  );

  static final AnalyticsSummaryModel analytics = AnalyticsSummaryModel(
    totalVisits: 1_248,
    totalTaps: 432,
    totalQrScans: 317,
    totalClicks: 2_894,
    visitsThisWeek: 94,
    visitsLastWeek: 76,
    visitsByDay: [12, 18, 9, 24, 31, 15, 28],
    linkStats: [
      const LinkStatModel(
        linkId: 's1',
        label: 'LinkedIn',
        platform: 'linkedin',
        clicks: 634,
        percentage: 0.72,
      ),
      const LinkStatModel(
        linkId: 's2',
        label: 'Instagram',
        platform: 'instagram',
        clicks: 521,
        percentage: 0.59,
      ),
      const LinkStatModel(
        linkId: 'c3',
        label: 'Email',
        platform: 'email',
        clicks: 298,
        percentage: 0.34,
      ),
      const LinkStatModel(
        linkId: 's3',
        label: 'X / Twitter',
        platform: 'twitter',
        clicks: 187,
        percentage: 0.21,
      ),
      const LinkStatModel(
        linkId: 'c2',
        label: 'WhatsApp',
        platform: 'whatsapp',
        clicks: 412,
        percentage: 0.47,
      ),
    ],
    recentEvents: [
      VisitEventModel(
        id: 'v1',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        device: 'iPhone 15',
        city: 'Monterrey',
        country: 'MX',
        source: 'nfc',
      ),
      VisitEventModel(
        id: 'v2',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        device: 'Samsung Galaxy S23',
        city: 'Ciudad de México',
        country: 'MX',
        source: 'qr',
      ),
      VisitEventModel(
        id: 'v3',
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        device: 'iPad Pro',
        city: 'Guadalajara',
        country: 'MX',
        source: 'link',
      ),
      VisitEventModel(
        id: 'v4',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        device: 'Android',
        city: 'Tijuana',
        country: 'MX',
        source: 'nfc',
      ),
      VisitEventModel(
        id: 'v5',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        device: 'iPhone 14',
        city: 'Cancún',
        country: 'MX',
        source: 'qr',
      ),
      VisitEventModel(
        id: 'v6',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
        device: 'Chrome / Windows',
        city: 'Mérida',
        country: 'MX',
        source: 'link',
      ),
    ],
  );

  // ─── Lead Intelligence ────────────────────────────────────────────────────

  static final List<LeadModel> leads = [
    LeadModel(
      id: 'l1',
      name: 'María Hernández',
      company: 'Tech Solutions S.A.',
      location: 'Monterrey, MX',
      firstSeen: DateTime.now().subtract(const Duration(hours: 2)),
      lastSeen: DateTime.now().subtract(const Duration(minutes: 15)),
      actions: [
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedLinkedIn,
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedWhatsApp,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        LeadActionEvent(
          action: LeadAction.downloadedContact,
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        ),
      ],
    ),
    LeadModel(
      id: 'l2',
      name: 'Carlos Ruiz',
      company: 'Distribuidora del Norte',
      location: 'Guadalajara, MX',
      firstSeen: DateTime.now().subtract(const Duration(hours: 5)),
      lastSeen: DateTime.now().subtract(const Duration(hours: 1)),
      actions: [
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedWebsite,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedLinkedIn,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    LeadModel(
      id: 'l3',
      name: null,
      company: null,
      location: 'Ciudad de México, MX',
      firstSeen: DateTime.now().subtract(const Duration(days: 1)),
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      actions: [
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
    LeadModel(
      id: 'l4',
      name: 'Sofía Torres',
      company: 'Innovación MX',
      location: 'CDMX, MX',
      isConverted: true,
      firstSeen: DateTime.now().subtract(const Duration(days: 3)),
      lastSeen: DateTime.now().subtract(const Duration(days: 2)),
      actions: [
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedWhatsApp,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
        ),
        LeadActionEvent(
          action: LeadAction.downloadedContact,
          timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 4)),
        ),
        LeadActionEvent(
          action: LeadAction.filledForm,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ],
    ),
    LeadModel(
      id: 'l5',
      name: 'Roberto Leal',
      company: 'Consultoría RL',
      location: 'Cancún, MX',
      firstSeen: DateTime.now().subtract(const Duration(days: 2)),
      lastSeen: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      actions: [
        LeadActionEvent(
          action: LeadAction.visitedProfile,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedLinkedIn,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
        ),
        LeadActionEvent(
          action: LeadAction.clickedWebsite,
          timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        ),
      ],
    ),
  ];

  // ─── Team Performance ─────────────────────────────────────────────────────

  static final List<TeamMemberModel> teamMembers = [
    const TeamMemberModel(
      id: 't1',
      name: 'Ana Martínez',
      jobTitle: 'Ejecutiva de Ventas',
      taps: 75,
      profileViews: 210,
      contactsSaved: 38,
      conversions: 18,
    ),
    const TeamMemberModel(
      id: 't2',
      name: 'Carlos Mendoza',
      jobTitle: 'Asesor Comercial',
      taps: 61,
      profileViews: 175,
      contactsSaved: 25,
      conversions: 9,
    ),
    const TeamMemberModel(
      id: 't3',
      name: 'Luis Pérez',
      jobTitle: 'Rep. de Ventas',
      taps: 42,
      profileViews: 134,
      contactsSaved: 19,
      conversions: 5,
    ),
    const TeamMemberModel(
      id: 't4',
      name: 'Diana Flores',
      jobTitle: 'Ejecutiva de Ventas',
      taps: 38,
      profileViews: 98,
      contactsSaved: 14,
      conversions: 4,
    ),
  ];

  // ─── Campaigns ────────────────────────────────────────────────────────────

  static final List<CampaignModel> campaigns = [
    CampaignModel(
      id: 'c1',
      name: 'Expo Industrial 2026',
      eventType: 'Expo',
      eventDate: DateTime(2026, 3, 14),
      location: 'Monterrey, NL',
      description:
          'Exposición industrial anual con líderes de manufactura y logística.',
      status: CampaignStatus.upcoming,
      taps: 0,
      leads: 0,
      conversions: 0,
      assignedMemberNames: ['Ana Martínez', 'Carlos Mendoza'],
    ),
    CampaignModel(
      id: 'c2',
      name: 'Feria Médica Nacional',
      eventType: 'Feria',
      eventDate: DateTime(2025, 11, 20),
      location: 'Ciudad de México, CDMX',
      description:
          'Feria de salud y tecnología médica. Conectamos con distribuidores y directores de hospitales.',
      status: CampaignStatus.active,
      taps: 148,
      leads: 47,
      conversions: 12,
      assignedMemberNames: ['Ana Martínez', 'Luis Pérez', 'Diana Flores'],
    ),
    CampaignModel(
      id: 'c3',
      name: 'Evento Empresarial MTY',
      eventType: 'Networking',
      eventDate: DateTime(2025, 9, 5),
      location: 'Monterrey, NL',
      description:
          'Encuentro de empresarios del noreste. Sesiones de networking y presentaciones de casos de éxito.',
      status: CampaignStatus.finished,
      taps: 312,
      leads: 89,
      conversions: 31,
      assignedMemberNames: ['Carlos Mendoza', 'Luis Pérez'],
    ),
    CampaignModel(
      id: 'c4',
      name: 'Congreso Fintech 2025',
      eventType: 'Congreso',
      eventDate: DateTime(2025, 10, 8),
      location: 'Guadalajara, JAL',
      description:
          'Congreso de innovación financiera y pagos digitales para el sector PYME.',
      status: CampaignStatus.finished,
      taps: 204,
      leads: 63,
      conversions: 19,
      assignedMemberNames: ['Ana Martínez'],
    ),
  ];
}
