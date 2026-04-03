String friendlyStorageUploadError(
  Object error, {
  required String assetLabel,
  required String bucket,
}) {
  final raw = error.toString();
  final normalized = raw.toLowerCase();

  if (normalized.contains('bucket not found') ||
      normalized.contains('not found') && normalized.contains(bucket)) {
    return 'No se pudo subir $assetLabel porque el bucket `$bucket` no existe en Supabase Storage.';
  }

  if (normalized.contains('row-level security') ||
      normalized.contains('permission') ||
      normalized.contains('not allowed') ||
      normalized.contains('unauthorized')) {
    return 'No se pudo subir $assetLabel porque las policies de Storage no permiten escribir en `$bucket`.';
  }

  if (normalized.contains('mime') || normalized.contains('content type')) {
    return 'No se pudo subir $assetLabel porque el bucket `$bucket` no acepta ese tipo de archivo.';
  }

  if (normalized.contains('too large') ||
      normalized.contains('payload too large') ||
      normalized.contains('entity too large')) {
    return 'No se pudo subir $assetLabel porque el archivo excede el límite permitido en Storage.';
  }

  return 'No se pudo subir $assetLabel. Detalle: $raw';
}
