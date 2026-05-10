import 'dart:convert';
import 'dart:io';

import 'package:age_calculator/core/utils/app_locale.dart';
import 'package:age_calculator/features/famous_birthdays/service/famous_birthday_service.dart';
import 'package:age_calculator/features/on_this_day/services/historical_event_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MapAssetBundle extends CachingAssetBundle {
  _MapAssetBundle(this._data);

  final Map<String, String> _data;

  @override
  Future<ByteData> load(String key) async {
    final value = _data[key];
    if (value == null) {
      throw Exception('Asset not found: $key');
    }
    final bytes = Uint8List.fromList(utf8.encode(value));
    return ByteData.view(bytes.buffer);
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _data[key];
    if (value == null) {
      throw Exception('Asset not found: $key');
    }
    return value;
  }
}

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('Famous birthdays loads local Bangladesh data by MM-DD', () async {
    final service = FamousBirthdayService(
      sharedPreferences: prefs,
      client: MockClient((_) async => http.Response('{"births": []}', 200)),
      assetBundle: _MapAssetBundle({
        'assets/data/bangladesh_famous_birthdays.json': jsonEncode([
          {
            'date': '03-17',
            'name': 'Sheikh Mujibur Rahman',
            'birthYear': 1920,
            'description': 'Founding leader of Bangladesh.',
            'region': 'Bangladesh',
            'source': 'local',
          },
        ]),
      }),
    );

    final result = await service.fetchByMonthDay(
      '03-17',
      locale: AppLocale.bangla,
    );

    expect(result, isNotEmpty);
    expect(result.first.name, 'Sheikh Mujibur Rahman');
    expect(result.first.isCurated, isTrue);
  });

  test(
    'Famous birthdays keeps local first and removes duplicate names',
    () async {
      final client = MockClient((request) async {
        if (request.url.path.contains('/onthisday/births/03/17')) {
          return http.Response(
            jsonEncode({
              'births': [
                {
                  'year': 1920,
                  'text': 'Sheikh Mujibur Rahman, Bangladeshi politician',
                  'pages': [
                    {
                      'title': 'Sheikh Mujibur Rahman',
                      'extract': 'Bangladeshi statesman',
                    },
                  ],
                },
                {
                  'year': 1879,
                  'text': 'Albert Einstein, physicist',
                  'pages': [
                    {'title': 'Albert Einstein'},
                  ],
                },
              ],
            }),
            200,
          );
        }
        return http.Response('{"results":{"bindings":[]}}', 200);
      });

      final service = FamousBirthdayService(
        sharedPreferences: prefs,
        client: client,
        assetBundle: _MapAssetBundle({
          'assets/data/bangladesh_famous_birthdays.json': jsonEncode([
            {
              'date': '03-17',
              'name': 'Sheikh Mujibur Rahman',
              'birthYear': 1920,
              'description': 'Founding leader of Bangladesh.',
              'region': 'Bangladesh',
              'source': 'local',
            },
          ]),
        }),
      );

      final result = await service.fetchByMonthDay(
        '03-17',
        locale: AppLocale.bangla,
        forceRefresh: true,
      );

      expect(result.first.name, 'Sheikh Mujibur Rahman');
      expect(result.where((e) => e.name == 'Sheikh Mujibur Rahman').length, 1);
    },
  );

  test('Historical events loads local Bangladesh data offline', () async {
    final service = HistoricalEventService(
      sharedPreferences: prefs,
      client: MockClient((_) async => throw const SocketException('offline')),
      assetBundle: _MapAssetBundle({
        'assets/data/bangladesh_historical_events.json': jsonEncode([
          {
            'date': '12-16',
            'year': 1971,
            'title': 'Victory Day of Bangladesh',
            'description': 'Bangladesh observes Victory Day.',
            'region': 'Bangladesh',
            'type': 'national',
            'source': 'local',
          },
        ]),
      }),
    );

    final result = await service.fetchByMonthDay(
      '12-16',
      locale: AppLocale.bangla,
    );

    expect(result, isNotEmpty);
    expect(result.first.title, 'Victory Day of Bangladesh');
    expect(result.first.isCurated, isTrue);
  });

  test('English locale does not force Bangladesh curated data', () async {
    final service = FamousBirthdayService(
      sharedPreferences: prefs,
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'births': [
              {
                'year': 1879,
                'text': 'Albert Einstein, physicist',
                'pages': [
                  {'title': 'Albert Einstein'},
                ],
              },
            ],
          }),
          200,
        ),
      ),
      assetBundle: _MapAssetBundle({
        'assets/data/bangladesh_famous_birthdays.json': jsonEncode([
          {
            'date': '03-17',
            'name': 'Sheikh Mujibur Rahman',
            'birthYear': 1920,
            'region': 'Bangladesh',
            'source': 'local',
          },
        ]),
      }),
    );

    final result = await service.fetchByMonthDay(
      '03-17',
      locale: AppLocale.english,
      forceRefresh: true,
    );

    // The curated Bangladesh entry must NOT appear for an English user.
    expect(result.any((e) => e.name == 'Sheikh Mujibur Rahman'), isFalse);
    expect(result.any((e) => e.name == 'Albert Einstein'), isTrue);
  });

  test(
    'Historical events local stays first and de-duplicates title/year',
    () async {
      final client = MockClient((request) async {
        if (request.url.path.contains('/onthisday/events/03/26')) {
          return http.Response(
            jsonEncode({
              'events': [
                {
                  'year': 1971,
                  'text': 'Independence Day of Bangladesh',
                  'pages': [
                    {
                      'title': 'Independence Day of Bangladesh',
                      'extract': 'Bangladesh observes Independence Day.',
                    },
                  ],
                },
                {
                  'year': 1967,
                  'text': 'A global event',
                  'pages': [
                    {'title': 'A global event'},
                  ],
                },
              ],
            }),
            200,
          );
        }
        return http.Response('{"events": []}', 200);
      });

      final service = HistoricalEventService(
        sharedPreferences: prefs,
        client: client,
        assetBundle: _MapAssetBundle({
          'assets/data/bangladesh_historical_events.json': jsonEncode([
            {
              'date': '03-26',
              'year': 1971,
              'title': 'Independence Day of Bangladesh',
              'description': 'Bangladesh observes Independence Day.',
              'region': 'Bangladesh',
              'type': 'national',
              'source': 'local',
            },
          ]),
        }),
      );

      final result = await service.fetchByMonthDay(
        '03-26',
        locale: AppLocale.bangla,
        forceRefresh: true,
      );

      expect(result.first.title, 'Independence Day of Bangladesh');
      expect(
        result.where((e) => e.title == 'Independence Day of Bangladesh').length,
        1,
      );
    },
  );
}
