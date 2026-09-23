import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../models/life_calendar_model.dart';

class LifeCalendarShareCard extends StatelessWidget {
  const LifeCalendarShareCard({super.key, required this.summary});

  final LifeCalendarSummary summary;

  static const _background = Color(0xFF0B1220);
  static const _accent = Color(0xFF38BDF8);
  static const _lived = Color(0xFF0EA5E9);
  static const _current = Color(0xFFF59E0B);
  static const _future = Color(0xFF334155);
  static const _event = Color(0xFFA855F7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      color: _background,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.grid_view_rounded, color: _accent, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                AppStrings.appName,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'MY LIFE IN WEEKS',
            style: GoogleFonts.inter(
              color: _accent,
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${summary.completedWeeks} weeks lived',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            summary.currentAge.compactText,
            style: GoogleFonts.inter(
              color: _accent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: 1,
            runSpacing: 1,
            children: [
              for (final week in summary.weeks)
                SizedBox(
                  width: 5,
                  height: 5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: week.hasEvents
                          ? _event
                          : week.isCurrent
                          ? _current
                          : week.isLived
                          ? _lived
                          : _future,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            '${summary.horizonYears}-year visual horizon · ${summary.eventCount} life events marked',
            style: GoogleFonts.inter(
              color: const Color(0xFFB9C2D0),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
