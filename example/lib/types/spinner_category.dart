enum SpinnerCategory {
  dots('dots', 'Dots'),
  bars('bars', 'Bars'),
  square('square', 'Square'),
  lines('lines', 'Lines'),
  widgets('widgets', 'Widgets'),
  state('state', 'State');

  final String value;
  final String label;

  const SpinnerCategory(this.value, this.label);

  static SpinnerCategory fromLabel(String label) {
    return SpinnerCategory.values.firstWhere(
      (e) => e.label.toLowerCase() == label.toLowerCase(),
      orElse: () => SpinnerCategory.dots,
    );
  }
}
