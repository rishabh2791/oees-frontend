class GoodRateProduction {
  final int hour;
  final double production;

  GoodRateProduction({
    required this.hour,
    required this.production,
  });

  @override
  String toString() {
    return hour.toString() + "_" + production.toString();
  }
}
