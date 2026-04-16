import { useState, useEffect, useCallback } from "react";
import { motion, AnimatePresence } from "motion/react";
import { Play, Pause, SkipForward, SkipBack, Volume2, VolumeX, X, ChevronLeft } from "lucide-react";
import { useNavigate } from "react-router";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard } from "./royal-theme";
import { ImageWithFallback } from "./figma/ImageWithFallback";

const exercises = [
  { en: "Jumping Jacks", ar: "قفز النجوم", duration: 30, reps: "30 reps", repsAr: "30 تكرار", img: "https://images.unsplash.com/photo-1760876320777-636b607c5261?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwY2FyZGlvJTIwZml0bmVzcyUyMGRhcmt8ZW58MXx8fHwxNzc1OTg4MTczfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" },
  { en: "Push-Ups", ar: "تمارين الضغط", duration: 30, reps: "15 reps", repsAr: "15 تكرار", img: "https://images.unsplash.com/photo-1764426445448-95103b0024a6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNjdWxhciUyMG1hbiUyMHB1c2h1cCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc3NTk4ODE3MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" },
  { en: "Plank Hold", ar: "تمرين البلانك", duration: 45, reps: "45 sec", repsAr: "45 ثانية", img: "https://images.unsplash.com/photo-1660745752547-bb72b8694171?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhYnMlMjB3b3Jrb3V0JTIwcGxhbmslMjBkYXJrJTIwZ3ltfGVufDF8fHx8MTc3NTk4OTAwNHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" },
  { en: "Squats", ar: "تمرين القرفصاء", duration: 30, reps: "20 reps", repsAr: "20 تكرار", img: "https://images.unsplash.com/photo-1758875568800-29fb434c7b17?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzcXVhdCUyMGJhcmJlbGwlMjBmaXRuZXNzJTIwd29tYW58ZW58MXx8fHwxNzc1OTg5MDA0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" },
  { en: "Mountain Climbers", ar: "متسلق الجبال", duration: 30, reps: "20 reps", repsAr: "20 تكرار", img: "https://images.unsplash.com/photo-1758274525981-05497b2c5b97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHlvZ2ElMjBzdHJldGNoaW5nJTIwZml0bmVzc3xlbnwxfHx8fDE3NzU5ODgxNzN8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral" },
];

export function ActiveExercise() {
  const { t } = useRoyal();
  const nav = useNavigate();
  const [current, setCurrent] = useState(0);
  const [playing, setPlaying] = useState(false);
  const [timer, setTimer] = useState(exercises[0].duration);
  const [voiceCoach, setVoiceCoach] = useState(true);

  const ex = exercises[current];
  const progressPct = ((ex.duration - timer) / ex.duration) * 100;

  // Circular timer
  const timerRadius = 90;
  const timerCirc = 2 * Math.PI * timerRadius;
  const timerOffset = timerCirc * (timer / ex.duration);

  useEffect(() => {
    setTimer(exercises[current].duration);
  }, [current]);

  useEffect(() => {
    if (!playing || timer <= 0) return;
    const id = setInterval(() => setTimer((t) => Math.max(0, t - 1)), 1000);
    return () => clearInterval(id);
  }, [playing, timer]);

  const next = useCallback(() => {
    if (current < exercises.length - 1) {
      setCurrent((c) => c + 1);
      setPlaying(false);
    }
  }, [current]);

  const prev = useCallback(() => {
    if (current > 0) {
      setCurrent((c) => c - 1);
      setPlaying(false);
    }
  }, [current]);

  useEffect(() => {
    if (timer === 0 && playing) next();
  }, [timer, playing, next]);

  const formatTime = (s: number) => `${Math.floor(s / 60)}:${(s % 60).toString().padStart(2, "0")}`;

  return (
    <div className="min-h-screen flex flex-col relative" style={{ background: C.emeraldDark }}>
      <GeometricBg />

      <div className="relative z-10 flex flex-col flex-1">
        <StatusBar />

        {/* Top bar */}
        <div className="flex items-center justify-between px-5 mb-2">
          <motion.button whileTap={{ scale: 0.9 }} onClick={() => nav(-1)} className="flex items-center justify-center" style={{ width: 40, height: 40, borderRadius: 12, ...glassCard }}>
            <ChevronLeft size={20} color={C.cream} />
          </motion.button>
          <div className="flex flex-col items-center">
            <span style={{ color: C.gold, fontSize: 12, letterSpacing: 1 }}>
              {t("EXERCISE", "التمرين")}
            </span>
            <span style={{ color: C.creamDim, fontSize: 11 }}>
              {current + 1} / {exercises.length}
            </span>
          </div>
          <motion.button whileTap={{ scale: 0.9 }} onClick={() => nav("/")} className="flex items-center justify-center" style={{ width: 40, height: 40, borderRadius: 12, ...glassCard }}>
            <X size={18} color={C.creamDim} />
          </motion.button>
        </div>

        {/* Segmented progress */}
        <div className="flex gap-1.5 px-5 mb-4">
          {exercises.map((_, i) => (
            <div key={i} className="flex-1 rounded-full overflow-hidden" style={{ height: 4, background: "rgba(212,175,55,0.1)" }}>
              <motion.div
                className="h-full rounded-full"
                style={{
                  background: i < current ? C.gold : i === current ? `linear-gradient(90deg, ${C.gold}, ${C.goldLight})` : "transparent",
                  boxShadow: i === current ? `0 0 8px rgba(212,175,55,0.5)` : "none",
                }}
                initial={false}
                animate={{ width: i < current ? "100%" : i === current ? `${progressPct}%` : "0%" }}
                transition={{ duration: 0.3 }}
              />
            </div>
          ))}
        </div>

        {/* Exercise Image — full-screen area */}
        <AnimatePresence mode="wait">
          <motion.div
            key={current}
            initial={{ opacity: 0, scale: 0.95 }}
            animate={{ opacity: 1, scale: 1 }}
            exit={{ opacity: 0, scale: 0.95 }}
            transition={{ duration: 0.3 }}
            className="mx-5 rounded-3xl overflow-hidden relative"
            style={{
              aspectRatio: "4/3",
              border: `1px solid ${C.goldBorder}`,
              boxShadow: `0 0 40px rgba(212,175,55,0.08)`,
            }}
          >
            <ImageWithFallback src={ex.img} alt={ex.en} className="w-full h-full object-cover" />
            <div className="absolute inset-0" style={{ background: "linear-gradient(180deg, transparent 40%, rgba(0,0,0,0.7))" }} />

            {/* Overlay info */}
            <div className="absolute bottom-0 left-0 right-0 p-5">
              <h2 style={{ color: C.cream, fontSize: 22 }}>{t(ex.en, ex.ar)}</h2>
              <p className="mt-0.5" style={{ color: C.gold, fontSize: 13 }}>{t(ex.reps, ex.repsAr)}</p>
            </div>

            {/* Play overlay when paused */}
            {!playing && (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                className="absolute inset-0 flex items-center justify-center"
                style={{ background: "rgba(0,0,0,0.25)" }}
              >
                <motion.button
                  whileTap={{ scale: 0.9 }}
                  onClick={() => setPlaying(true)}
                  className="flex items-center justify-center rounded-full"
                  style={{
                    width: 70,
                    height: 70,
                    background: `linear-gradient(135deg, rgba(212,175,55,0.85), rgba(230,198,92,0.85))`,
                    backdropFilter: "blur(10px)",
                    boxShadow: `0 0 30px rgba(212,175,55,0.4)`,
                  }}
                >
                  <Play size={30} color={C.emeraldDark} fill={C.emeraldDark} style={{ marginLeft: 3 }} />
                </motion.button>
              </motion.div>
            )}
          </motion.div>
        </AnimatePresence>

        {/* Timer Section */}
        <div className="flex-1 flex flex-col items-center justify-center py-4">
          {/* Circular Timer */}
          <div className="relative" style={{ width: 180, height: 180 }}>
            <svg viewBox="0 0 200 200" className="w-full h-full" style={{ transform: "rotate(-90deg)" }}>
              <circle cx="100" cy="100" r={timerRadius} fill="none" stroke="rgba(212,175,55,0.1)" strokeWidth="6" />
              <circle
                cx="100" cy="100" r={timerRadius} fill="none"
                stroke={C.gold} strokeWidth="6" strokeLinecap="round"
                strokeDasharray={timerCirc}
                strokeDashoffset={timerCirc - timerOffset}
                style={{ filter: `drop-shadow(0 0 8px rgba(212,175,55,0.5))`, transition: "stroke-dashoffset 0.3s ease" }}
              />
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
              <span style={{ color: C.gold, fontSize: 44, fontVariantNumeric: "tabular-nums" }}>
                {formatTime(timer)}
              </span>
              <span style={{ color: C.creamDim, fontSize: 12 }}>
                {t("remaining", "متبقي")}
              </span>
            </div>
          </div>
        </div>

        {/* Bottom Controls — thumb zone */}
        <div className="px-5 pb-4" style={{ paddingBottom: "max(env(safe-area-inset-bottom, 20px), 20px)" }}>
          {/* Voice Coach Toggle */}
          <div className="flex justify-center mb-5">
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => setVoiceCoach(!voiceCoach)}
              className="flex items-center gap-2 px-5 py-2.5 rounded-full relative overflow-hidden"
              style={{
                background: voiceCoach ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "transparent",
                color: voiceCoach ? C.emeraldDark : C.gold,
                border: `1px solid ${voiceCoach ? "transparent" : C.goldBorder}`,
                fontSize: 13,
                boxShadow: voiceCoach ? `0 4px 16px rgba(212,175,55,0.3)` : "none",
              }}
            >
              {voiceCoach && <GoldShimmer />}
              {voiceCoach ? <Volume2 size={16} className="relative z-10" /> : <VolumeX size={16} />}
              <span className="relative z-10">{t("Voice Coach", "المدرب الصوتي")}</span>
            </motion.button>
          </div>

          {/* Playback Controls */}
          <div className="flex items-center justify-center gap-6">
            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={prev}
              className="flex items-center justify-center rounded-2xl"
              style={{
                width: 56,
                height: 56,
                ...glassCard,
                opacity: current > 0 ? 1 : 0.35,
              }}
            >
              <SkipBack size={22} color={C.cream} />
            </motion.button>

            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={() => setPlaying(!playing)}
              className="flex items-center justify-center rounded-full relative overflow-hidden"
              style={{
                width: 80,
                height: 80,
                background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
                boxShadow: `0 0 40px rgba(212,175,55,0.4)`,
              }}
            >
              <GoldShimmer />
              {playing ? (
                <Pause size={34} color={C.emeraldDark} fill={C.emeraldDark} className="relative z-10" />
              ) : (
                <Play size={34} color={C.emeraldDark} fill={C.emeraldDark} className="relative z-10" style={{ marginLeft: 4 }} />
              )}
            </motion.button>

            <motion.button
              whileTap={{ scale: 0.9 }}
              onClick={next}
              className="flex items-center justify-center rounded-2xl"
              style={{
                width: 56,
                height: 56,
                ...glassCard,
                opacity: current < exercises.length - 1 ? 1 : 0.35,
              }}
            >
              <SkipForward size={22} color={C.cream} />
            </motion.button>
          </div>
        </div>
      </div>
    </div>
  );
}
