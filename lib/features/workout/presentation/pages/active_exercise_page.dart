import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/common_widgets/royal_geometric_background.dart';
import '../../../../core/common_widgets/royal_glass_panel.dart';
import '../../../../core/common_widgets/video_webview_page.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/workout_repository.dart';
import '../../../auth/presentation/widgets/royal_gold_shimmer.dart';
import '../models/local_exercise_item.dart';

/// Full-screen active workout (Figma `ActiveExercise`) — outside tab shell.
class ActiveExercisePage extends StatefulWidget {
  const ActiveExercisePage({
    super.key,
    this.exercises = const <LocalExerciseItem>[],
    this.startIndex = 0,
  });

  final List<LocalExerciseItem> exercises;
  final int startIndex;

  @override
  State<ActiveExercisePage> createState() => _ActiveExercisePageState();
}

class _ActiveExercisePageState extends State<ActiveExercisePage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  int _current = 0;
  bool _playing = false;
  int _timer = 30;
  bool _voiceCoach = true;
  Timer? _tick;
  late final List<LocalExerciseItem> _items;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioGuidePlayer = AudioPlayer();
  final List<String> _speechQueue = <String>[];
  bool _isSpeaking = false;
  int _lastCountSpoken = -1;
  final Random _rand = Random();
  int _lastEncouragementSecond = -1;
  final Set<int> _completedIndices = <int>{};
  String? _sessionId;
  DateTime? _sessionStartedAt;
  bool _sessionClosed = false;

  static const List<String> _encouragementAr = <String>[
    'ممتاز! كمّل بنفس القوة.',
    'أداء رائع، ركّز على النفس والحركة.',
    'أنت بطل، باقي قليل.',
    'ثبات ممتاز، استمر.',
    'يا سلام عليك، كمل للنهاية.',
  ];

  static const List<String> _encouragementEn = <String>[
    'Great work. Keep that pace.',
    'Excellent form. Stay focused.',
    'You are doing amazing. Keep going.',
    'Strong effort. Keep pushing.',
    'Almost there. Finish strong.',
  ];

  LocalExerciseItem get _ex => _items[_current];
  int get _duration => _ex.durationSec;
  bool get _isArabic => context.locale.languageCode == 'ar';
  double get _progressPct =>
      _duration == 0 ? 0 : ((_duration - _timer) / _duration) * 100;

  @override
  void initState() {
    super.initState();
    _items = widget.exercises.isNotEmpty
        ? widget.exercises
        : const <LocalExerciseItem>[
            LocalExerciseItem(
              id: 'fallback-1',
              name: 'Jumping Jacks',
              nameAr: 'قفز النجوم',
              type: 'home',
              minutes: 1,
              cal: 120,
              level: 'workout_level_beginner',
              imageAssetPath:
                  'assets/exercisedb_v1_sample/gifs_360x360/05Cf2v8.gif',
              exerciseSteps: 6,
              rating: 4.7,
            ),
          ];
    _current = widget.startIndex.clamp(0, _items.length - 1);
    _timer = _ex.durationSec;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initTts();
      _speakExerciseIntro();
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _tts.stop();
    unawaited(_audioGuidePlayer.dispose());
    unawaited(_closeSessionIfNeeded());
    super.dispose();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage(_isArabic ? 'ar-SA' : 'en-US');
    await _tts.setSpeechRate(_isArabic ? 0.42 : 0.46);
    await _tts.setPitch(_isArabic ? 0.98 : 1.02);
    await _tts.awaitSpeakCompletion(true);
    await _selectBestAvailableVoice();
    _tts.setStartHandler(() {
      _isSpeaking = true;
    });
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      _drainSpeechQueue();
    });
    _tts.setCancelHandler(() {
      _isSpeaking = false;
      _drainSpeechQueue();
    });
    _tts.setErrorHandler((_) {
      _isSpeaking = false;
      _drainSpeechQueue();
    });
  }

  Future<void> _selectBestAvailableVoice() async {
    try {
      final dynamic voices = await _tts.getVoices;
      if (voices is! List) return;
      final langNeedle = _isArabic ? 'ar' : 'en';
      Map<String, dynamic>? preferred;
      for (final v in voices) {
        if (v is! Map) continue;
        final voice = Map<String, dynamic>.from(v);
        final locale = (voice['locale'] ?? '').toString().toLowerCase();
        final name = (voice['name'] ?? '').toString().toLowerCase();
        if (!locale.contains(langNeedle)) continue;
        if (_isArabic) {
          if (name.contains('female') || name.contains('hoda') || name.contains('laila')) {
            preferred = voice;
            break;
          }
        } else {
          if (name.contains('natural') || name.contains('female') || name.contains('aria')) {
            preferred = voice;
            break;
          }
        }
        preferred ??= voice;
      }
      if (preferred != null) {
        await _tts.setVoice(preferred.map(
          (key, value) => MapEntry(key, value.toString()),
        ));
      }
    } catch (_) {
      // Fallback to default system voice when voice listing is unavailable.
    }
  }

  void _enqueueSpeech(String text) {
    if (!_voiceCoach || text.trim().isEmpty) return;
    _speechQueue.add(text);
    _drainSpeechQueue();
  }

  Future<void> _drainSpeechQueue() async {
    if (_isSpeaking || _speechQueue.isEmpty || !_voiceCoach) return;
    final next = _speechQueue.removeAt(0);
    await _tts.speak(next);
  }

  Future<void> _stopSpeech() async {
    _speechQueue.clear();
    _isSpeaking = false;
    await _tts.stop();
  }

  Future<void> _playAudioGuide() async {
    final audioUrl = _ex.audioUrl;
    if (audioUrl == null || audioUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No audio guide for this exercise yet.')),
      );
      return;
    }
    try {
      await _audioGuidePlayer.setUrl(audioUrl);
      await _audioGuidePlayer.play();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to play audio guide.')),
      );
    }
  }

  String _exerciseNameForSpeech() => _ex.displayName(context.locale.languageCode);

  String? _exerciseTtsScript() {
    if (_isArabic) {
      final ar = _ex.ttsScriptAr?.trim();
      if (ar != null && ar.isNotEmpty) return ar;
    }
    final localized = _ex.ttsScript?.trim();
    if (localized != null && localized.isNotEmpty) return localized;
    final fallbackAr = _ex.ttsScriptAr?.trim();
    if (fallbackAr != null && fallbackAr.isNotEmpty) return fallbackAr;
    return null;
  }

  String _encouragementMessage() {
    final list = _isArabic ? _encouragementAr : _encouragementEn;
    return list[_rand.nextInt(list.length)];
  }

  String _countdownSpeech(int sec) {
    if (!_isArabic) return '$sec';
    const arNums = <int, String>{
      1: 'واحد',
      2: 'اثنين',
      3: 'ثلاثة',
      4: 'أربعة',
      5: 'خمسة',
    };
    return arNums[sec] ?? '$sec';
  }

  void _speakExerciseIntro() {
    final ttsScript = _exerciseTtsScript();
    if (ttsScript != null && ttsScript.isNotEmpty) {
      _enqueueSpeech(ttsScript);
      return;
    }

    _enqueueSpeech(
      _isArabic
          ? 'جاهز؟ ابدأ تمرين ${_exerciseNameForSpeech()}. لديك ${_ex.exerciseSteps} خطوات.'
          : 'Ready? Start ${_exerciseNameForSpeech()}. You have ${_ex.exerciseSteps} steps.',
    );

    if (_ex.instructions.isNotEmpty) {
      _enqueueSpeech(_ex.instructions.first);
    }
  }

  void _syncTimerToExercise() {
    _timer = _items[_current].durationSec;
    _lastCountSpoken = -1;
    _lastEncouragementSecond = -1;
  }

  void _startTicker() {
    _tick?.cancel();
    if (!_playing || _timer <= 0) return;
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      var shouldSpeakNext = false;
      var announceDone = false;
      var announceTen = false;
      var announceEncouragement = false;
      int? announceCount;
      setState(() {
        if (_timer <= 0) {
          _tick?.cancel();
          return;
        }
        _timer--;
        if (_timer == 10) {
          announceTen = true;
        } else if (_timer <= 5 && _timer > 0 && _lastCountSpoken != _timer) {
          announceCount = _timer;
          _lastCountSpoken = _timer;
        } else if (
            _timer > 10 &&
            (_timer == (_duration ~/ 2) || _timer == (_duration ~/ 3)) &&
            _lastEncouragementSecond != _timer) {
          announceEncouragement = true;
          _lastEncouragementSecond = _timer;
        }
        if (_timer == 0 && _playing) {
          _markCurrentExerciseDone();
          if (_current < _items.length - 1) {
            _current++;
            _timer = _items[_current].durationSec;
            shouldSpeakNext = true;
          } else {
            _playing = false;
            _tick?.cancel();
            announceDone = true;
            _closeSessionIfNeeded();
          }
        }
      });
      if (_voiceCoach) {
        // If admin provided a custom coach script for this exercise,
        // suppress the app's default countdown/encouragement phrases.
        final hasCustomCoachScript =
            (_exerciseTtsScript()?.trim().isNotEmpty ?? false);

        if (hasCustomCoachScript) {
          if (shouldSpeakNext) {
            _speakExerciseIntro();
          }
          if (announceDone) {
            // Keep completion silent when custom script is present.
          }
          return;
        }

        if (announceTen) {
          _enqueueSpeech(_isArabic ? 'تبقّى عشر ثوانٍ. ركّز.' : 'Ten seconds left. Stay focused.');
        }
        if (announceCount != null) {
          _enqueueSpeech(_countdownSpeech(announceCount!));
        }
        if (announceEncouragement) {
          _enqueueSpeech(_encouragementMessage());
        }
        if (shouldSpeakNext) {
          _enqueueSpeech(
            _isArabic ? 'ممتاز. ننتقل للتمرين التالي.' : 'Great. Moving to the next exercise.',
          );
          _speakExerciseIntro();
        }
        if (announceDone) {
          _enqueueSpeech(
            _isArabic ? 'انتهى التمرين. عمل بطولي.' : 'Workout complete. Outstanding effort.',
          );
        }
      }
    });
  }

  void _setPlaying(bool v) {
    setState(() {
      _playing = v;
    });
    _tick?.cancel();
    if (_playing && _timer > 0) {
      _startSessionIfNeeded();
      _startTicker();
      _speakExerciseIntro();
    } else {
      _stopSpeech();
    }
  }

  void _next() {
    _startSessionIfNeeded();
    _markCurrentExerciseDone();
    if (_current < _items.length - 1) {
      setState(() {
        _current++;
        _playing = false;
        _syncTimerToExercise();
      });
      _tick?.cancel();
      _stopSpeech();
      _speakExerciseIntro();
    }
  }

  Future<void> _startSessionIfNeeded() async {
    if (_sessionId != null) return;
    try {
      final id = await _workoutRepository.startSession(
        plannedExerciseCount: _items.length,
      );
      _sessionId = id;
      _sessionStartedAt = DateTime.now();
    } catch (_) {
      // Keep the training flow running even if persistence is temporarily unavailable.
    }
  }

  void _markCurrentExerciseDone() {
    if (_completedIndices.contains(_current)) return;
    _completedIndices.add(_current);
    final sid = _sessionId;
    if (sid == null) return;
    _workoutRepository.saveSessionItem(
      sessionId: sid,
      exercise: _items[_current],
      index: _current,
      done: true,
    );
  }

  Future<void> _closeSessionIfNeeded() async {
    if (_sessionClosed) return;
    if (_completedIndices.isEmpty) return;
    final sid = _sessionId;
    final started = _sessionStartedAt;
    if (sid == null || started == null) return;
    _sessionClosed = true;
    final durationSec = DateTime.now().difference(started).inSeconds;
    final calories = _completedIndices.fold<int>(
      0,
      (sum, idx) => sum + _items[idx].cal,
    );
    try {
      await _workoutRepository.completeSession(
        sessionId: sid,
        durationSec: durationSec,
        calories: calories,
        completedExercises: _completedIndices.length,
      );
    } catch (_) {
      // Ignore backend errors to avoid blocking UI at the end of session.
    }
  }

  void _prev() {
    if (_current > 0) {
      setState(() {
        _current--;
        _playing = false;
        _syncTimerToExercise();
      });
      _tick?.cancel();
      _stopSpeech();
      _speakExerciseIntro();
    }
  }

  String _formatTime(int s) {
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    const timerRadius = 90.0;
    const stroke = 6.0;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryEmerald,
                  AppColors.emeraldDark,
                ],
              ),
            ),
          ),
          const Positioned.fill(child: RoyalGeometricBackground()),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _topIcon(
                        context,
                        Icons.chevron_left,
                        () => Navigator.of(context).pop(),
                      ),
                      Column(
                        children: [
                          Text(
                            'exercise_header'.tr(),
                            style: const TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '${_current + 1} / ${_items.length}',
                            style: const TextStyle(
                              color: AppColors.creamDim,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      _topIcon(
                        context,
                        Icons.close,
                        () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(_items.length, (i) {
                      final widthFrac = i < _current
                          ? 1.0
                          : i == _current
                              ? _progressPct / 100
                              : 0.0;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: SizedBox(
                              height: 4,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  const ColoredBox(
                                    color: Color.fromRGBO(212, 175, 55, 0.1),
                                  ),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: FractionallySizedBox(
                                      widthFactor: widthFrac.clamp(0.0, 1.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              AppColors.accentGold,
                                              AppColors.goldLight,
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          boxShadow: i == _current
                                              ? const [
                                                  BoxShadow(
                                                    color: Color.fromRGBO(
                                                      212,
                                                      175,
                                                      55,
                                                      0.5,
                                                    ),
                                                    blurRadius: 8,
                                                  ),
                                                ]
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Padding(
                          key: ValueKey<int>(_current),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: AspectRatio(
                            aspectRatio: 4 / 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _exerciseImage(_ex.imageAssetPath, _ex.mediaType),
                                  const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Color.fromRGBO(0, 0, 0, 0.7),
                                        ],
                                        stops: [0.4, 1],
                                      ),
                                    ),
                                  ),
                                  if (_ex.mediaType == 'video')
                                    Positioned.fill(
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          onTap: () {
                                            final url = _ex.imageAssetPath.trim();
                                            if (url.isEmpty) return;
                                            Navigator.of(context).push<void>(
                                              MaterialPageRoute<void>(
                                                builder: (_) => VideoWebViewPage(
                                                  url: url,
                                                  title: _ex.displayName(context.locale.languageCode),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            color: const Color.fromRGBO(0, 0, 0, 0.35),
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 72,
                                              height: 72,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color.fromRGBO(212, 175, 55, 0.9),
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow,
                                                size: 44,
                                                color: AppColors.emeraldDark,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    left: 20,
                                    right: 20,
                                    bottom: 20,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _ex.displayName(
                                            context.locale.languageCode,
                                          ),
                                          style: const TextStyle(
                                            color: AppColors.textCream,
                                            fontSize: 22,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${_ex.exerciseSteps} ${'workout_exercises_suffix'.tr()}',
                                          style: const TextStyle(
                                            color: AppColors.accentGold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!_playing)
                                    Positioned.fill(
                                      child: ColoredBox(
                                        color: const Color.fromRGBO(
                                          0,
                                          0,
                                          0,
                                          0.25,
                                        ),
                                        child: Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: _ex.mediaType == 'video'
                                                  ? null
                                                  : () => _setPlaying(true),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              child: Ink(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(
                                                        212,
                                                        175,
                                                        55,
                                                        0.85,
                                                      ),
                                                      Color.fromRGBO(
                                                        230,
                                                        198,
                                                        92,
                                                        0.85,
                                                      ),
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color.fromRGBO(
                                                        212,
                                                        175,
                                                        55,
                                                        0.4,
                                                      ),
                                                      blurRadius: 30,
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.play_arrow,
                                                  size: 40,
                                                  color: AppColors.emeraldDark,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: CustomPaint(
                            painter: _RingTimerPainter(
                              progress: (_duration - _timer) / _duration,
                              radius: timerRadius,
                              strokeWidth: stroke,
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTime(_timer),
                                    style: const TextStyle(
                                      color: AppColors.accentGold,
                                      fontSize: 44,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'exercise_remaining'.tr(),
                                    style: const TextStyle(
                                      color: AppColors.creamDim,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(999),
                              onTap: () {
                                final next = !_voiceCoach;
                                setState(() => _voiceCoach = next);
                                if (!next) {
                                  _stopSpeech();
                                } else {
                                  _speakExerciseIntro();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: _voiceCoach
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.accentGold,
                                            AppColors.goldLight,
                                          ],
                                        )
                                      : null,
                                  color: _voiceCoach
                                      ? null
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: _voiceCoach
                                        ? Colors.transparent
                                        : AppColors.goldBorder,
                                  ),
                                  boxShadow: _voiceCoach
                                      ? const [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                              212,
                                              175,
                                              55,
                                              0.3,
                                            ),
                                            blurRadius: 16,
                                            offset: Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if (_voiceCoach)
                                      const Positioned.fill(
                                        child: RoyalGoldShimmer(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(999),
                                          ),
                                        ),
                                      ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _voiceCoach
                                              ? Icons.volume_up
                                              : Icons.volume_off,
                                          size: 16,
                                          color: _voiceCoach
                                              ? AppColors.emeraldDark
                                              : AppColors.accentGold,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'exercise_voice_coach'.tr(),
                                          style: TextStyle(
                                            color: _voiceCoach
                                                ? AppColors.emeraldDark
                                                : AppColors.accentGold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if ((_ex.audioUrl ?? '').isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Center(
                              child: OutlinedButton.icon(
                                onPressed: _playAudioGuide,
                                icon: const Icon(Icons.headphones, size: 16),
                                label: const Text('Play exercise audio'),
                              ),
                            ),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _sideControl(
                              icon: Icons.skip_previous,
                              enabled: _current > 0,
                              onTap: _prev,
                            ),
                            const SizedBox(width: 24),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () => _setPlaying(!_playing),
                                child: Ink(
                                  width: 80,
                                  height: 80,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.accentGold,
                                        AppColors.goldLight,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color.fromRGBO(
                                          212,
                                          175,
                                          55,
                                          0.4,
                                        ),
                                        blurRadius: 40,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      const RoyalGoldShimmer(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(999),
                                        ),
                                      ),
                                      Icon(
                                        _playing
                                            ? Icons.pause
                                            : Icons.play_arrow,
                                        size: 34,
                                        color: AppColors.emeraldDark,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            _sideControl(
                              icon: Icons.skip_next,
                              enabled:
                                  _current < _items.length - 1,
                              onTap: _next,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topIcon(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: RoyalGlassPanel(
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              icon,
              size: 20,
              color: icon == Icons.close
                  ? AppColors.creamDim
                  : AppColors.textCream,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sideControl({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: RoyalGlassPanel(
            borderRadius: 16,
            padding: EdgeInsets.zero,
            child: SizedBox(
              width: 56,
              height: 56,
              child: Icon(icon, size: 22, color: AppColors.textCream),
            ),
          ),
        ),
      ),
    );
  }

  Widget _exerciseImage(String path, String mediaType) {
    if (mediaType == 'video') {
      final thumb = _ex.thumbnailUrl ?? _videoThumbUrl(path);
      if (thumb != null && thumb.trim().isNotEmpty) {
        return Image.network(
          thumb.trim(),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _videoFallback(),
        );
      }
      // If admin provided a direct video file URL, show a lightweight preview.
      if (path.startsWith('http://') || path.startsWith('https://')) {
        final lower = path.toLowerCase();
        final isDirect = lower.endsWith('.mp4') ||
            lower.endsWith('.webm') ||
            lower.endsWith('.mov') ||
            lower.endsWith('.m3u8') ||
            lower.contains('.mp4?') ||
            lower.contains('.webm?') ||
            lower.contains('.mov?') ||
            lower.contains('.m3u8?');
        if (isDirect) {
          return Container(
            color: AppColors.obsidian,
            alignment: Alignment.center,
            child: const Icon(
              Icons.play_circle_fill,
              color: AppColors.accentGold,
              size: 40,
            ),
          );
        }
      }
      return Container(
        color: AppColors.obsidian,
        alignment: Alignment.center,
        child: _videoFallback(),
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

  String? _videoThumbUrl(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final uri = Uri.tryParse(s);
    final host = (uri?.host ?? '').toLowerCase().replaceFirst('www.', '');
    if (host.contains('youtu.be') || host.contains('youtube.com')) {
      final id = _parseYouTubeId(s);
      if (id != null) return 'https://img.youtube.com/vi/$id/hqdefault.jpg';
    }
    if (host.contains('vimeo.com')) {
      final id = _parseVimeoId(s);
      if (id != null) return 'https://vumbnail.com/$id.jpg';
    }
    return null;
  }

  String? _parseYouTubeId(String raw) {
    try {
      final u = Uri.parse(raw);
      final host = u.host.toLowerCase().replaceFirst('www.', '');
      if (host == 'youtu.be') {
        final seg = u.pathSegments.isNotEmpty ? u.pathSegments.first : null;
        return seg?.trim().isEmpty ?? true ? null : seg!.trim();
      }
      if (host.endsWith('youtube.com')) {
        final v = u.queryParameters['v'];
        if (v != null && v.trim().isNotEmpty) return v.trim();
        final parts = u.pathSegments;
        final idx = parts.indexWhere((p) => p == 'shorts' || p == 'embed' || p == 'v');
        if (idx >= 0 && idx + 1 < parts.length) {
          final id = parts[idx + 1].trim();
          return id.isEmpty ? null : id;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _parseVimeoId(String raw) {
    try {
      final u = Uri.parse(raw);
      final host = u.host.toLowerCase().replaceFirst('www.', '');
      if (!host.endsWith('vimeo.com')) return null;
      final parts = u.pathSegments.where((e) => e.trim().isNotEmpty).toList();
      if (parts.isEmpty) return null;
      final id = (parts.first == 'video' && parts.length > 1) ? parts[1] : parts.first;
      return RegExp(r'^\d+$').hasMatch(id) ? id : null;
    } catch (_) {
      return null;
    }
  }

  Widget _videoFallback() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.play_circle_fill, color: AppColors.accentGold, size: 40),
        SizedBox(height: 8),
        Text('Tap to play', style: TextStyle(color: AppColors.creamDim)),
      ],
    );
  }

  Widget _imageFallback() {
    return Container(
      color: AppColors.obsidian,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.creamDim,
      ),
    );
  }
}

class _RingTimerPainter extends CustomPainter {
  _RingTimerPainter({
    required this.progress,
    required this.radius,
    required this.strokeWidth,
  });

  final double progress;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final track = Paint()
      ..color = const Color.fromRGBO(212, 175, 55, 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final arc = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, radius, track);
    final rect = Rect.fromCircle(center: c, radius: radius);
    final sweep = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);
    canvas.drawArc(rect, -3.141592653589793 / 2, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingTimerPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
