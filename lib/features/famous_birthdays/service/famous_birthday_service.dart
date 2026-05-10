import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/app_locale.dart';
import '../model/famous_birthday_model.dart';

class FamousBirthdayService {
  FamousBirthdayService({
    required SharedPreferences sharedPreferences,
    http.Client? client,
    AssetBundle? assetBundle,
  }) : _sharedPreferences = sharedPreferences,
       _client = client ?? http.Client(),
       _assetBundle = assetBundle ?? rootBundle;

  final SharedPreferences _sharedPreferences;
  final http.Client _client;
  final AssetBundle _assetBundle;

  static const _cachePrefix = 'famous_birthdays_cache_v4_';

  Future<List<FamousBirthday>> fetchByMonthDay(
    String monthDay, {
    AppLocale locale = AppLocale.english,
    bool forceRefresh = false,
  }) async {
    final local = await _loadCuratedBirthdays(monthDay, locale);

    if (!forceRefresh) {
      final cached = _readCache(monthDay, locale);
      if (cached != null && cached.isNotEmpty) {
        return _dedupeAndRank([
          ...local,
          ...cached,
        ], locale).take(10).toList(growable: false);
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
          (code) => _fetchWikimediaLocale(month: month, day: day, locale: code),
        ),
      );

      var merged = _dedupeAndRank([
        ...local,
        ...responses.expand((items) => items),
      ], locale);

      // Wikipedia's "on this day" feeds under-represent South Asia, so enrich
      // with Wikidata only for those locales.
      if (locale.isSouthAsian) {
        final hasRegional = merged.any(_isSouthAsianItem);
        if (!hasRegional) {
          final monthInt = int.tryParse(month) ?? 1;
          final dayInt = int.tryParse(day) ?? 1;

          final wikidataCitizenship = await _fetchWikidataCitizenshipFallback(
            monthInt,
            dayInt,
          );
          merged = _dedupeAndRank([
            ...merged,
            ...wikidataCitizenship,
          ], locale);

          if (!merged.any(_isSouthAsianItem)) {
            final wikidataBirthPlace = await _fetchWikidataBirthPlaceFallback(
              monthInt,
              dayInt,
            );
            merged = _dedupeAndRank([
              ...merged,
              ...wikidataBirthPlace,
            ], locale);
          }
        }
      }

      final finalItems = merged.take(10).toList(growable: false);
      await _writeCache(monthDay, locale, finalItems);
      return finalItems;
    } on TimeoutException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <FamousBirthday>[]),
      ], locale).take(10).toList(growable: false);
    } on SocketException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <FamousBirthday>[]),
      ], locale).take(10).toList(growable: false);
    } on FormatException {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <FamousBirthday>[]),
      ], locale).take(10).toList(growable: false);
    } catch (_) {
      return _dedupeAndRank([
        ...local,
        ...(_readCache(monthDay, locale) ?? const <FamousBirthday>[]),
      ], locale).take(10).toList(growable: false);
    }
  }

  bool _isSouthAsianItem(FamousBirthday item) {
    final tag = (item.countryTag ?? '').toLowerCase();
    return tag == 'bangladesh' || tag == 'india';
  }

  Future<List<FamousBirthday>> _loadCuratedBirthdays(
    String monthDay,
    AppLocale locale,
  ) async {
    if (!locale.hasCuratedData) {
      return const [];
    }
    try {
      final jsonString = await _assetBundle.loadString(
        'assets/data/bangladesh_famous_birthdays.json',
      );
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map>()
          .map((item) => item.cast<String, dynamic>())
          .where((item) => (item['date'] as String?)?.trim() == monthDay)
          .map(
            (item) => FamousBirthday(
              name: (item['name'] as String?)?.trim() ?? '',
              birthYear: _parseYear(item['birthYear']),
              description: (item['description'] as String?)?.trim(),
              countryTag: _detectCountry((item['region'] as String?) ?? ''),
              sourceLocale: 'local',
            ),
          )
          .where((item) => item.name.isNotEmpty)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  int? _parseYear(Object? value) {
    return switch (value) {
      int v => v,
      num v => v.toInt(),
      String v => int.tryParse(v),
      _ => null,
    };
  }

  Future<List<FamousBirthday>> _fetchWikimediaLocale({
    required String month,
    required String day,
    required String locale,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.wikimedia.org/feed/v1/wikipedia/$locale/onthisday/births/$month/$day',
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

      return parseBirthdays(decoded, sourceLocale: locale);
    } catch (_) {
      return const [];
    }
  }

  List<FamousBirthday> parseBirthdays(
    Map<String, dynamic> json, {
    required String sourceLocale,
  }) {
    final births = json['births'];
    if (births is! List) {
      return const [];
    }

    final items = <FamousBirthday>[];
    for (final raw in births) {
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

      final name = _pickName(page, text);
      if (name.isEmpty) {
        continue;
      }

      final description = _pickDescription(page, text);
      items.add(
        FamousBirthday(
          name: name,
          birthYear: year,
          description: description,
          thumbnailUrl: _pickThumbnail(page),
          pageUrl: _pickPageUrl(page),
          countryTag: _detectCountry(
            '$name ${description ?? ''} ${text ?? ''}',
          ),
          sourceLocale: sourceLocale,
        ),
      );
    }

    return items;
  }

  Future<List<FamousBirthday>> _fetchWikidataCitizenshipFallback(
    int month,
    int day,
  ) async {
    final query =
        '''
SELECT ?person ?personLabel ?personDescription ?birthDate ?image ?article ?countryLabel WHERE {
  ?person wdt:P31 wd:Q5;
          wdt:P569 ?birthDate;
          wdt:P27 ?country.

  VALUES ?country { wd:Q902 wd:Q668 }

  FILTER(MONTH(?birthDate) = $month && DAY(?birthDate) = $day)

  OPTIONAL { ?person wdt:P18 ?image. }

  OPTIONAL {
    ?article schema:about ?person;
             schema:isPartOf <https://en.wikipedia.org/>.
  }

  SERVICE wikibase:label {
    bd:serviceParam wikibase:language "en,bn,hi".
  }
}
ORDER BY DESC(?article)
LIMIT 20
''';

    return _fetchWikidataQuery(
      query,
      countryField: 'countryLabel',
      source: 'wikidata',
    );
  }

  Future<List<FamousBirthday>> _fetchWikidataBirthPlaceFallback(
    int month,
    int day,
  ) async {
    final query =
        '''
SELECT ?person ?personLabel ?personDescription ?birthDate ?image ?article ?birthPlaceLabel WHERE {
  ?person wdt:P31 wd:Q5;
          wdt:P569 ?birthDate;
          wdt:P19 ?birthPlace.

  ?birthPlace wdt:P17 ?country.
  VALUES ?country { wd:Q902 wd:Q668 }

  FILTER(MONTH(?birthDate) = $month && DAY(?birthDate) = $day)

  OPTIONAL { ?person wdt:P18 ?image. }

  OPTIONAL {
    ?article schema:about ?person;
             schema:isPartOf <https://en.wikipedia.org/>.
  }

  SERVICE wikibase:label {
    bd:serviceParam wikibase:language "en,bn,hi".
  }
}
LIMIT 20
''';

    return _fetchWikidataQuery(
      query,
      countryField: 'birthPlaceLabel',
      source: 'wikidata_birthplace',
    );
  }

  Future<List<FamousBirthday>> _fetchWikidataQuery(
    String query, {
    required String countryField,
    required String source,
  }) async {
    try {
      final uri = Uri.parse(
        'https://query.wikidata.org/sparql',
      ).replace(queryParameters: {'query': query});

      final response = await _client
          .get(
            uri,
            headers: const {
              'User-Agent': 'AgeCalculatorApp/1.1 (https://khokan.me)',
              'Api-User-Agent': 'AgeCalculatorApp/1.1 (https://khokan.me)',
              'Accept': 'application/sparql-results+json',
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

      final results = decoded['results'];
      if (results is! Map<String, dynamic>) {
        return const [];
      }

      final bindings = results['bindings'];
      if (bindings is! List) {
        return const [];
      }

      final items = <FamousBirthday>[];
      for (final raw in bindings) {
        if (raw is! Map<String, dynamic>) {
          continue;
        }

        final personLabel = _bindingValue(raw, 'personLabel');
        if (personLabel == null || personLabel.trim().isEmpty) {
          continue;
        }

        final birthDateRaw = _bindingValue(raw, 'birthDate');
        final birthYear = _extractYear(birthDateRaw);
        final description = _bindingValue(raw, 'personDescription');
        final image = _bindingValue(raw, 'image');
        final article = _bindingValue(raw, 'article');
        final countryRaw = _bindingValue(raw, countryField);

        items.add(
          FamousBirthday(
            name: personLabel.trim(),
            birthYear: birthYear,
            description: description,
            thumbnailUrl: image,
            pageUrl: article,
            countryTag: _detectCountry(
              '${countryRaw ?? ''} ${description ?? ''}',
            ),
            sourceLocale: source,
          ),
        );
      }

      return items;
    } catch (_) {
      return const [];
    }
  }

  String? _bindingValue(Map<String, dynamic> binding, String key) {
    final field = binding[key];
    if (field is! Map<String, dynamic>) {
      return null;
    }
    final value = field['value'];
    return value is String ? value.trim() : null;
  }

  int? _extractYear(String? value) {
    if (value == null || value.length < 4) {
      return null;
    }
    return int.tryParse(value.substring(0, 4));
  }

  List<FamousBirthday> _dedupeAndRank(
    List<FamousBirthday> items,
    AppLocale locale,
  ) {
    final seen = <String>{};
    final deduped = <FamousBirthday>[];

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
      final ay = a.birthYear ?? 99999;
      final by = b.birthYear ?? 99999;
      return ay.compareTo(by);
    });

    return deduped;
  }

  int _priority(FamousBirthday item, AppLocale locale) {
    if (item.isCurated) {
      return 3;
    }
    if (item.isRegional(locale.languageCode)) {
      return 2;
    }
    // For South-Asian users, Wikidata-sourced regional people still rank above
    // generic global results.
    if (locale.isSouthAsian && _isSouthAsianItem(item)) {
      return 2;
    }
    return 1;
  }

  String _pickName(Map<String, dynamic>? page, String? text) {
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

    return text.split(',').first.trim();
  }

  String? _pickDescription(Map<String, dynamic>? page, String? text) {
    final extract = (page?['extract'] as String?)?.trim();
    if (extract != null && extract.isNotEmpty) {
      return extract;
    }
    return text;
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

  String? _detectCountry(String input) {
    final t = input.toLowerCase();
    if (t.contains('bangladesh') ||
        t.contains('bangladeshi') ||
        t.contains('বাংলাদেশ')) {
      return 'bangladesh';
    }
    if (t.contains('india') || t.contains('indian') || t.contains('ভারত')) {
      return 'india';
    }
    return null;
  }

  List<FamousBirthday>? _readCache(String monthDay, AppLocale locale) {
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
          .map((item) => FamousBirthday.fromJson(item.cast<String, dynamic>()))
          .where((item) => item.name.trim().isNotEmpty)
          .take(10)
          .toList(growable: false);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(
    String monthDay,
    AppLocale locale,
    List<FamousBirthday> items,
  ) {
    final payload = items.map((e) => e.toJson()).toList(growable: false);
    return _sharedPreferences.setString(
      '$_cachePrefix${locale.cacheKey}_$monthDay',
      jsonEncode(payload),
    );
  }
}
