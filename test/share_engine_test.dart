import 'dart:typed_data';

import 'package:age_calculator/core/sharing/app_store_links.dart';
import 'package:age_calculator/core/sharing/share_engine.dart';
import 'package:age_calculator/core/sharing/share_payload.dart';
import 'package:age_calculator/core/sharing/share_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart' hide ShareResult;

void main() {
  test('app share contains both platform links', () {
    expect(AppStoreLinks.appShareMessage, contains(AppStoreLinks.android));
    expect(AppStoreLinks.appShareMessage, contains(AppStoreLinks.ios));
  });

  test('caption builder adds compact attribution and links', () {
    final caption = AppStoreLinks.captionFor(
      'A result',
      includeStoreLinks: true,
    );
    expect(caption, contains('Made with Age Calculator'));
    expect(caption, contains('Android: ${AppStoreLinks.android}'));
    expect(caption, contains('iPhone: ${AppStoreLinks.ios}'));
  });

  testWidgets('image share returns image format', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox();
        },
      ),
    );
    var sharedImages = 0;
    final engine = ShareEngine(
      capture: (_, __) async => Uint8List.fromList([1, 2, 3]),
      writeFile: (_, __) async => XFile('birthday.png'),
      shareFiles: (_, {text, subject}) async => sharedImages++,
    );

    final result = await engine.share(
      context,
      const SharePayload(text: 'caption', widget: SizedBox()),
    );

    expect(result, ShareResult.image);
    expect(sharedImages, 1);
  });

  testWidgets('capture failure falls back to text', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox();
        },
      ),
    );
    String? sharedText;
    final engine = ShareEngine(
      capture: (_, __) async => null,
      shareText: (text, {subject}) async => sharedText = text,
    );

    final result = await engine.share(
      context,
      const SharePayload(text: 'fallback text', widget: SizedBox()),
    );

    expect(result, ShareResult.textFallback);
    expect(sharedText, 'fallback text');
  });

  testWidgets('temporary file failure falls back to text', (tester) async {
    late BuildContext context;
    await tester.pumpWidget(
      Builder(
        builder: (value) {
          context = value;
          return const SizedBox();
        },
      ),
    );
    var textShares = 0;
    final engine = ShareEngine(
      capture: (_, __) async => Uint8List.fromList([1]),
      writeFile: (_, __) async => throw StateError('disk unavailable'),
      shareText: (text, {subject}) async => textShares++,
    );

    final result = await engine.share(
      context,
      const SharePayload(text: 'safe fallback', widget: SizedBox()),
    );

    expect(result, ShareResult.textFallback);
    expect(textShares, 1);
  });

  test('text-only sharing is supported', () async {
    var textShares = 0;
    final engine = ShareEngine(
      shareText: (text, {subject}) async => textShares++,
    );

    final result = await engine.share(
      _TestBuildContext(),
      const SharePayload(text: 'plain text'),
    );

    expect(result, ShareResult.text);
    expect(textShares, 1);
  });
}

/// Only used by the text-only branch, which never reads the context.
class _TestBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
