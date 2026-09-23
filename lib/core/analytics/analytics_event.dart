/// Product events sent to the configured analytics provider.
enum AnalyticsEvent {
  // Firebase automatically collects `app_open`; use a separate product
  // event name so the app does not double-log that SDK event.
  appOpen('product_app_open'),
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
  timelineEventDeleted('timeline_event_deleted'),
  primaryProfileSaved('primary_profile_saved'),
  primaryProfileUpdated('primary_profile_updated'),
  primaryProfileCleared('primary_profile_cleared'),
  todayDashboardViewed('today_dashboard_viewed'),
  todayDashboardAction('today_dashboard_action');

  const AnalyticsEvent(this.name);

  final String name;
}
