// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

Future<bool> downloadVCardFile(String fileName, String contents) async {
  final bytes = utf8.encode(contents);
  final blob = html.Blob([bytes], 'text/vcard;charset=utf-8');
  final blobUrl = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: blobUrl)
    ..download = fileName
    ..style.display = 'none';

  try {
    html.document.body?.append(anchor);
    anchor.click();
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return true;
  } finally {
    anchor.remove();
    html.Url.revokeObjectUrl(blobUrl);
  }
}
