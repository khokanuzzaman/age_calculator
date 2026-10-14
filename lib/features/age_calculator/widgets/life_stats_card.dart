import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../shared/widgets/animated_count_text.dart';
import '../../../shared/widgets/animated_progress_bar.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_stat_tile.dart';
import '../models/age_milestone_model.dart';

class LifeStatsCard extends StatefulWidget {
  const LifeStatsCard({super.key, required this.stats, this.birthDate});

  final LifeStats stats;

  /// When provided, hours / minutes / seconds tick live every second.
  /// Days and the progress bars keep the values from [stats].
  final DateTime? birthDate;

  @override
  State<LifeStatsCard> createState() => _LifeStatsCardState();
}

class _LifeStatsCardState extends State<LifeStatsCard> {
  Timer? _timer;
  late int _hours;
  late int _minutes;
  late int _seconds;

  @override
  void initState() {
    super.initState();
    _syncFromStats();
    _startTickerIfNeeded();
  }

  @override
  void didUpdateWidget(covariant LifeStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // `stats` is rebuilt (new instance) on every parent build, so only a
    // different birth date restarts the ticker.
    if (oldWidget.birthDate != widget.birthDate) {
      _timer?.cancel();
      _timer = null;
      _syncFromStats();
      _startTickerIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _syncFromStats() {
    _hours = widget.stats.totalHours;
    _minutes = widget.stats.totalMinutes;
    _seconds = widget.stats.totalSeconds;
  }

  void _startTickerIfNeeded() {
    if (widget.birthDate == null) {
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final birth = widget.birthDate;
    if (!mounted || birth == null) {
      return;
    }
    final elapsed = DateTime.now().difference(AppDateUtils.dateOnly(birth));
    if (elapsed.isNegative) {
      return;
    }
    setState(() {
      _hours = elapsed.inHours;
      _minutes = elapsed.inMinutes;
      _seconds = elapsed.inSeconds;
    });
  }

  Widget _liveText(BuildContext context, int value) {
    return Text(
      AppDateUtils.formatLargeInteger(value),
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _countValue(BuildContext context, int value) {
    return AnimatedCountText(
      value: value,
      formatter: (n) => AppDateUtils.formatLargeInteger(n.round()),
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final stats = widget.stats;
    final isLive = widget.birthDate != null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Life Stats', style: textTheme.titleLarge),
          const SizedBox(height: AppSpacing.base),
          AppStatTile(
            label: 'Total days lived',
            valueWidget: _countValue(context, stats.totalDays),
            icon: Icons.today_outlined,
          ),
          AppStatTile(
            label: 'Total hours lived',
            valueWidget: isLive
                ? _liveText(context, _hours)
                : _countValue(context, stats.totalHours),
            icon: Icons.access_time,
          ),
          AppStatTile(
            label: 'Total minutes lived',
            valueWidget: isLive
                ? _liveText(context, _minutes)
                : _countValue(context, stats.totalMinutes),
            icon: Icons.timer_outlined,
          ),
          AppStatTile(
            label: 'Total seconds lived',
            valueWidget: isLive
                ? _liveText(context, _seconds)
                : _countValue(context, stats.totalSeconds),
            icon: Icons.hourglass_bottom,
          ),
          const SizedBox(height: AppSpacing.base),
          _ProgressRow(label: 'Year completed', value: stats.yearProgress),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(label: 'Month completed', value: stats.monthProgress),
          const SizedBox(height: AppSpacing.sm),
          _ProgressRow(label: 'Week completed', value: stats.weekProgress),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    final normalized = (value / 100).clamp(0, 1).toDouble();

    return AnimatedProgressBar(
      label: label,
      value: normalized,
      duration: const Duration(milliseconds: 1000),
    );
  }
}
