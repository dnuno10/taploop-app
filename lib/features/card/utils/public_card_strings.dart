/// Static UI chrome strings for the public digital card page
/// (lib/features/card/views/public_card_view.dart), in Spanish ('es',
/// default — unchanged from before this file existed) or English ('en').
///
/// This never translates user-authored content (name, bio, job title,
/// contact/social labels, smart form titles/fields, etc.) — only the app's
/// own labels/buttons/messages around that content.
class PublicCardStrings {
  final bool isEnglish;

  const PublicCardStrings._(this.isEnglish);

  factory PublicCardStrings.of(String? language) =>
      PublicCardStrings._(language == 'en');

  String _t(String es, String en) => isEnglish ? en : es;

  String get deactivatedDefaultMessage => _t(
    'Tarjeta digital desactivada por seguridad',
    'Digital card deactivated for security',
  );

  String get deactivatedBody => _t(
    'Esta tarjeta no se encuentra disponible temporalmente.',
    'This card is temporarily unavailable.',
  );

  String get connectWithMe => _t('Conecta conmigo', 'Connect with me');

  String get contact => _t('Contacto', 'Contact');

  String get socialNetworks => _t('Redes sociales', 'Social media');

  String get scheduleMeeting => _t('Agendar reunión', 'Schedule a meeting');

  String sectionHelpText(String title) => _t(
    'Muestra la sección pública de $title en esta tarjeta.',
    'Shows the public "$title" section on this card.',
  );

  String get saveContact => _t('Guardar contacto', 'Save contact');

  String get sendEmail => _t('Enviar correo', 'Send email');

  String get share => _t('Compartir', 'Share');

  String get linkCopied => _t('Enlace copiado', 'Link copied');

  String get call => _t('Llamar', 'Call');

  String get sendWhatsapp => _t('Enviar WhatsApp', 'Send WhatsApp');

  String get getDirections => _t('Cómo llegar', 'Get directions');

  String get visitWebsite => _t('Visitar sitio web', 'Visit website');

  String get createdWith => _t('Creado con ', 'Made with ');

  String get formsLoadFailed => _t(
    'No se pudieron cargar los formularios.',
    'The forms could not be loaded.',
  );

  String get contactForm => _t('Formulario de contacto', 'Contact form');

  String pleaseComplete(String label) =>
      _t('Por favor completa: $label', 'Please fill in: $label');

  String get requestSentSuccessfully =>
      _t('Solicitud enviada satisfactoriamente.', 'Request sent successfully.');

  String get submitError => _t(
    'Error al enviar. Intenta de nuevo.',
    'Failed to send. Please try again.',
  );

  String get send => _t('Enviar', 'Send');
}
