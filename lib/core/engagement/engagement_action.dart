enum EngagementAction {
  age('age'),
  profile('profile'),
  people('people'),
  lifeEvent('life_event'),
  share('share'),
  dateTools('date_tools');

  const EngagementAction(this.analyticsValue);

  final String analyticsValue;
}
