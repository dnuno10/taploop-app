// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

class OptimizedWebImage {
  final Uint8List bytes;
  final String contentType;
  final String extension;

  const OptimizedWebImage({
    required this.bytes,
    required this.contentType,
    required this.extension,
  });
}

Future<OptimizedWebImage> optimizeWebRasterImage(
  html.File file, {
  required int maxDimension,
  required String outputType,
  double quality = 0.9,
  bool flattenToWhite = false,
}) async {
  final objectUrl = html.Url.createObjectUrlFromBlob(file);
  try {
    final image = html.ImageElement(src: objectUrl);
    await image.onLoad.first.timeout(const Duration(seconds: 12));

    final sourceWidth = image.naturalWidth;
    final sourceHeight = image.naturalHeight;
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      throw StateError('No se pudo leer la imagen seleccionada.');
    }

    final scale = math.min(
      1.0,
      maxDimension / math.max(sourceWidth, sourceHeight),
    );
    final targetWidth = math.max(1, (sourceWidth * scale).round());
    final targetHeight = math.max(1, (sourceHeight * scale).round());

    final canvas = html.CanvasElement(width: targetWidth, height: targetHeight);
    final context = canvas.context2D;
    if (flattenToWhite) {
      context
        ..fillStyle = '#FFFFFF'
        ..fillRect(0, 0, targetWidth, targetHeight);
    }
    context.drawImageScaled(image, 0, 0, targetWidth, targetHeight);

    final dataUrl = canvas.toDataUrl(outputType, quality);
    final commaIndex = dataUrl.indexOf(',');
    if (commaIndex == -1) {
      throw StateError('No se pudo optimizar la imagen seleccionada.');
    }

    final bytes = base64Decode(dataUrl.substring(commaIndex + 1));
    return OptimizedWebImage(
      bytes: Uint8List.fromList(bytes),
      contentType: outputType,
      extension: outputType == 'image/png' ? 'png' : 'jpg',
    );
  } finally {
    html.Url.revokeObjectUrl(objectUrl);
  }
}
