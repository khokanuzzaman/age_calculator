/// Coarse, non-identifying classifications used only for product analytics.
class AnalyticsClassification {
  AnalyticsClassification._();

  static String ageGroup(int years) {
    if (years < 18) {
      return 'under_18';
    }
    if (years < 25) {
      return '18_24';
    }
    if (years < 35) {
      return '25_34';
    }
    if (years < 45) {
      return '35_44';
    }
    if (years < 55) {
      return '45_54';
    }
    if (years < 65) {
      return '55_64';
    }
    return '65_plus';
  }

  static String dateDifferenceDirection(DateTime start, DateTime end) {
    if (end.isAtSameMomentAs(start)) {
      return 'same_day';
    }
    return end.isAfter(start) ? 'future' : 'past';
  }
}
