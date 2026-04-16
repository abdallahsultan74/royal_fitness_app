import { useState } from "react";
import { motion } from "motion/react";
import { Clock, Flame, ChevronRight, Search, SlidersHorizontal, Dumbbell, Home as HomeIcon, Star } from "lucide-react";
import { useNavigate } from "react-router";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard, glassCardGold } from "./royal-theme";
import { ImageWithFallback } from "./figma/ImageWithFallback";

const IMAGES = [
  "https://images.unsplash.com/photo-1764426445448-95103b0024a6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtdXNjdWxhciUyMG1hbiUyMHB1c2h1cCUyMGV4ZXJjaXNlfGVufDF8fHx8MTc3NTk4ODE3MXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
  "https://images.unsplash.com/photo-1758274525981-05497b2c5b97?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx3b21hbiUyMHlvZ2ElMjBzdHJldGNoaW5nJTIwZml0bmVzc3xlbnwxfHx8fDE3NzU5ODgxNzN8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
  "https://images.unsplash.com/photo-1770493895453-4f758c40d11d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxkdW1iYmVsbCUyMHdlaWdodCUyMHRyYWluaW5nJTIwZ3ltfGVufDF8fHx8MTc3NTk4ODE3M3ww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
  "https://images.unsplash.com/photo-1660745752547-bb72b8694171?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhYnMlMjB3b3Jrb3V0JTIwcGxhbmslMjBkYXJrJTIwZ3ltfGVufDF8fHx8MTc3NTk4OTAwNHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
  "https://images.unsplash.com/photo-1758875568800-29fb434c7b17?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxzcXVhdCUyMGJhcmJlbGwlMjBmaXRuZXNzJTIwd29tYW58ZW58MXx8fHwxNzc1OTg5MDA0fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
  "https://images.unsplash.com/photo-1760876320777-636b607c5261?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxydW5uaW5nJTIwY2FyZGlvJTIwZml0bmVzcyUyMGRhcmt8ZW58MXx8fHwxNzc1OTg4MTczfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
];

const workouts = [
  { en: "Push-Up Mastery", ar: "إتقان تمرين الضغط", type: "home", time: "12 min", cal: 110, level: "Beginner", img: 0, exercises: 8, rating: 4.8 },
  { en: "Yoga Flow", ar: "تدفق اليوغا", type: "home", time: "25 min", cal: 180, level: "Intermediate", img: 1, exercises: 12, rating: 4.9 },
  { en: "Dumbbell Power", ar: "قوة الدمبل", type: "gym", time: "35 min", cal: 280, level: "Advanced", img: 2, exercises: 15, rating: 4.7 },
  { en: "Core Destroyer", ar: "تدمير عضلات البطن", type: "home", time: "15 min", cal: 160, level: "Intermediate", img: 3, exercises: 10, rating: 4.6 },
  { en: "Squat Challenge", ar: "تحدي القرفصاء", type: "gym", time: "20 min", cal: 220, level: "Advanced", img: 4, exercises: 12, rating: 4.8 },
  { en: "Cardio Burn", ar: "حرق الكارديو", type: "home", time: "20 min", cal: 220, level: "Intermediate", img: 5, exercises: 10, rating: 4.5 },
];

export function WorkoutLibrary() {
  const { t } = useRoyal();
  const nav = useNavigate();
  const [filter, setFilter] = useState<"all" | "home" | "gym">("all");
  const [search, setSearch] = useState("");

  const filtered = workouts.filter(
    (w) => (filter === "all" || w.type === filter) && t(w.en, w.ar).toLowerCase().includes(search.toLowerCase())
  );

  const levelColor = (l: string) => l === "Beginner" ? "#66bb6a" : l === "Intermediate" ? "#ffca28" : "#ff7043";

  return (
    <div className="min-h-screen pb-24" style={{ background: `linear-gradient(180deg, ${C.emerald}, ${C.emeraldDark})` }}>
      <GeometricBg />

      <div className="relative z-10">
        <StatusBar />

        <div className="px-5 mt-1 mb-4">
          <h1 style={{ color: C.cream, fontSize: 22 }}>
            {t("Workout Library", "مكتبة التمارين")}
          </h1>
          <p className="mt-0.5" style={{ color: C.creamDim, fontSize: 12 }}>
            {t("Choose your royal training", "اختر تدريبك الملكي")}
          </p>
        </div>

        {/* Search Bar */}
        <div className="px-5 mb-4">
          <div
            className="flex items-center gap-3 px-4 relative overflow-hidden"
            style={{ height: 50, ...glassCard }}
          >
            <Search size={18} color={C.creamDim} />
            <input
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              placeholder={t("Search workouts...", "ابحث عن التمارين...")}
              className="flex-1 bg-transparent outline-none"
              style={{ color: C.cream, fontSize: 14 }}
            />
            <div className="flex items-center justify-center rounded-xl" style={{ width: 34, height: 34, background: C.goldDim }}>
              <SlidersHorizontal size={15} color={C.gold} />
            </div>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="px-5 flex gap-2.5 mb-5">
          {([
            { key: "all", en: "All", ar: "الكل", icon: null },
            { key: "home", en: "Home", ar: "المنزل", icon: HomeIcon },
            { key: "gym", en: "Gym", ar: "الجيم", icon: Dumbbell },
          ] as const).map((f) => (
            <motion.button
              key={f.key}
              onClick={() => setFilter(f.key)}
              className="flex items-center gap-1.5 px-5 py-2.5 rounded-full transition-all duration-300 relative overflow-hidden"
              style={{
                background: filter === f.key ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "transparent",
                color: filter === f.key ? C.emeraldDark : C.cream,
                border: `1px solid ${filter === f.key ? "transparent" : C.glassBorder}`,
                fontSize: 13,
                boxShadow: filter === f.key ? `0 4px 16px rgba(212,175,55,0.3)` : "none",
              }}
              whileTap={{ scale: 0.95 }}
            >
              {filter === f.key && <GoldShimmer />}
              {f.icon && <f.icon size={14} className="relative z-10" />}
              <span className="relative z-10">{t(f.en, f.ar)}</span>
            </motion.button>
          ))}
        </div>

        {/* Featured Workout */}
        <motion.div
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-5 mb-4 rounded-3xl overflow-hidden relative"
          style={{ height: 200, border: `1px solid ${C.goldBorder}` }}
        >
          <ImageWithFallback
            src={IMAGES[2]}
            alt="featured"
            className="absolute inset-0 w-full h-full object-cover"
          />
          <div className="absolute inset-0" style={{ background: "linear-gradient(180deg, transparent 30%, rgba(0,0,0,0.85))" }} />
          <GoldShimmer />
          <div className="absolute bottom-0 left-0 right-0 p-5 relative z-10">
            <div className="flex items-center gap-1.5 mb-1">
              <Star size={12} color={C.gold} fill={C.gold} />
              <span style={{ color: C.gold, fontSize: 11 }}>{t("Featured Workout", "التمرين المميز")}</span>
            </div>
            <h3 style={{ color: C.cream, fontSize: 19 }}>{t("Full Body Power", "قوة كامل الجسم")}</h3>
            <div className="flex items-center gap-3 mt-1.5">
              <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                <Clock size={11} /> 30 min
              </span>
              <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                <Flame size={11} /> 350 kcal
              </span>
              <span className="px-2 py-0.5 rounded-full" style={{ background: "rgba(255,112,67,0.15)", color: "#ff7043", fontSize: 10 }}>
                {t("Advanced", "متقدم")}
              </span>
            </div>
            <motion.button
              whileTap={{ scale: 0.95 }}
              onClick={() => nav("/exercise")}
              className="mt-3 px-6 py-2 rounded-full relative overflow-hidden"
              style={{
                background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
                color: C.emeraldDark,
                fontSize: 13,
                boxShadow: `0 4px 16px rgba(212,175,55,0.35)`,
              }}
            >
              <GoldShimmer />
              <span className="relative z-10">{t("Start Now", "ابدأ الآن")}</span>
            </motion.button>
          </div>
        </motion.div>

        {/* Workout List */}
        <div className="px-5 flex flex-col gap-3">
          {filtered.map((w, i) => (
            <motion.button
              key={`${w.en}-${i}`}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.05 }}
              onClick={() => nav("/exercise")}
              className="flex gap-3.5 p-3 text-left relative overflow-hidden"
              style={glassCardGold}
              whileTap={{ scale: 0.98 }}
            >
              <GoldShimmer />
              <ImageWithFallback
                src={IMAGES[w.img]}
                alt={w.en}
                className="rounded-2xl object-cover flex-shrink-0 relative z-10"
                style={{ width: 85, height: 85 }}
              />
              <div className="flex-1 flex flex-col justify-between py-0.5 relative z-10">
                <div>
                  <div className="flex items-center gap-1.5">
                    <h4 style={{ color: C.cream, fontSize: 15 }}>{t(w.en, w.ar)}</h4>
                  </div>
                  <div className="flex items-center gap-1 mt-0.5">
                    <Star size={10} color={C.gold} fill={C.gold} />
                    <span style={{ color: C.gold, fontSize: 10 }}>{w.rating}</span>
                    <span style={{ color: C.creamDim, fontSize: 10 }}>
                      • {w.exercises} {t("exercises", "تمرين")}
                    </span>
                  </div>
                </div>
                <div className="flex items-center gap-2.5 mt-1">
                  <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                    <Clock size={11} /> {w.time}
                  </span>
                  <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                    <Flame size={11} /> {w.cal}
                  </span>
                  <span
                    className="px-2 py-0.5 rounded-full"
                    style={{ fontSize: 9, background: `${levelColor(w.level)}15`, color: levelColor(w.level) }}
                  >
                    {t(w.level, w.level === "Beginner" ? "مبتدئ" : w.level === "Intermediate" ? "متوسط" : "متقدم")}
                  </span>
                </div>
              </div>
              <ChevronRight size={16} color={C.goldBorder} className="self-center flex-shrink-0 relative z-10" />
            </motion.button>
          ))}
        </div>
      </div>
    </div>
  );
}
