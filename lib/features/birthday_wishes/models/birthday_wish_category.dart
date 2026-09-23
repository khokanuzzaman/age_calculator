enum BirthdayWishCategory {
  warm('Warm'),
  short('Short'),
  funny('Funny'),
  formal('Formal'),
  family('Family'),
  romantic('Romantic');

  const BirthdayWishCategory(this.label);

  final String label;

  String get analyticsValue => name;
}
