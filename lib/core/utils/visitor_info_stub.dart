/// Non-web stub — returns empty map.
Future<Map<String, String?>> collectVisitorInfo() async => {};

Future<String?> getStableVisitorId() async => null;

Future<bool> hasLocalLeadSubmission({
  required String cardId,
  required String formId,
}) async => false;

Future<void> markLocalLeadSubmission({
  required String cardId,
  required String formId,
}) async {}
