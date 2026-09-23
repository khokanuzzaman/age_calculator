import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/share_card_branding.dart';
import '../models/birthday_share_card_model.dart';

class BirthdayShareCard extends StatelessWidget {
  const BirthdayShareCard({super.key, required this.model});

  final BirthdayShareCardModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17112B), Color(0xFF6D28D9)],
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(model.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.md),
          Text(
            model.type == BirthdayShareCardType.today
                ? 'BIRTHDAY TODAY'
                : 'COMING UP',
            style: GoogleFonts.inter(
              color: const Color(0xFFE9D5FF),
              fontSize: 13,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            model.headline,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              model.secondary,
              style: GoogleFonts.inter(
                color: const Color(0xFFF5D0FE),
                fontSize: 19,
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
