import '../models/birthday_wish_category.dart';
import '../models/birthday_wish_template.dart';

/// Offline, deterministic birthday copy. Templates are intentionally curated
/// and contain no network, model, or personalization service.
class BirthdayWishService {
  BirthdayWishService._();

  static const Map<BirthdayWishCategory, List<BirthdayWishTemplate>>
  templates = {
    BirthdayWishCategory.warm: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text:
            'Happy birthday, {name}! Wishing you a day full of joy and warmth.',
        ageText: 'Here is to {age} wonderful years.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text:
            'Happy birthday, {name}! May the year ahead bring you many bright moments.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text:
            'Sending you the happiest birthday wishes, {name}. Enjoy every moment!',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text:
            'Happy birthday, {name}! You deserve a beautiful day and a beautiful year.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text: 'Wishing you laughter, peace, and plenty of cake today, {name}.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.warm,
        text:
            'Have a wonderful birthday, {name}! I hope this one feels extra special.',
      ),
    ],
    BirthdayWishCategory.short: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Happy birthday, {name}! 🎂',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Many happy returns, {name}! 🎉',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Have the best birthday, {name}!',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Cheers to you, {name}! Happy birthday.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Birthday hugs for you, {name}! 💛',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.short,
        text: 'Celebrate big today, {name}!',
      ),
    ],
    BirthdayWishCategory.funny: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text: 'Happy birthday, {name}! Cake calories do not count today.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text:
            'Happy birthday, {name}! You are not older, just more experienced at birthdays.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text:
            'Congratulations, {name}: you made it another year without becoming boring.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text:
            'Happy birthday, {name}! Today your to-do list is officially just cake.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text: 'Have a fantastic birthday, {name}! Please save me some cake.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.funny,
        text:
            'Happy birthday, {name}! You still look remarkably young in birthday photos.',
      ),
    ],
    BirthdayWishCategory.formal: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Wishing you a very happy birthday, {name}, and continued success in the year ahead.',
        ageText: 'Warm wishes as you celebrate {age} years.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Please accept my sincere birthday wishes, {name}. May your year be rewarding and joyful.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Happy birthday, {name}. Wishing you health, happiness, and a memorable celebration.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Best wishes on your birthday, {name}. I hope the coming year is excellent for you.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Many happy returns, {name}. May this special day be the start of a wonderful year.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.formal,
        text:
            'Warm birthday greetings to you, {name}. Enjoy a well-deserved celebration.',
      ),
    ],
    BirthdayWishCategory.family: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text:
            'Happy birthday, {name}! Our family is brighter because you are in it.',
        ageText: 'Celebrating you and your {age} amazing years today.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text: 'Happy birthday to a truly special part of our family, {name}!',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text:
            'Sending family-sized birthday hugs to you, {name}. Have a wonderful day!',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text:
            'Happy birthday, {name}! I am so grateful for every memory we share.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text:
            'Wishing my wonderful family member {name} a day full of love and laughter.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.family,
        text: 'Have the happiest birthday, {name}. We love celebrating you!',
      ),
    ],
    BirthdayWishCategory.romantic: [
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'Happy birthday, {name}! You make ordinary days feel extraordinary.',
        ageText: 'I love celebrating every one of your {age} years.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'Happy birthday to my favorite person, {name}. I hope your day is as lovely as you are.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'To {name}: my heart is happiest when I am with you. Happy birthday!',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'Happy birthday, {name}. Thank you for making life sweeter every day.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'Celebrating you today, {name}, and feeling lucky to share this life with you.',
      ),
      BirthdayWishTemplate(
        category: BirthdayWishCategory.romantic,
        text:
            'Happy birthday, {name}, my love. I hope this year brings us even more beautiful memories.',
      ),
    ],
  };

  static BirthdayWish create({
    required BirthdayWishCategory category,
    required int index,
    required String name,
    int? age,
    bool useAge = false,
  }) {
    final choices = templates[category]!;
    final normalizedIndex = index % choices.length;
    final template = choices[normalizedIndex];
    var text = template.text.replaceAll('{name}', name.trim());
    if (useAge && age != null && template.ageText != null) {
      text = '$text ${template.ageText!.replaceAll('{age}', '$age')}';
    }
    return BirthdayWish(
      category: category,
      index: normalizedIndex,
      text: text.trim(),
      supportsAge: template.supportsAge,
    );
  }

  static int nextIndex(BirthdayWishCategory category, int index) {
    return (index + 1) % templates[category]!.length;
  }

  static int previousIndex(BirthdayWishCategory category, int index) {
    final count = templates[category]!.length;
    return (index - 1 + count) % count;
  }
}
