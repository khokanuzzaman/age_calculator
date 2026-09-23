/// Event names reserved for the future analytics vendor integration.
enum AnalyticsEvent {
  appOpen('app_open'),
  ageCalculated('age_calculated'),
  ageResultShared('age_result_shared'),
  birthdaySaved('birthday_saved'),
  birthdayDeleted('birthday_deleted'),
  birthdayReminderEnabled('birthday_reminder_enabled'),
  famousBirthdaysOpened('famous_birthdays_opened'),
  onThisDayOpened('on_this_day_opened'),
  dateDifferenceUsed('date_difference_used'),
  ageDifferenceUsed('age_difference_used'),
  appShareClicked('app_share_clicked'),
  rateAppClicked('rate_app_clicked');

  const AnalyticsEvent(this.name);

  final String name;
}
