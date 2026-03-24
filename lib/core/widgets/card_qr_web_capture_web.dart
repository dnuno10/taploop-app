// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util' as js_util;

Future<String?> captureQrCodeFromCameraOrImage() async {
  final barcodeDetectorCtor = js_util.getProperty<Object?>(
    html.window,
    'BarcodeDetector',
  );
  if (barcodeDetectorCtor == null) return null;

  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..setAttribute('capture', 'environment')
    ..style.display = 'none';

  html.document.body?.append(input);
  final completer = Completer<String?>();

  Future<void> cleanup() async {
    input.remove();
  }

  input.onChange.first.then((_) async {
    try {
      final file = input.files?.first;
      if (file == null) {
        completer.complete(null);
        return;
      }

      final imageSrc = await _readFileAsDataUrl(file);
      if (imageSrc == null) {
        completer.complete(null);
        return;
      }

      final image = html.ImageElement(src: imageSrc);
      await image.onLoad.first.timeout(const Duration(seconds: 10));

      final detector =
          js_util.callConstructor(barcodeDetectorCtor, <Object?>[]) as Object;
      final detectionResult = await js_util.promiseToFuture<Object?>(
        js_util.callMethod<Object?>(detector, 'detect', [image]) as Object,
      );

      final decoded = js_util.dartify(detectionResult);
      if (decoded is! List || decoded.isEmpty) {
        completer.complete(null);
        return;
      }

      for (final item in decoded) {
        if (item is Map && item['rawValue'] is String) {
          final rawValue = (item['rawValue'] as String).trim();
          if (rawValue.isNotEmpty) {
            completer.complete(rawValue);
            return;
          }
        }
      }

      completer.complete(null);
    } catch (_) {
      completer.complete(null);
    } finally {
      await cleanup();
    }
  });

  input.click();
  return completer.future;
}

Future<String?> _readFileAsDataUrl(html.File file) async {
  final reader = html.FileReader();
  final completer = Completer<String?>();

  reader.onLoad.first.then((_) {
    final result = reader.result;
    completer.complete(result is String ? result : null);
  });

  reader.onError.first.then((_) {
    completer.complete(null);
  });

  reader.readAsDataUrl(file);
  return completer.future;
}
