import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/royal_tab_scaffold.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/workout_repository.dart';
import '../../domain/daily_stat.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import '../models/local_exercise_item.dart';
import 'active_exercise_page.dart';

class WorkoutLibraryPage extends StatefulWidget {
  const WorkoutLibraryPage({super.key});

  @override
  State<WorkoutLibraryPage> createState() => _WorkoutLibraryPageState();
}

class _WorkoutLibraryPageState extends State<WorkoutLibraryPage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  RealtimeChannel? _exercisesChannel;
  static const String _kJsonPath =
      'assets/exercisedb_v1_sample/exercises.json';
  static const String _kGifBasePath =
      'assets/exercisedb_v1_sample/gifs_360x360';

  String _filter = 'all';
  final TextEditingController _search = TextEditingController();
  bool _loading = true;
  String? _error;
  String _dataMode = 'local';
  List<LocalExerciseItem> _workouts = const [];
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _loadWorkouts();
    _subscribeExercisesChanges();
  }

  @override
  void dispose() {
    if (_exercisesChannel != null) {
      Supabase.instance.client.removeChannel(_exercisesChannel!);
    }
    _search.dispose();
    super.dispose();
  }

  void _subscribeExercisesChanges() {
    final client = Supabase.instance.client;
    _exercisesChannel = client
        .channel('app-exercises-live')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'exercises',
          callback: (_) => _loadWorkoutsFromApi(),
        )
        .subscribe();
  }

  Future<void> _loadWorkouts() async {
    final loadedFromApi = await _loadWorkoutsFromApi();
    if (loadedFromApi) return;
    await _loadLocalWorkouts();
  }

  Future<bool> _loadWorkoutsFromApi() async {
    try {
      final lang = context.locale.languageCode;
      final rows = await Supabase.instance.client.rpc<List<dynamic>>(
        'api_list_exercises',
        params: <String, dynamic>{
          'lang': lang,
          'kind': '',
          'search_query': '',
        },
      );
      if (rows.isEmpty) return false;

      debugPrint('WorkoutLibraryPage API rows: ${rows.length}');

      final mapped = rows
          .whereType<Map>()
          .map((raw) => _mapRemoteWorkout(Map<String, dynamic>.from(raw)))
          .toList(growable: false);

      if (!mounted) return true;
      setState(() {
        _workouts = mapped;
        _loading = false;
        _error = null;
        _dataMode = 'api:${mapped.length}';
      });
      return true;
    } catch (e) {
      debugPrint('WorkoutLibraryPage API error: $e');
      if (mounted) {
        setState(() {
          _error = 'Supabase API error: $e';
          _dataMode = 'api-error';
        });
      }
      return false;
    }
  }

  Future<void> _loadLocalWorkouts() async {
    try {
      final raw = await rootBundle.loadString(_kJsonPath);
      final list = (jsonDecode(raw) as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .toList();

      final mapped = list.map(_mapWorkout).toList(growable: false);
      if (!mounted) return;
      setState(() {
        _workouts = mapped;
        _loading = false;
        _error ??= 'Supabase API returned no rows, showing local fallback.';
        _dataMode = 'local:${mapped.length}';
      });
      _syncExercisesToSupabase(mapped);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
        _dataMode = 'local-error';
      });
    }
  }

  Future<void> _syncExercisesToSupabase(List<LocalExerciseItem> items) async {
    try {
      final client = Supabase.instance.client;
      for (final item in items) {
        await client.from('exercises').upsert(<String, dynamic>{
          'legacy_id': item.id,
          'name': item.name,
          'name_ar': item.nameAr,
          'type': item.type,
          'minutes': item.minutes,
          'calories': item.cal,
          'level': item.level,
          'image_asset_path': item.imageAssetPath,
          'exercise_steps': item.exerciseSteps,
          'rating': item.rating,
          'instructions': item.instructions,
          'source': 'app',
        });
      }
    } catch (_) {
      // Keep local experience stable even if backend sync fails.
    }
  }

  LocalExerciseItem _mapRemoteWorkout(Map<String, dynamic> raw) {
    final levelRaw = (raw['level'] ?? '').toString();
    final level = _levelKey(levelRaw);
    return LocalExerciseItem(
      id: (raw['legacy_id'] ?? raw['id'] ?? '').toString(),
      name: (raw['name'] ?? 'Workout').toString(),
      nameAr: (raw['name_ar'] ?? raw['name'] ?? 'تمرين').toString(),
      type: (raw['type'] ?? 'home').toString(),
      minutes: _toInt(raw['minutes'], fallback: 1),
      cal: _toInt(raw['calories'], fallback: 0),
      level: level,
      imageAssetPath: (raw['image_url'] ?? '').toString(),
      mediaType: (raw['media_type'] ?? 'image').toString(),
      exerciseSteps: _toInt(raw['exercise_steps'], fallback: 0),
      rating: _toDouble(raw['rating'], fallback: 4),
      instructions: (raw['instructions'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e.toString())
          .toList(growable: false),
      audioUrl: raw['audio_url']?.toString(),
      ttsScript: raw['tts_script']?.toString(),
      ttsScriptAr: raw['tts_script_ar']?.toString(),
    );
  }

  int _toInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  double _toDouble(dynamic value, {required double fallback}) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _levelKey(String raw) {
    final value = raw.toLowerCase();
    if (value.contains('beginner')) return 'workout_level_beginner';
    if (value.contains('intermediate')) return 'workout_level_intermediate';
    if (value.contains('advanced')) return 'workout_level_advanced';
    if (value.startsWith('workout_level_')) return raw;
    return 'workout_level_beginner';
  }

  LocalExerciseItem _mapWorkout(Map<String, dynamic> json) {
    final id = (json['exerciseId'] ?? '').toString();
    final name = (json['name'] ?? 'Workout').toString();
    final equipment = _firstOrEmpty(json['equipments']).toLowerCase();
    final bodyPart = _firstOrEmpty(json['bodyParts']).toLowerCase();
    final instructions = _safeList(json['instructions']);
    final gifName = (json['gifUrl'] ?? '').toString();
    final target = _firstOrEmpty(json['targetMuscles']).toLowerCase();

    final type = equipment == 'body weight' || bodyPart == 'cardio'
        ? 'home'
        : 'gym';
    final level = instructions.length <= 4
        ? 'workout_level_beginner'
        : instructions.length <= 6
            ? 'workout_level_intermediate'
            : 'workout_level_advanced';
    final minutes = (instructions.length * 2).clamp(8, 35);
    final cal = _estimateCalories(bodyPart: bodyPart, target: target);
    final rating = 4 + ((id.isEmpty ? 3 : id.codeUnitAt(0) % 10) / 10);

    return LocalExerciseItem(
      id: id,
      name: name,
      nameAr: _arabicName(name),
      type: type,
      minutes: minutes,
      cal: cal,
      level: level,
      imageAssetPath: '$_kGifBasePath/$gifName',
      mediaType: 'image',
      exerciseSteps: instructions.length,
      rating: double.parse(rating.clamp(4, 4.9).toStringAsFixed(1)),
      instructions: instructions,
    );
  }

  static String _arabicName(String englishName) {
    const map = <String, String>{
      'hack calf raise': 'رفع سمانة على جهاز الهاك',
      'sled 45° leg press (side pov)': 'ضغط أرجل 45° على السليد (جانبي)',
      'dumbbell front raise': 'رفع أمامي بالدمبل',
      'dumbbell over bench revers wrist curl': 'ثني معصم عكسي بالدمبل فوق البنش',
      'barbell incline bench press': 'بنش مائل بالبار',
      'cable squatting curl': 'كرل سكوات بالكابل',
      'dumbbell one arm hammer preacher curl': 'هامر كرل ذراع واحدة على بريتشر',
      'barbell standing close grip curl': 'كرل بار بقبضة ضيقة واقف',
      'kettlebell pistol squat': 'سكوات مسدس بالكيتل بيل',
      'impossible dips': 'ديبس صعب',
      'barbell seated overhead triceps extension':
          'تمديد ترايسبس فوق الرأس بالبار جلوس',
      'smith incline bench press': 'بنش مائل على جهاز سميث',
      'weighted side bend (on stability ball)': 'انحناء جانبي بوزن على كرة الثبات',
      'dumbbell one arm upright row': 'سحب رأسي دمبل ذراع واحدة',
      'barbell standing rocking leg calf raise': 'رفع سمانة واقف متأرجح بالبار',
      'barbell wrist curl v. 2': 'ثني معصم بالبار (نسخة 2)',
      'dumbbell lying single extension': 'تمديد دمبل فردي أثناء الاستلقاء',
      'dumbbell reverse spider curl': 'سبايدر كرل عكسي بالدمبل',
      'bent knee lying twist (male)': 'لفّ الركبتين أثناء الاستلقاء',
      'lever front pulldown': 'سحب أمامي على جهاز ليفر',
      'lever seated row': 'تجديف جلوس على جهاز ليفر',
      'dumbbell standing concentration curl': 'كونسنتريشن كرل بالدمبل واقف',
      'cable decline fly': 'فلاي مائل لأسفل بالكابل',
      'smith leg press': 'ضغط أرجل على جهاز سميث',
      'dumbbell palms in incline bench press': 'بنش مائل بالدمبل قبضة داخلية',
      'assisted hanging knee raise with throw down':
          'رفع ركبة معلّق بمساعدة مع دفع لأسفل',
      'cable seated curl': 'كرل جلوس بالكابل',
      'barbell standing calf raise': 'رفع سمانة واقف بالبار',
      'weighted hyperextension (on stability ball)':
          'هايبر إكستنشن بوزن على كرة الثبات',
      'cable seated crunch': 'كرنش جلوس بالكابل',
    };
    return map[englishName.toLowerCase()] ?? englishName;
  }

  static int _estimateCalories({
    required String bodyPart,
    required String target,
  }) {
    if (bodyPart.contains('legs') || target.contains('glutes')) return 240;
    if (bodyPart.contains('back') || bodyPart.contains('chest')) return 220;
    if (bodyPart.contains('waist') || target.contains('abs')) return 170;
    if (bodyPart.contains('arms') || target.contains('biceps')) return 160;
    if (bodyPart.contains('cardio')) return 260;
    return 190;
  }

  static String _firstOrEmpty(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first.toString();
    }
    return '';
  }

  static List<String> _safeList(dynamic value) {
    if (value is List) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const <String>[];
  }

  Color _levelColor(String levelKey) {
    if (levelKey == 'workout_level_beginner') return const Color(0xFF66BB6A);
    if (levelKey == 'workout_level_intermediate') return const Color(0xFFFFCA28);
    return const Color(0xFFFF7043);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.locale.languageCode;
    final q = _search.text.trim().toLowerCase();
    final filtered = _workouts.where((w) {
      final matchType = _filter == 'all' || w.type == _filter;
      final localizedName = w.displayName(lang).toLowerCase();
      final matchSearch =
          q.isEmpty || localizedName.contains(q) || w.name.toLowerCase().contains(q);
      return matchType && matchSearch;
    }).toList(growable: false);

    return RoyalTabScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'workout_library_title'.tr(),
                  style: const TextStyle(
                    color: AppColors.textCream,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                StreamBuilder<DailyStat>(
                  stream: _workoutRepository.watchTodayStats(),
                  builder: (context, snapshot) {
                    final stat = snapshot.data;
                    final text =
                        '${'workout_library_subtitle'.tr()} · ${stat?.sessionCount ?? 0} sessions today · ${stat?.completedExercises ?? 0} exercises · $_dataMode';
                    return Text(
                      text,
                      style: const TextStyle(
                        color: AppColors.creamDim,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RoyalGlassPanel(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: AppColors.creamDim),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(
                          color: AppColors.textCream,
                          fontSize: 14,
                        ),
                        cursorColor: AppColors.accentGold,
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: 'workout_search_hint'.tr(),
                          hintStyle: const TextStyle(
                            color: AppColors.creamDim,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.goldDim,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, size: 15, color: AppColors.accentGold),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _filterChip(key: 'all', labelKey: 'workout_filter_all', icon: null),
                const SizedBox(width: 10),
                _filterChip(
                  key: 'home',
                  labelKey: 'workout_filter_home',
                  icon: Icons.home_outlined,
                ),
                const SizedBox(width: 10),
                _filterChip(
                  key: 'gym',
                  labelKey: 'workout_filter_gym',
                  icon: Icons.fitness_center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBody(filtered),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(List<LocalExerciseItem> filtered) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          _error!,
          style: const TextStyle(color: Color(0xFFFF6B6B), fontSize: 12),
        ),
      );
    }
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Text(
          'No workouts found',
          style: const TextStyle(color: AppColors.creamDim),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final w = filtered[i];
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              final selectedIndex =
                  _workouts.indexWhere((item) => item.id == w.id);
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => ActiveExercisePage(
                    exercises: _workouts,
                    startIndex: selectedIndex < 0 ? 0 : selectedIndex,
                  ),
                ),
              );
            },
            child: RoyalGlassPanel(
              variant: RoyalGlassVariant.gold,
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: _exerciseImage(w.imageAssetPath, w.mediaType),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                w.displayName(context.locale.languageCode),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textCream,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Icon(Icons.star, size: 14, color: AppColors.accentGold),
                            Text(
                              '${w.rating}',
                              style: const TextStyle(
                                color: AppColors.accentGold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.timer_outlined, size: 12, color: AppColors.creamDim),
                            Text(
                              ' ${w.minutes} min',
                              style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.local_fire_department,
                              size: 12,
                              color: AppColors.creamDim,
                            ),
                            Text(
                              ' ${w.cal} kcal',
                              style: const TextStyle(color: AppColors.creamDim, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _levelColor(w.level).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                w.level.tr(),
                                style: TextStyle(
                                  color: _levelColor(w.level),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${w.exerciseSteps} ${'workout_exercises_suffix'.tr()}',
                              style: const TextStyle(color: AppColors.creamDim, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.goldBorder),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _filterChip({
    required String key,
    required String labelKey,
    IconData? icon,
  }) {
    final selected = _filter == key;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => setState(() => _filter = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(colors: [AppColors.accentGold, AppColors.goldLight])
                  : null,
              color: selected ? null : Colors.transparent,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? Colors.transparent : AppColors.glassBorder,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(212, 175, 55, 0.3),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (selected)
                  const Positioned.fill(
                    child: RoyalGoldShimmer(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: 14,
                        color: selected ? AppColors.emeraldDark : AppColors.textCream,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        labelKey.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: selected ? AppColors.emeraldDark : AppColors.textCream,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseImage(String path, String mediaType) {
    if (mediaType == 'video') {
      return Container(
        color: AppColors.obsidian,
        alignment: Alignment.center,
        child: const Icon(
          Icons.play_circle_fill,
          color: AppColors.accentGold,
          size: 30,
        ),
      );
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _imageFallback(),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.obsidian,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.creamDim,
        size: 18,
      ),
    );
  }
}
