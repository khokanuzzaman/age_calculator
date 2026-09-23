import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/share_card_branding.dart';
import '../models/life_event.dart';
import '../utils/life_event_utils.dart';

class LifeEventShareCard extends StatelessWidget {
  const LifeEventShareCard({
    super.key,
    required this.event,
    required this.details,
  });

  final LifeEvent event;
  final LifeEventDetails details;

  static const Color _bgTop = Color(0xFF0B1220);
  static const Color _bgBottom = Color(0xFF0EA5E9);
  static const Color _accent = Color(0xFF38BDF8);
  static const Color _onDark = Color(0xFFF8FAFC);
  @override
  Widget build(BuildContext context) {
    final age = details.ageAtEvent;
    final ageLine = age == null
        ? 'Add your birthday to see your age at this moment.'
        : '${details.isUpcoming ? 'You will be' : 'You were'} '
              '${age.years} years, ${age.months} months & ${age.days} days old';

    return Container(
      width: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_bgTop, Color(0xFF0F2A43), _bgBottom],
          stops: [0, 0.55, 1],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_outlined, color: _accent, size: 22),
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
          const SizedBox(height: AppSpacing.xxl),
          Text(
            event.emoji,
            style: const TextStyle(fontSize: 46),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            event.title,
            style: GoogleFonts.inter(
              color: _onDark,
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            details.relativeText,
            style: GoogleFonts.inter(
              color: _accent,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Text(
              ageLine,
              style: GoogleFonts.inter(
                color: _onDark,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const ShareCardBranding(),
        ],
      ),
    );
  }
}
