class ControlledDowntime {
  final int hour;
  final double downtime;

  ControlledDowntime({
    required this.downtime,
    required this.hour,
  });

  @override
  String toString() {
    return downtime.toString();
  }
}
