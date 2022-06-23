class PlannedDowntime {
  final int hour;
  final double downtime;

  PlannedDowntime({
    required this.downtime,
    required this.hour,
  });

  @override
  String toString() {
    return downtime.toString();
  }
}
