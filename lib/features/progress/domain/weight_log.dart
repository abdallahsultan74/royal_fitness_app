class WeightLog {
  const WeightLog({
    required this.id,
    required this.loggedAt,
    required this.weightKg,
    required this.source,
  });

  final String id;
  final DateTime loggedAt;
  final double weightKg;
  final String source;
}
