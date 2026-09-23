import 'package:flutter/material.dart';

/// Content passed to the central share engine.
class SharePayload {
  const SharePayload({
    required this.text,
    this.subject,
    this.widget,
    this.fileName = 'age_calculator_share.png',
  });

  final String text;
  final String? subject;
  final Widget? widget;
  final String fileName;
}
