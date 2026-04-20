import 'dart:io' show Platform;

/// AdMob IDs.
///
/// ملاحظة: دي IDs تجريبية من جوجل (Test IDs) عشان التطوير.
/// بدّلها بـ IDs الحقيقية قبل الإطلاق.
class AdMobIds {
  static String bannerUnitId() {
    if (Platform.isAndroid) return 'ca-app-pub-3940256099942544/6300978111';
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/2934735716';
    return '';
  }
}

