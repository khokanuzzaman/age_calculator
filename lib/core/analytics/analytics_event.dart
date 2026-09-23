/// Event names reserved for the future analytics vendor integration.
enum AnalyticsEvent {
  appOpen('app_open'),
  ageCalculated('age_calculated'),
  ageResultShared('age_result_shared'),
  birthdaySaved('birthday_saved'),
  birthdayUpdated('birthday_updated'),
  birthdayDeleted('birthday_deleted'),
  birthdayReminderEnabled('birthday_reminder_enabled'),
  notificationPermissionDenied('notification_permission_denied'),
  famousBirthdaysOpened('famous_birthdays_opened'),
  onThisDayOpened('on_this_day_opened'),
  dateDifferenceUsed('date_difference_used'),
  ageDifferenceUsed('age_difference_used'),
  appShareClicked('app_share_clicked'),
  rateAppClicked('rate_app_clicked'),
  lifeCalendarOpened('life_calendar_opened'),
  lifeTimelineOpened('life_timeline_opened'),
  timelineEventAdded('timeline_event_added'),
  timelineEventUpdated('timeline_event_updated'),
  timelineEventDeleted('timeline_event_deleted');

  const AnalyticsEvent(this.name);

  final String name;
}
