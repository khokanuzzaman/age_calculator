import 'package:age_calculator/core/analytics/analytics_event.dart';
import 'package:age_calculator/core/analytics/noop_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('centralizes the required analytics event names', () {
    expect(AnalyticsEvent.appOpen.name, 'app_open');
    expect(AnalyticsEvent.ageCalculated.name, 'age_calculated');
    expect(AnalyticsEvent.ageResultShared.name, 'age_result_shared');
    expect(AnalyticsEvent.birthdaySaved.name, 'birthday_saved');
    expect(AnalyticsEvent.birthdayDeleted.name, 'birthday_deleted');
    expect(
      AnalyticsEvent.birthdayReminderEnabled.name,
      'birthday_reminder_enabled',
    );
    expect(
      AnalyticsEvent.famousBirthdaysOpened.name,
      'famous_birthdays_opened',
    );
    expect(AnalyticsEvent.onThisDayOpened.name, 'on_this_day_opened');
    expect(AnalyticsEvent.dateDifferenceUsed.name, 'date_difference_used');
    expect(AnalyticsEvent.ageDifferenceUsed.name, 'age_difference_used');
    expect(AnalyticsEvent.appShareClicked.name, 'app_share_clicked');
    expect(AnalyticsEvent.rateAppClicked.name, 'rate_app_clicked');
  });

  test('the default analytics implementation is a safe no-op', () async {
    await const NoopAnalytics().logEvent(AnalyticsEvent.appOpen);
  });
}
