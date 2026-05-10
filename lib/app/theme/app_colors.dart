import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF0EA5E9);

  static ColorScheme lightScheme() =>
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light);

  static ColorScheme darkScheme() =>
      ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark);
}
