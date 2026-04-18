/// BMI from height (cm) and weight (kg); status matches DB / progress labels.
class BmiUtils {
  BmiUtils._();

  /// Returns rounded BMI and status: underweight, normal, overweight, obese.
  static ({double bmi, String status})? compute({
    required double? heightCm,
    required double? weightKg,
  }) {
    if (heightCm == null || weightKg == null || heightCm <= 0 || weightKg <= 0) {
      return null;
    }
    final m = heightCm / 100.0;
    final raw = weightKg / (m * m);
    final bmi = double.parse(raw.toStringAsFixed(1));
    String status;
    if (raw < 18.5) {
      status = 'underweight';
    } else if (raw < 25) {
      status = 'normal';
    } else if (raw < 30) {
      status = 'overweight';
    } else {
      status = 'obese';
    }
    return (bmi: bmi, status: status);
  }
}
