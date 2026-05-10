import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_locale.dart';
import '../models/historical_event_model.dart';

class HistoricalEventService {
  HistoricalEventService({
    required SharedPreferences sharedPreferences,
    http.Client? client,
    AssetBundle? assetBundle,
  }) : _sharedPreferences = sharedPreferences,
       _client = client ?? http.Client(),
       _assetBundle = assetBundle ?? rootBundle;

  final SharedPreferences _sharedPreferences;
  final http.Client _client;
  final AssetBundle _assetBundle;

  static const _cachePrefix = 'history_on_this_day_cache_v3_';

  Future<List<HistoricalEvent>> fetchByMonthDay(
    String monthDay, {
    AppLocale locale = AppLocale.english,
    bool forceRefresh = false,
  }) async {
    final local = await _loadCuratedEvents(monthDay, locale);

    if (!forceRefresh) {
      final cached = _readCache(monthDay, locale);
      if (cached != null && cached.isNotEmpty) {
        return _dedupeAndRank([
          ...local,
          ...cached,
        ], locale).take(8).toList(growable: false);
      }
    }

    try {
      final parts = monthDay.split('-');
      if (parts.length != 2) {
        throw const FormatException('Invalid month-day');
      }

      final month = parts[0];
      final day = parts[1];

      final responses = await Future.wait(
        locale.wikiLocales.map(
          (code) => _fetchLocale(month: month, day: day, locale: code),
        ),
      );

      final merged = _dedupeAndRank([
        ...local,
        ...responses.expand((items) => items),
      ], locale).take(8).toList(growable: false);

      await _writeCache(monthDay, locale, merged);
      return merged;
    } on TimeoutException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <HistoricalEvent>[]),
      ], locale).take(8).toList(growable: false);
    } on SocketException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <HistoricalEvent>[]),
      ], locale).take(8).toList(growable: false);
    } on FormatException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <HistoricalEvent>[]),
      ], locale).take(8).toList(growable: false);
    } catch (_) {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <HistoricalEvent>[]),
      ], locale).take(8).toList(growable: false);
    }
  }

  Future<List<HistoricalEvent>> _loadCuratedEvents(
    String monthDay,
    AppLocale locale,
  ) async {
    if (!locale.hasCuratedData) {
      return const [];
    }
    try {
      final jsonString = await _assetBundle.loadString(
        'assets/data/bangladesh_historical_events.json',
      );
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map(
            (item) => HistoricalEvent.fromJson({
              ...item.cast<String, dynamic>(),
              'source': 'local',
            }),
          )
          .where((item) => item.date == monthDay)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<List<HistoricalEvent>> _fetchLocale({
    required String month,
    required String day,
    required String locale,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.wikimedia.org/feed/v1/wikipedia/$locale/onthisday/events/$month/$day',
      );

      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent': 'AgeCalculatorApp/1.1 (https://khokan.me)',
              'Api-User-Agent': 'AgeCalculatorApp/1.1 (https://khokan.me)',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return const [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return const [];
      }

      return parseEvents(decoded, sourceLocale: locale);
    } catch (_) {
      return const [];
    }
  }

  List<HistoricalEvent> parseEvents(
    Map<String, dynamic> json, {
    required String sourceLocale,
  }) {
    final events = json['events'];
    if (events is! List) {
      return const [];
    }

    final items = <HistoricalEvent>[];
    for (final raw in events) {
      if (raw is! Map<String, dynamic>) {
        continue;
      }

      final year = raw['year'] is int ? raw['year'] as int : null;
      final text = (raw['text'] as String?)?.trim();
      Map<String, dynamic>? page;
      final pages = raw['pages'];
      if (pages is List &&
          pages.isNotEmpty &&
          pages.first is Map<String, dynamic>) {
        page = pages.first as Map<String, dynamic>;
      }

      final title = _pickTitle(page, text);
      if (title.isEmpty) {
        continue;
      }

      final description = _pickDescription(page, text);
      final region = _detectRegion('$title ${description ?? ''} ${text ?? ''}');

      items.add(
        HistoricalEvent(
          title: title,
          year: year,
          description: description,
          region: region,
          type: null,
          pageUrl: _pickPageUrl(page),
          thumbnailUrl: _pickThumbnail(page),
          source: sourceLocale,
        ),
      );
    }

    return items;
  }

  String _pickTitle(Map<String, dynamic>? page, String? text) {
    final normalized = (page?['normalizedtitle'] as String?)?.trim();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }

    final title = (page?['title'] as String?)?.trim();
    if (title != null && title.isNotEmpty) {
      return title;
    }

    if (text == null || text.isEmpty) {
      return '';
    }

    final firstSentence = text.split('.').first.trim();
    return firstSentence.isNotEmpty ? firstSentence : text;
  }

  String? _pickDescription(Map<String, dynamic>? page, String? text) {
    final extract = (page?['extract'] as String?)?.trim();
    if (extract != null && extract.isNotEmpty) {
      return extract;
    }
    return text;
  }

  String? _pickPageUrl(Map<String, dynamic>? page) {
    final contentUrls = page?['content_urls'];
    if (contentUrls is! Map<String, dynamic>) {
      return null;
    }

    final mobile = contentUrls['mobile'];
    if (mobile is Map<String, dynamic>) {
      final value = (mobile['page'] as String?)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    final desktop = contentUrls['desktop'];
    if (desktop is Map<String, dynamic>) {
      final value = (desktop['page'] as String?)?.trim();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String? _pickThumbnail(Map<String, dynamic>? page) {
    final thumbnail = page?['thumbnail'];
    if (thumbnail is! Map<String, dynamic>) {
      return null;
    }

    final source = (thumbnail['source'] as String?)?.trim();
    if (source == null || source.isEmpty) {
      return null;
    }

    return source;
  }

  String? _detectRegion(String text) {
    final t = text.toLowerCase();
    if (t.contains('bangladesh') ||
        t.contains('bangladeshi') ||
        t.contains('বাংলাদেশ')) {
      return 'Bangladesh';
    }
    if (t.contains('india') || t.contains('indian') || t.contains('ভারত')) {
      return 'India';
    }
    return null;
  }

  List<HistoricalEvent> _dedupeAndRank(
    List<HistoricalEvent> items,
    AppLocale locale,
  ) {
    final seen = <String>{};
    final deduped = <HistoricalEvent>[];

    for (final item in items) {
      final key = item.dedupeKey;
      if (key.isEmpty || seen.contains(key)) {
        continue;
      }
      seen.add(key);
      deduped.add(item);
    }

    deduped.sort((a, b) {
      final ap = _priority(a, locale);
      final bp = _priority(b, locale);
      if (ap != bp) {
        return bp.compareTo(ap);
      }
      final ay = a.year ?? 99999;
      final by = b.year ?? 99999;
      return ay.compareTo(by);
    });

    return deduped;
  }

  int _priority(HistoricalEvent item, AppLocale locale) {
    if (item.isCurated) {
      return 3;
    }
    if (item.isRegional(locale.languageCode)) {
      return 2;
    }
    return 1;
  }

  List<HistoricalEvent>? _readCache(String monthDay, AppLocale locale) {
    final cached = _sharedPreferences.getString(
      '$_cachePrefix${locale.cacheKey}_$monthDay',
    );
    if (cached == null || cached.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(cached);
      if (decoded is! List) {
        return null;
      }

      return decoded
          .whereType<Map>()
          .map((item) => HistoricalEvent.fromJson(item.cast<String, dynamic>()))
          .where((item) => item.title.trim().isNotEmpty)
          .take(8)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(
    String monthDay,
    AppLocale locale,
    List<HistoricalEvent> items,
  ) {
    final payload = items.map((e) => e.toJson()).toList(growable: false);
    return _sharedPreferences.setString(
      '$_cachePrefix${locale.cacheKey}_$monthDay',
      jsonEncode(payload),
    );
  }
}
