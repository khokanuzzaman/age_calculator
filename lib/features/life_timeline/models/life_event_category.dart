enum LifeEventCategory {
  personal('Personal', '⭐'),
  education('Education', '🎓'),
  career('Career', '💼'),
  relationship('Relationship', '❤️'),
  family('Family', '👨‍👩‍👧'),
  home('Home', '🏠'),
  travel('Travel', '✈️'),
  achievement('Achievement', '🏆'),
  financial('Financial', '💰'),
  custom('Custom', '⭐');

  const LifeEventCategory(this.label, this.defaultEmoji);

  final String label;
  final String defaultEmoji;
}
