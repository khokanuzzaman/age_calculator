import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/app_analytics.dart';
import '../../../core/analytics/app_analytics_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/sharing/share_engine.dart';
import '../../../core/sharing/share_payload.dart';
import '../../saved_birthdays/models/saved_person.dart';
import '../models/birthday_wish_category.dart';
import '../models/birthday_wish_template.dart';
import '../utils/birthday_wish_service.dart';

Future<void> showBirthdayWishComposer(
  BuildContext context, {
  required SavedPerson person,
  required int age,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) => _BirthdayWishComposer(person: person, age: age),
  );
}

class _BirthdayWishComposer extends ConsumerStatefulWidget {
  const _BirthdayWishComposer({required this.person, required this.age});

  final SavedPerson person;
  final int age;

  @override
  ConsumerState<_BirthdayWishComposer> createState() =>
      _BirthdayWishComposerState();
}

class _BirthdayWishComposerState extends ConsumerState<_BirthdayWishComposer> {
  BirthdayWishCategory _category = BirthdayWishCategory.warm;
  int _index = 0;
  bool _useAge = false;
  late final TextEditingController _controller;

  BirthdayWish get _wish => BirthdayWishService.create(
    category: _category,
    index: _index,
    name: widget.person.name,
    age: widget.age,
    useAge: _useAge,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _wish.text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(appAnalyticsProvider)
            .logEventSafely(
              AnalyticsEvent.birthdayWishOpened,
              parameters: <String, Object>{
                'category': _category.analyticsValue,
              },
            );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _refreshWish() {
    _controller.text = _wish.text;
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  void _selectCategory(BirthdayWishCategory category) {
    setState(() {
      _category = category;
      _index = 0;
      _useAge = false;
      _refreshWish();
    });
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayWishCategoryChanged,
          parameters: <String, Object>{'category': category.analyticsValue},
        );
  }

  void _step(bool next) {
    setState(() {
      _index = next
          ? BirthdayWishService.nextIndex(_category, _index)
          : BirthdayWishService.previousIndex(_category, _index);
      _refreshWish();
    });
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _controller.text.trim()));
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayWishCopied,
          parameters: <String, Object>{'category': _category.analyticsValue},
        );
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wish copied')));
    }
  }

  Future<void> _share() async {
    await ShareEngine().share(
      context,
      SharePayload(text: _controller.text.trim(), subject: 'Birthday wish'),
    );
    ref
        .read(appAnalyticsProvider)
        .logEventSafely(
          AnalyticsEvent.birthdayWishShared,
          parameters: const <String, Object>{'format': 'text'},
        );
  }

  @override
  Widget build(BuildContext context) {
    final supportsAge = _wish.supportsAge;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        0,
        AppSpacing.base,
        AppSpacing.base,
      ),
      child: ListView(
        shrinkWrap: true,
        children: [
          Text(
            'Birthday wish for ${widget.person.name}',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final category in BirthdayWishCategory.values) ...[
                  ChoiceChip(
                    label: Text(category.label),
                    selected: category == _category,
                    onSelected: (_) => _selectCategory(category),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Your wish',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          if (supportsAge) ...[
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use age in wish'),
              value: _useAge,
              onChanged: (value) {
                setState(() {
                  _useAge = value;
                  _refreshWish();
                });
              },
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _step(false),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _step(true),
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: _share,
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
