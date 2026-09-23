import 'package:intl/intl.dart';

import '../../age_calculator/utils/age_calculation_utils.dart';
import '../../saved_birthdays/models/saved_person.dart';

enum BirthdayShareCardType { today, countdown }

class BirthdayShareCardModel {
  const BirthdayShareCardModel({
    required this.type,
    required this.name,
    required this.emoji,
    required this.headline,
    required this.secondary,
    this.age,
    this.daysRemaining,
  });

  final BirthdayShareCardType type;
  final String name;
  final String emoji;
  final String headline;
  final String secondary;
  final int? age;
  final int? daysRemaining;

  factory BirthdayShareCardModel.fromPerson(SavedPerson person, DateTime now) {
    final details = AgeCalculationUtils.birthdayDetails(person.birthDate, now);
    if (details.daysUntilNextBirthday == 0) {
      return BirthdayShareCardModel(
        type: BirthdayShareCardType.today,
        name: person.name,
        emoji: person.emoji,
        headline: 'Happy Birthday, ${person.name}! 🎂',
        secondary: '${person.ageInYears(now)} today',
        age: person.ageInYears(now),
      );
    }
    return BirthdayShareCardModel(
      type: BirthdayShareCardType.countdown,
      name: person.name,
      emoji: person.emoji,
      headline:
          '${details.daysUntilNextBirthday} days until ${person.name}\'s birthday 🎉',
      secondary: DateFormat('d MMMM').format(details.nextBirthdayDate),
      daysRemaining: details.daysUntilNextBirthday,
    );
  }

  String get shareText => type == BirthdayShareCardType.today
      ? '$headline\n$secondary'
      : '$headline\n$secondary';
}
