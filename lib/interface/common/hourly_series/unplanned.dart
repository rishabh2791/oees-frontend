class UnplannedDowntime {
  final int hour;
  final double downtime;

  UnplannedDowntime({
    required this.downtime,
    required this.hour,
  });

  @override
  String toString() {
    return downtime.toString();
  }
}
