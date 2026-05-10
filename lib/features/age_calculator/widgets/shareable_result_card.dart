import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../age_calculator/domain/models/age_result.dart';
import '../utils/life_facts_utils.dart';
import '../utils/zodiac_utils.dart';

/// A self-contained, branded poster of the age result, designed to be captured
/// as an image and shared on social media. It deliberately uses fixed colors and
/// explicit sizing (rather than the app theme) so it renders identically off
/// screen regardless of the user's light/dark setting.
class ShareableResultCard extends StatelessWidget {
  const ShareableResultCard({super.key, required this.result});

  final AgeResult result;

  // Brand palette (seed #0EA5E9) kept fixed for a consistent shared image.
  static const Color _bgTop = Color(0xFF0B1220);
  static const Color _bgBottom = Color(0xFF0EA5E9);
  static const Color _accent = Color(0xFF38BDF8);
  static const Color _onDark = Color(0xFFF8FAFC);
  static const Color _muted = Color(0xFFB9C2D0);

  /// Logical width of the poster. Capture at pixelRatio 3 → 1080px wide.
  static const double width = 360;

  @override
  Widget build(BuildContext context) {
    final zodiac = ZodiacUtils.fromBirthDate(result.birthDate);
    final facts = LifeFactsUtils.fromTotalDays(result.totalDays);
    final heartbeats = facts.firstWhere((f) => f.label == 'Heartbeats');
    final breaths = facts.firstWhere((f) => f.label == 'Breaths taken');

    return Container(
      width: width,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, Color(0xFF0F2A43), _bgBottom],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.cake_outlined, color: _accent, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  AppStrings.appName,
                  style: GoogleFonts.inter(
                    color: _onDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'I AM',
              style: GoogleFonts.inter(
                color: _muted,
                fontSize: 13,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${result.years}',
              style: GoogleFonts.inter(
                color: _onDark,
                fontSize: 88,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'years, ${result.months} months & ${result.days} days old',
              style: GoogleFonts.inter(
                color: _accent,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: 'Days lived',
                    value: AppDateUtils.formatLargeInteger(result.totalDays),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatBox(
                    label: 'Next birthday',
                    value: '${result.daysUntilNextBirthday}d',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                    label: '${zodiac.westernSymbol} Zodiac',
                    value: zodiac.westernSign,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _StatBox(
                    label: '${zodiac.chineseEmoji} Chinese',
                    value: zodiac.chineseAnimal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _StatBox(
              label: '❤️ Heartbeats · 🫁 Breaths',
              value: '${heartbeats.value}  ·  ${breaths.value}',
            ),
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Text(
                'Calculate yours · ${AppStrings.appName}',
                style: GoogleFonts.inter(
                  color: _muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              color: ShareableResultCard._muted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.inter(
              color: ShareableResultCard._onDark,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
