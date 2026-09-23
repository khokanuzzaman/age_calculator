import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart' hide ShareResult;

import 'share_payload.dart';
import 'share_result.dart';

typedef ShareCapture =
    Future<Uint8List?> Function(BuildContext context, Widget widget);
typedef ShareText = Future<void> Function(String text, {String? subject});
typedef ShareFiles =
    Future<void> Function(List<XFile> files, {String? text, String? subject});
typedef ShareFileWriter =
    Future<XFile> Function(Uint8List bytes, String fileName);

/// Owns the platform share mechanics while leaving content and card design to
/// each feature. The injectable boundaries keep fallback behavior testable.
class ShareEngine {
  ShareEngine({
    ShareCapture? capture,
    ShareText? shareText,
    ShareFiles? shareFiles,
    ShareFileWriter? writeFile,
  }) : _capture = capture ?? _captureWidget,
       _shareText = shareText ?? _shareTextWithPlatform,
       _shareFiles = shareFiles ?? _shareFilesWithPlatform,
       _writeFile = writeFile ?? _writeTemporaryFile;

  final ShareCapture _capture;
  final ShareText _shareText;
  final ShareFiles _shareFiles;
  final ShareFileWriter _writeFile;

  Future<ShareResult> share(BuildContext context, SharePayload payload) async {
    if (payload.widget == null) {
      await _shareText(payload.text, subject: payload.subject);
      return ShareResult.text;
    }

    Uint8List? bytes;
    try {
      bytes = await _capture(context, payload.widget!);
    } catch (_) {
      bytes = null;
    }
    if (bytes == null) {
      await _shareText(payload.text, subject: payload.subject);
      return ShareResult.textFallback;
    }

    try {
      final file = await _writeFile(bytes, payload.fileName);
      await _shareFiles([file], text: payload.text, subject: payload.subject);
      return ShareResult.image;
    } catch (_) {
      await _shareText(payload.text, subject: payload.subject);
      return ShareResult.textFallback;
    }
  }

  static Future<Uint8List?> _captureWidget(
    BuildContext context,
    Widget widget,
  ) {
    return ScreenshotController().captureFromWidget(
      widget,
      context: context,
      pixelRatio: 3,
      delay: const Duration(milliseconds: 20),
    );
  }

  static Future<void> _shareTextWithPlatform(String text, {String? subject}) {
    return Share.share(text, subject: subject);
  }

  static Future<void> _shareFilesWithPlatform(
    List<XFile> files, {
    String? text,
    String? subject,
  }) {
    return Share.shareXFiles(files, text: text, subject: subject);
  }

  static Future<XFile> _writeTemporaryFile(
    Uint8List bytes,
    String fileName,
  ) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path, mimeType: 'image/png');
  }
}
