import { motion } from "motion/react";
import { Crown, Flame, Droplets, Footprints, ChevronRight, Trophy, Zap, Timer } from "lucide-react";
import { useNavigate } from "react-router";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard, glassCardGold } from "./royal-theme";
import { ImageWithFallback } from "./figma/ImageWithFallback";

const IMG_CHALLENGE = "https://images.unsplash.com/photo-1561532325-7d5231a2dede?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dCUyMGRhcmt8ZW58MXx8fHwxNzc1OTg4MTcxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral";

export function HomeScreen() {
  const { t } = useRoyal();
  const nav = useNavigate();
  const progress = 0.68;

  // Circular progress ring calculations
  const radius = 72;
  const circumference = 2 * Math.PI * radius;
  const strokeDashoffset = circumference * (1 - progress);

  return (
    <div className="min-h-screen pb-24" style={{ background: `linear-gradient(180deg, ${C.emerald}, ${C.emeraldDark})` }}>
      <GeometricBg />

      <div className="relative z-10">
        <StatusBar />

        {/* Header */}
        <div className="flex items-center justify-between px-5 mb-5 mt-1">
          <div>
            <p style={{ color: C.creamDim, fontSize: 12, letterSpacing: 1 }}>
              {t("GOOD MORNING", "صباح الخير")} 👑
            </p>
            <h1 className="mt-0.5" style={{ color: C.cream, fontSize: 22 }}>
              {t("Welcome, Champion", "مرحباً، بطل")}
            </h1>
          </div>
          <motion.div
            whileTap={{ scale: 0.9 }}
            className="flex items-center justify-center relative"
            style={{
              width: 46,
              height: 46,
              borderRadius: 16,
              ...glassCard,
            }}
          >
            <Crown size={20} color={C.gold} />
            <div
              className="absolute -top-0.5 -right-0.5 rounded-full"
              style={{ width: 10, height: 10, background: "#ff6b6b", border: `2px solid ${C.emerald}` }}
            />
          </motion.div>
        </div>

        {/* Activity Rings Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-5 p-5 relative overflow-hidden"
          style={glassCardGold}
        >
          <GoldShimmer />
          <div className="flex items-center gap-5 relative z-10">
            {/* Triple Rings */}
            <div className="relative flex-shrink-0" style={{ width: 155, height: 155 }}>
              <svg viewBox="0 0 160 160" className="w-full h-full" style={{ transform: "rotate(-90deg)" }}>
                {/* Outer ring - Calories */}
                <circle cx="80" cy="80" r={radius} fill="none" stroke="rgba(255,107,107,0.15)" strokeWidth="9" />
                <circle
                  cx="80" cy="80" r={radius} fill="none"
                  stroke="#ff6b6b" strokeWidth="9" strokeLinecap="round"
                  strokeDasharray={circumference}
                  strokeDashoffset={circumference * 0.32}
                  style={{ filter: "drop-shadow(0 0 4px rgba(255,107,107,0.5))" }}
                />
                {/* Middle ring - Exercise */}
                <circle cx="80" cy="80" r={58} fill="none" stroke="rgba(212,175,55,0.15)" strokeWidth="9" />
                <circle
                  cx="80" cy="80" r={58} fill="none"
                  stroke={C.gold} strokeWidth="9" strokeLinecap="round"
                  strokeDasharray={2 * Math.PI * 58}
                  strokeDashoffset={2 * Math.PI * 58 * 0.25}
                  style={{ filter: `drop-shadow(0 0 4px rgba(212,175,55,0.5))` }}
                />
                {/* Inner ring - Stand */}
                <circle cx="80" cy="80" r={44} fill="none" stroke="rgba(102,187,106,0.15)" strokeWidth="9" />
                <circle
                  cx="80" cy="80" r={44} fill="none"
                  stroke="#66bb6a" strokeWidth="9" strokeLinecap="round"
                  strokeDasharray={2 * Math.PI * 44}
                  strokeDashoffset={2 * Math.PI * 44 * 0.42}
                  style={{ filter: "drop-shadow(0 0 4px rgba(102,187,106,0.5))" }}
                />
              </svg>
              {/* Center text */}
              <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span style={{ color: C.gold, fontSize: 28 }}>{Math.round(progress * 100)}%</span>
                <span style={{ color: C.creamDim, fontSize: 10 }}>{t("Daily Goal", "هدف اليوم")}</span>
              </div>
            </div>

            {/* Stats */}
            <div className="flex flex-col gap-4 flex-1">
              {[
                { icon: Flame, label: t("Calories", "السعرات"), val: "420", unit: "kcal", color: "#ff6b6b" },
                { icon: Timer, label: t("Exercise", "التمارين"), val: "45", unit: "min", color: C.gold },
                { icon: Zap, label: t("Steps", "الخطوات"), val: "7,842", unit: "", color: "#66bb6a" },
              ].map((s, i) => (
                <div key={i} className="flex items-center gap-2.5">
                  <div
                    className="flex items-center justify-center rounded-lg"
                    style={{ width: 30, height: 30, background: `${s.color}15` }}
                  >
                    <s.icon size={14} color={s.color} />
                  </div>
                  <div>
                    <div className="flex items-baseline gap-1">
                      <span style={{ color: C.cream, fontSize: 17 }}>{s.val}</span>
                      <span style={{ color: C.creamDim, fontSize: 10 }}>{s.unit}</span>
                    </div>
                    <span style={{ color: C.creamDim, fontSize: 10 }}>{s.label}</span>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </motion.div>

        {/* BMI Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mx-5 mt-4 p-4 relative overflow-hidden"
          style={glassCard}
        >
          <div className="flex items-center justify-between relative z-10">
            <div>
              <p style={{ color: C.creamDim, fontSize: 11, letterSpacing: 1 }}>
                {t("YOUR BMI", "مؤشر كتلة الجسم")}
              </p>
              <div className="flex items-end gap-2 mt-1">
                <span style={{ color: C.cream, fontSize: 30 }}>22.5</span>
                <span
                  className="px-2.5 py-1 rounded-full mb-1"
                  style={{ background: "rgba(102,187,106,0.15)", color: "#66bb6a", fontSize: 11 }}
                >
                  {t("Normal", "طبيعي")}
                </span>
              </div>
            </div>
            <div className="flex flex-col items-end gap-1.5">
              {/* BMI Gauge */}
              <div className="relative" style={{ width: 100, height: 12 }}>
                <div className="flex rounded-full overflow-hidden" style={{ height: 6, marginTop: 3 }}>
                  {[
                    { color: "#4fc3f7", w: "25%" },
                    { color: "#66bb6a", w: "25%" },
                    { color: "#ffca28", w: "25%" },
                    { color: "#ff7043", w: "25%" },
                  ].map((b, i) => (
                    <div key={i} style={{ width: b.w, background: b.color, opacity: i === 1 ? 1 : 0.35 }} />
                  ))}
                </div>
                {/* Indicator */}
                <div
                  className="absolute top-0 rounded-full"
                  style={{
                    left: "37%",
                    width: 6,
                    height: 12,
                    background: C.cream,
                    border: `1px solid ${C.emerald}`,
                    boxShadow: "0 0 6px rgba(255,255,255,0.3)",
                  }}
                />
              </div>
              <span style={{ color: C.creamDim, fontSize: 9 }}>
                {t("Healthy: 18.5 - 24.9", "صحي: 18.5 - 24.9")}
              </span>
            </div>
          </div>
        </motion.div>

        {/* Royal Challenge Banner */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="mx-5 mt-4 rounded-3xl overflow-hidden relative"
          style={{ height: 170, border: `1px solid ${C.goldBorder}` }}
        >
          <ImageWithFallback
            src={IMG_CHALLENGE}
            alt="challenge"
            className="absolute inset-0 w-full h-full object-cover"
          />
          <div
            className="absolute inset-0"
            style={{
              background: `linear-gradient(${document?.dir === "rtl" ? "270deg" : "90deg"}, rgba(1,26,16,0.95) 35%, rgba(1,26,16,0.4) 70%, transparent)`,
            }}
          />
          <GoldShimmer />
          <div className="relative z-10 h-full flex flex-col justify-center px-5">
            <div className="flex items-center gap-2 mb-2">
              <Trophy size={14} color={C.gold} />
              <span style={{ color: C.gold, fontSize: 10, letterSpacing: 2 }}>
                {t("ROYAL CHALLENGE", "التحدي الملكي")}
              </span>
            </div>
            <h3 style={{ color: C.cream, fontSize: 20 }}>
              {t("30-Day Transform", "تحوّل 30 يوماً")}
            </h3>
            <p className="mt-1" style={{ color: C.creamDim, fontSize: 12 }}>
              {t("Day 12 of 30", "اليوم 12 من 30")}
            </p>
            <div className="mt-3 flex items-center gap-3">
              <div className="flex-1 rounded-full overflow-hidden" style={{ height: 5, background: "rgba(212,175,55,0.15)" }}>
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: "40%" }}
                  transition={{ delay: 0.5, duration: 1 }}
                  className="h-full rounded-full"
                  style={{ background: `linear-gradient(90deg, ${C.gold}, ${C.goldLight})`, boxShadow: `0 0 8px rgba(212,175,55,0.4)` }}
                />
              </div>
              <span style={{ color: C.gold, fontSize: 12 }}>40%</span>
            </div>
          </div>
        </motion.div>

        {/* Quick Workouts Section */}
        <div className="mt-5 px-5">
          <div className="flex items-center justify-between mb-3">
            <h3 style={{ color: C.cream, fontSize: 16 }}>{t("Quick Start", "بداية سريعة")}</h3>
            <button
              className="flex items-center gap-1"
              style={{ color: C.gold, fontSize: 12 }}
              onClick={() => nav("/workouts")}
            >
              {t("See All", "عرض الكل")}
              <ChevronRight size={14} />
            </button>
          </div>
          <div
            className="flex gap-3 overflow-x-auto pb-3"
            style={{ scrollbarWidth: "none", marginRight: -20, paddingRight: 20 }}
          >
            {[
              { en: "Full Body", ar: "كامل الجسم", time: "20", cal: "150", icon: "💪" },
              { en: "Upper Body", ar: "الجزء العلوي", time: "15", cal: "120", icon: "🏋️" },
              { en: "Core Blast", ar: "تقوية البطن", time: "10", cal: "90", icon: "🔥" },
              { en: "Leg Day", ar: "يوم الأرجل", time: "25", cal: "200", icon: "🦵" },
            ].map((w, i) => (
              <motion.button
                key={i}
                initial={{ opacity: 0, x: 30 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: 0.3 + i * 0.08 }}
                onClick={() => nav("/exercise")}
                className="flex-shrink-0 p-4 relative overflow-hidden text-left"
                style={{ width: 145, ...glassCardGold }}
                whileTap={{ scale: 0.96 }}
              >
                <GoldShimmer />
                <div className="relative z-10">
                  <span style={{ fontSize: 28 }}>{w.icon}</span>
                  <p className="mt-2" style={{ color: C.cream, fontSize: 14 }}>{t(w.en, w.ar)}</p>
                  <div className="flex items-center gap-2 mt-2">
                    <span className="flex items-center gap-0.5" style={{ color: C.creamDim, fontSize: 11 }}>
                      <Timer size={10} /> {w.time}m
                    </span>
                    <span className="flex items-center gap-0.5" style={{ color: C.creamDim, fontSize: 11 }}>
                      <Flame size={10} /> {w.cal}
                    </span>
                  </div>
                </div>
              </motion.button>
            ))}
          </div>
        </div>

        {/* Today's Plan */}
        <div className="mt-2 px-5">
          <h3 className="mb-3" style={{ color: C.cream, fontSize: 16 }}>
            {t("Today's Plan", "خطة اليوم")}
          </h3>
          {[
            { en: "Morning Stretch", ar: "تمدد الصباح", time: "7:00 AM", done: true },
            { en: "HIIT Cardio", ar: "كارديو عالي الشدة", time: "10:00 AM", done: true },
            { en: "Evening Yoga", ar: "يوغا المساء", time: "6:00 PM", done: false },
          ].map((item, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4 + i * 0.06 }}
              className="flex items-center gap-3 p-3.5 mb-2 rounded-2xl"
              style={glassCard}
            >
              <div
                className="flex items-center justify-center rounded-xl flex-shrink-0"
                style={{
                  width: 42,
                  height: 42,
                  background: item.done ? "rgba(102,187,106,0.12)" : C.goldDim,
                  border: `1px solid ${item.done ? "rgba(102,187,106,0.25)" : C.goldBorder}`,
                }}
              >
                {item.done ? (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none">
                    <path d="M5 13l4 4L19 7" stroke="#66bb6a" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                ) : (
                  <Timer size={18} color={C.gold} />
                )}
              </div>
              <div className="flex-1">
                <p style={{ color: item.done ? C.creamDim : C.cream, fontSize: 14, textDecoration: item.done ? "line-through" : "none" }}>
                  {t(item.en, item.ar)}
                </p>
                <p style={{ color: C.creamDim, fontSize: 11 }}>{item.time}</p>
              </div>
              <ChevronRight size={16} color={C.goldBorder} />
            </motion.div>
          ))}
        </div>
      </div>
    </div>
  );
}
