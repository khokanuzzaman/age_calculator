import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Brightness brightness) {
    final materialTextTheme = brightness == Brightness.dark
        ? Typography.material2021().white
        : Typography.material2021().black;
    final base = GoogleFonts.interTextTheme(materialTextTheme);

    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w400),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w400),
      displaySmall: base.displaySmall?.copyWith(fontWeight: FontWeight.w400),
      headlineLarge: base.headlineLarge?.copyWith(fontWeight: FontWeight.w400),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w400,
      ),
      headlineSmall: base.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w400),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w400),
      bodyLarge: base.bodyLarge?.copyWith(fontWeight: FontWeight.w400),
      bodyMedium: base.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
      bodySmall: base.bodySmall?.copyWith(fontWeight: FontWeight.w400),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500),
      labelSmall: base.labelSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
