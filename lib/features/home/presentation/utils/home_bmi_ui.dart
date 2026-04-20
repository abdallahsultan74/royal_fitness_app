import 'package:easy_localization/easy_localization.dart';

/// Slider thumb horizontal position (0–1) for BMI ~16–36 on a 4-zone bar.
double homeBmiMarkerFraction(double? bmi) {
  if (bmi == null) return 0.37;
  return ((bmi - 16) / 20).clamp(0.0, 1.0);
}

String homeBmiStatusLabel(String? status) {
  final x = (status ?? '').toLowerCase();
  if (x == 'underweight') return 'progress_bmi_status_underweight'.tr();
  if (x == 'normal') return 'home_bmi_normal'.tr();
  if (x == 'overweight') return 'progress_bmi_status_overweight'.tr();
  if (x == 'obese') return 'progress_bmi_status_obese'.tr();
  return 'progress_bmi_status_normal'.tr();
}
