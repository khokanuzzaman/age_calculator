import 'birthday_wish_category.dart';

class BirthdayWishTemplate {
  const BirthdayWishTemplate({
    required this.category,
    required this.text,
    this.ageText,
  });

  final BirthdayWishCategory category;
  final String text;
  final String? ageText;

  bool get supportsAge => ageText != null;
}

class BirthdayWish {
  const BirthdayWish({
    required this.category,
    required this.index,
    required this.text,
    required this.supportsAge,
  });

  final BirthdayWishCategory category;
  final int index;
  final String text;
  final bool supportsAge;
}
