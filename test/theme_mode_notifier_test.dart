import 'package:age_calculator/app/theme/theme_mode_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> createContainer({
    Map<String, Object> preferences = const {},
  }) async {
    SharedPreferences.setMockInitialValues(preferences);
    final sharedPreferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ThemeModeNotifier', () {
    test('defaults to dark mode when no value is stored', () async {
      final container = await createContainer();

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('restores system mode when explicitly stored', () async {
      final container = await createContainer(
        preferences: const {'theme_mode': 'system'},
      );

      expect(container.read(themeModeProvider), ThemeMode.system);
    });

    test('restores a stored theme mode', () async {
      final container = await createContainer(
        preferences: const {'theme_mode': 'dark'},
      );

      expect(container.read(themeModeProvider), ThemeMode.dark);
    });

    test('persists theme mode changes', () async {
      final container = await createContainer();
      final notifier = container.read(themeModeProvider.notifier);

      await notifier.setThemeMode(ThemeMode.light);

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(
        container.read(sharedPreferencesProvider).getString('theme_mode'),
        'light',
      );
    });
  });
}
