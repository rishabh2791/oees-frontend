class BadRateProduction {
  final int hour;
  final double production;

  BadRateProduction({
    required this.hour,
    required this.production,
  });

  @override
  String toString() {
    return hour.toString() + "_" + production.toString();
  }
}
