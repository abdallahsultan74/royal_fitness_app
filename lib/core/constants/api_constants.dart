/// RapidAPI / ExerciseDB-related constants.
/// Pass secrets via: `--dart-define=RAPIDAPI_KEY=your_key`
abstract final class ApiConstants {
  /// ExerciseDB on RapidAPI — replace host if you use a different API.
  static const String rapidApiBaseUrl =
      'https://exercisedb.p.rapidapi.com';

  static const String rapidApiHost = 'exercisedb.p.rapidapi.com';

  /// Set at build/run time; never commit real keys.
  static String get rapidApiKey =>
      const String.fromEnvironment('RAPIDAPI_KEY', defaultValue: '');
}
