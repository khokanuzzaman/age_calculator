enum BirthdayRegionFilter { all, regional }

class FamousBirthday {
  const FamousBirthday({
    required this.name,
    this.birthYear,
    this.description,
    this.thumbnailUrl,
    this.pageUrl,
    this.countryTag,
    this.sourceLocale,
  });

  final String name;
  final int? birthYear;
  final String? description;
  final String? thumbnailUrl;
  final String? pageUrl;
  final String? countryTag;
  final String? sourceLocale;

  /// Came from the app's bundled curated dataset (highest relevance).
  bool get isCurated => (sourceLocale ?? '') == 'local';

  /// Relevant to the user's own region: either curated, or sourced from the
  /// user's (non-English) Wikipedia language edition.
  bool isRegional(String languageCode) =>
      isCurated ||
      (languageCode != 'en' && (sourceLocale ?? '') == languageCode);

  String get dedupeKey =>
      name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();

  factory FamousBirthday.fromJson(Map<String, dynamic> json) {
    final rawYear = json['birthYear'];
    final parsedYear = switch (rawYear) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };

    return FamousBirthday(
      name: (json['name'] as String?)?.trim() ?? '',
      birthYear: parsedYear,
      description: (json['description'] as String?)?.trim(),
      thumbnailUrl: (json['thumbnailUrl'] as String?)?.trim(),
      pageUrl: (json['pageUrl'] as String?)?.trim(),
      countryTag: (json['countryTag'] as String?)?.trim(),
      sourceLocale: (json['sourceLocale'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'birthYear': birthYear,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'pageUrl': pageUrl,
      'countryTag': countryTag,
      'sourceLocale': sourceLocale,
    };
  }
}
