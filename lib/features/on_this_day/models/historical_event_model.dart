class HistoricalEvent {
  const HistoricalEvent({
    required this.title,
    this.year,
    this.description,
    this.region,
    this.type,
    this.pageUrl,
    this.thumbnailUrl,
    required this.source,
    this.date,
  });

  final String title;
  final int? year;
  final String? description;
  final String? region;
  final String? type;
  final String? pageUrl;
  final String? thumbnailUrl;
  final String source;
  final String? date;

  /// Came from the app's bundled curated dataset (highest relevance).
  bool get isCurated => source == 'local';

  /// Relevant to the user's own region: either curated, or sourced from the
  /// user's (non-English) Wikipedia language edition.
  bool isRegional(String languageCode) =>
      isCurated || (languageCode != 'en' && source == languageCode);

  String get dedupeKey {
    final y = year?.toString() ?? 'na';
    final t = title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
    return '$y|$t';
  }

  factory HistoricalEvent.fromJson(Map<String, dynamic> json) {
    final rawYear = json['year'];
    final parsedYear = switch (rawYear) {
      int value => value,
      num value => value.toInt(),
      String value => int.tryParse(value),
      _ => null,
    };

    return HistoricalEvent(
      title: (json['title'] as String?)?.trim() ?? '',
      year: parsedYear,
      description: (json['description'] as String?)?.trim(),
      region: (json['region'] as String?)?.trim(),
      type: (json['type'] as String?)?.trim(),
      pageUrl: (json['pageUrl'] as String?)?.trim(),
      thumbnailUrl: (json['thumbnailUrl'] as String?)?.trim(),
      source: (json['source'] as String?)?.trim() ?? 'cache',
      date: (json['date'] as String?)?.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'year': year,
      'description': description,
      'region': region,
      'type': type,
      'pageUrl': pageUrl,
      'thumbnailUrl': thumbnailUrl,
      'source': source,
      'date': date,
    };
  }
}
