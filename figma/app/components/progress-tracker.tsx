import { useState } from "react";
import { motion } from "motion/react";
import { AreaChart, Area, LineChart, Line, XAxis, YAxis, ResponsiveContainer, Tooltip } from "recharts";
import { Flame, Trophy, Calendar, TrendingDown, ChevronLeft, ChevronRight } from "lucide-react";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard, glassCardGold } from "./royal-theme";

const weightData = [
  { day: "W1", weight: 85 },
  { day: "W2", weight: 84.2 },
  { day: "W3", weight: 83.5 },
  { day: "W4", weight: 83.8 },
  { day: "W5", weight: 82.9 },
  { day: "W6", weight: 82.1 },
  { day: "W7", weight: 81.5 },
  { day: "W8", weight: 80.8 },
];

const calData = [
  { day: "Mon", cal: 320 },
  { day: "Tue", cal: 450 },
  { day: "Wed", cal: 280 },
  { day: "Thu", cal: 520 },
  { day: "Fri", cal: 390 },
  { day: "Sat", cal: 600 },
  { day: "Sun", cal: 420 },
];

export function ProgressTracker() {
  const { t } = useRoyal();
  const [chartTab, setChartTab] = useState<"weight" | "calories">("weight");

  const daysInMonth = 30;
  const startDay = 3;
  const streakDays = new Set([1, 2, 3, 5, 6, 7, 8, 9, 10, 12]);
  const today = 12;

  const weeks: (number | null)[][] = [];
  let week: (number | null)[] = Array(startDay).fill(null);
  for (let d = 1; d <= daysInMonth; d++) {
    week.push(d);
    if (week.length === 7) { weeks.push(week); week = []; }
  }
  if (week.length) { while (week.length < 7) week.push(null); weeks.push(week); }

  const stats = [
    { icon: Flame, en: "Calories", ar: "السعرات", val: "12.8k", color: "#ff6b6b" },
    { icon: Trophy, en: "Workouts", ar: "التمارين", val: "28", color: C.gold },
    { icon: Calendar, en: "Streak", ar: "الاستمرار", val: "8d", color: "#66bb6a" },
    { icon: TrendingDown, en: "Lost", ar: "مفقود", val: "4.2kg", color: "#4fc3f7" },
  ];

  return (
    <div className="min-h-screen pb-24" style={{ background: `linear-gradient(180deg, ${C.emerald}, ${C.emeraldDark})` }}>
      <GeometricBg />

      <div className="relative z-10">
        <StatusBar />

        <div className="px-5 mt-1 mb-5">
          <h1 style={{ color: C.cream, fontSize: 22 }}>{t("Your Progress", "تقدمك")}</h1>
          <p className="mt-0.5" style={{ color: C.creamDim, fontSize: 12 }}>
            {t("Track your royal journey", "تتبع رحلتك الملكية")}
          </p>
        </div>

        {/* Stats Row */}
        <div className="flex gap-2.5 px-5 mb-5 overflow-x-auto" style={{ scrollbarWidth: "none" }}>
          {stats.map((s, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 15 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: i * 0.06 }}
              className="flex-1 min-w-[75px] p-3.5 flex flex-col items-center gap-1.5 relative overflow-hidden"
              style={glassCardGold}
            >
              <div
                className="flex items-center justify-center rounded-xl"
                style={{ width: 36, height: 36, background: `${s.color}12` }}
              >
                <s.icon size={17} color={s.color} />
              </div>
              <span style={{ color: C.cream, fontSize: 17 }}>{s.val}</span>
              <span style={{ color: C.creamDim, fontSize: 9 }}>{t(s.en, s.ar)}</span>
            </motion.div>
          ))}
        </div>

        {/* Chart Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.25 }}
          className="mx-5 p-4 relative overflow-hidden mb-4"
          style={glassCardGold}
        >
          <GoldShimmer />

          {/* Chart Tabs */}
          <div className="flex gap-2 mb-4 relative z-10">
            {([
              { key: "weight" as const, en: "Weight", ar: "الوزن" },
              { key: "calories" as const, en: "Calories", ar: "السعرات" },
            ]).map((tab) => (
              <button
                key={tab.key}
                onClick={() => setChartTab(tab.key)}
                className="px-4 py-1.5 rounded-full transition-all duration-300"
                style={{
                  background: chartTab === tab.key ? C.goldDim : "transparent",
                  color: chartTab === tab.key ? C.gold : C.creamDim,
                  border: `1px solid ${chartTab === tab.key ? C.goldBorder : "transparent"}`,
                  fontSize: 12,
                }}
              >
                {t(tab.en, tab.ar)}
              </button>
            ))}
          </div>

          {chartTab === "weight" ? (
            <>
              <div className="flex items-baseline gap-2 mb-1 relative z-10">
                <span style={{ color: C.cream, fontSize: 24 }}>80.8 kg</span>
                <span style={{ color: "#66bb6a", fontSize: 12 }}>▼ 4.2 kg</span>
              </div>
              <p className="mb-3 relative z-10" style={{ color: C.creamDim, fontSize: 11 }}>
                {t("Last 8 weeks", "آخر 8 أسابيع")}
              </p>
              <ResponsiveContainer width="100%" height={140}>
                <AreaChart data={weightData}>
                  <defs>
                    <linearGradient id="wGrad" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="0%" stopColor={C.gold} stopOpacity={0.25} />
                      <stop offset="100%" stopColor={C.gold} stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fill: C.creamDim, fontSize: 10 }} />
                  <YAxis domain={["auto", "auto"]} hide />
                  <Tooltip
                    contentStyle={{ background: C.obsidian, border: `1px solid ${C.goldBorder}`, borderRadius: 12, fontSize: 12 }}
                    labelStyle={{ color: C.cream }}
                    itemStyle={{ color: C.gold }}
                  />
                  <Area type="monotone" dataKey="weight" stroke={C.gold} strokeWidth={2.5} fill="url(#wGrad)" dot={{ fill: C.gold, r: 3.5, strokeWidth: 0 }} activeDot={{ r: 5, fill: C.gold, stroke: C.emeraldDark, strokeWidth: 2 }} />
                </AreaChart>
              </ResponsiveContainer>
            </>
          ) : (
            <>
              <div className="flex items-baseline gap-2 mb-1 relative z-10">
                <span style={{ color: C.cream, fontSize: 24 }}>2,980</span>
                <span style={{ color: C.creamDim, fontSize: 12 }}>kcal {t("this week", "هذا الأسبوع")}</span>
              </div>
              <p className="mb-3 relative z-10" style={{ color: C.creamDim, fontSize: 11 }}>
                {t("Daily breakdown", "التوزيع اليومي")}
              </p>
              <ResponsiveContainer width="100%" height={140}>
                <LineChart data={calData}>
                  <XAxis dataKey="day" axisLine={false} tickLine={false} tick={{ fill: C.creamDim, fontSize: 10 }} />
                  <YAxis hide />
                  <Tooltip
                    contentStyle={{ background: C.obsidian, border: `1px solid ${C.goldBorder}`, borderRadius: 12, fontSize: 12 }}
                    labelStyle={{ color: C.cream }}
                    itemStyle={{ color: "#ff6b6b" }}
                  />
                  <Line type="monotone" dataKey="cal" stroke="#ff6b6b" strokeWidth={2.5} dot={{ fill: "#ff6b6b", r: 3.5, strokeWidth: 0 }} activeDot={{ r: 5, fill: "#ff6b6b", stroke: C.emeraldDark, strokeWidth: 2 }} />
                </LineChart>
              </ResponsiveContainer>
            </>
          )}
        </motion.div>

        {/* Calendar Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.35 }}
          className="mx-5 p-4 relative overflow-hidden"
          style={glassCardGold}
        >
          <GoldShimmer />

          <div className="flex items-center justify-between mb-4 relative z-10">
            <motion.button whileTap={{ scale: 0.9 }} className="flex items-center justify-center" style={{ width: 32, height: 32, borderRadius: 10, background: C.goldDim }}>
              <ChevronLeft size={16} color={C.gold} />
            </motion.button>
            <h3 style={{ color: C.cream, fontSize: 15 }}>April 2026</h3>
            <motion.button whileTap={{ scale: 0.9 }} className="flex items-center justify-center" style={{ width: 32, height: 32, borderRadius: 10, background: C.goldDim }}>
              <ChevronRight size={16} color={C.gold} />
            </motion.button>
          </div>

          <div className="grid grid-cols-7 gap-1 mb-2 relative z-10">
            {(t("S,M,T,W,T,F,S", "أ,إ,ث,أ,خ,ج,س")).split(",").map((d, i) => (
              <div key={i} className="text-center" style={{ color: C.creamDim, fontSize: 10, paddingBottom: 4 }}>{d}</div>
            ))}
          </div>

          <div className="relative z-10">
            {weeks.map((wk, wi) => (
              <div key={wi} className="grid grid-cols-7 gap-1 mb-1">
                {wk.map((day, di) => {
                  if (!day) return <div key={di} />;
                  const isStreak = streakDays.has(day);
                  const isToday = day === today;
                  return (
                    <motion.div
                      key={di}
                      initial={{ scale: 0.8, opacity: 0 }}
                      animate={{ scale: 1, opacity: 1 }}
                      transition={{ delay: 0.4 + (wi * 7 + di) * 0.01 }}
                      className="flex items-center justify-center rounded-xl"
                      style={{
                        height: 38,
                        background: isToday
                          ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`
                          : isStreak
                          ? C.goldDim
                          : "transparent",
                        color: isToday ? C.emeraldDark : isStreak ? C.gold : C.creamDim,
                        fontSize: 12,
                        border: isStreak && !isToday ? `1px solid ${C.goldBorder}` : "none",
                        boxShadow: isToday ? `0 0 16px rgba(212,175,55,0.4)` : "none",
                      }}
                    >
                      {day}
                    </motion.div>
                  );
                })}
              </div>
            ))}
          </div>

          <div className="flex items-center gap-5 mt-3 justify-center relative z-10">
            <div className="flex items-center gap-1.5">
              <div className="rounded-md" style={{ width: 10, height: 10, background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` }} />
              <span style={{ color: C.creamDim, fontSize: 10 }}>{t("Today", "اليوم")}</span>
            </div>
            <div className="flex items-center gap-1.5">
              <div className="rounded-md" style={{ width: 10, height: 10, background: C.goldDim, border: `1px solid ${C.goldBorder}` }} />
              <span style={{ color: C.creamDim, fontSize: 10 }}>{t("Workout Day", "يوم تمرين")}</span>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}
