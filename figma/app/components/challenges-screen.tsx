import { motion } from "motion/react";
import { Trophy, Users, Clock, Flame, ChevronRight, Crown, Lock, Star } from "lucide-react";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard, glassCardGold } from "./royal-theme";
import { ImageWithFallback } from "./figma/ImageWithFallback";

const IMG = "https://images.unsplash.com/photo-1561532325-7d5231a2dede?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaXRuZXNzJTIwZ3ltJTIwd29ya291dCUyMGRhcmt8ZW58MXx8fHwxNzc1OTg4MTcxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral";

export function ChallengesScreen() {
  const { t } = useRoyal();

  const challenges = [
    { en: "30-Day Transform", ar: "تحوّل 30 يوماً", days: 30, progress: 40, participants: "12.5k", active: true },
    { en: "Plank Master", ar: "سيد البلانك", days: 14, progress: 72, participants: "8.3k", active: true },
    { en: "Cardio King", ar: "ملك الكارديو", days: 21, progress: 0, participants: "15.1k", active: false },
    { en: "Flexibility Flow", ar: "مرونة التدفق", days: 28, progress: 0, participants: "6.7k", active: false, locked: true },
  ];

  return (
    <div className="min-h-screen pb-24" style={{ background: `linear-gradient(180deg, ${C.emerald}, ${C.emeraldDark})` }}>
      <GeometricBg />

      <div className="relative z-10">
        <StatusBar />

        <div className="px-5 mt-1 mb-5">
          <h1 style={{ color: C.cream, fontSize: 22 }}>{t("Challenges", "التحديات")}</h1>
          <p className="mt-0.5" style={{ color: C.creamDim, fontSize: 12 }}>
            {t("Push your limits", "تجاوز حدودك")}
          </p>
        </div>

        {/* Active Challenge Banner */}
        <motion.div
          initial={{ opacity: 0, y: 15 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-5 rounded-3xl overflow-hidden relative mb-5"
          style={{ height: 190, border: `1px solid ${C.goldBorder}` }}
        >
          <ImageWithFallback src={IMG} alt="challenge" className="absolute inset-0 w-full h-full object-cover" />
          <div className="absolute inset-0" style={{ background: "linear-gradient(180deg, rgba(1,26,16,0.5) 0%, rgba(1,26,16,0.95) 100%)" }} />
          <GoldShimmer />
          <div className="absolute inset-0 flex flex-col justify-end p-5 relative z-10">
            <div className="flex items-center gap-2 mb-2">
              <Crown size={16} color={C.gold} style={{ filter: `drop-shadow(0 0 6px ${C.goldGlow})` }} />
              <span style={{ color: C.gold, fontSize: 11, letterSpacing: 2 }}>
                {t("ACTIVE CHALLENGE", "التحدي النشط")}
              </span>
            </div>
            <h2 style={{ color: C.cream, fontSize: 22 }}>
              {t("30-Day Royal Transform", "تحوّل ملكي 30 يوماً")}
            </h2>
            <div className="flex items-center gap-4 mt-2">
              <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                <Clock size={11} /> {t("Day 12 of 30", "اليوم 12 من 30")}
              </span>
              <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                <Users size={11} /> 12.5k
              </span>
            </div>
            <div className="mt-3 flex items-center gap-3">
              <div className="flex-1 rounded-full overflow-hidden" style={{ height: 6, background: "rgba(212,175,55,0.15)" }}>
                <motion.div
                  initial={{ width: 0 }}
                  animate={{ width: "40%" }}
                  transition={{ delay: 0.5, duration: 1 }}
                  className="h-full rounded-full"
                  style={{ background: `linear-gradient(90deg, ${C.gold}, ${C.goldLight})`, boxShadow: `0 0 10px rgba(212,175,55,0.4)` }}
                />
              </div>
              <span style={{ color: C.gold, fontSize: 13 }}>40%</span>
            </div>
          </div>
        </motion.div>

        {/* Leaderboard Preview */}
        <div className="mx-5 mb-5">
          <div className="flex items-center justify-between mb-3">
            <h3 style={{ color: C.cream, fontSize: 16 }}>{t("Leaderboard", "المتصدرين")}</h3>
            <button className="flex items-center gap-1" style={{ color: C.gold, fontSize: 12 }}>
              {t("View All", "عرض الكل")} <ChevronRight size={14} />
            </button>
          </div>
          <div className="flex gap-3">
            {[
              { rank: 1, name: "Ahmed", pts: "2,450", medal: "🥇" },
              { rank: 2, name: "Sara", pts: "2,180", medal: "🥈" },
              { rank: 3, name: "Omar", pts: "1,950", medal: "🥉" },
            ].map((p, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.2 + i * 0.08 }}
                className="flex-1 flex flex-col items-center py-4 relative overflow-hidden"
                style={{
                  ...(i === 0 ? glassCardGold : glassCard),
                  ...(i === 0 ? { boxShadow: `0 0 24px rgba(212,175,55,0.12)` } : {}),
                }}
              >
                {i === 0 && <GoldShimmer />}
                <span style={{ fontSize: 24 }}>{p.medal}</span>
                <span className="mt-1 relative z-10" style={{ color: i === 0 ? C.gold : C.cream, fontSize: 14 }}>{p.name}</span>
                <span className="relative z-10" style={{ color: C.creamDim, fontSize: 11 }}>{p.pts} pts</span>
              </motion.div>
            ))}
          </div>
        </div>

        {/* All Challenges */}
        <div className="px-5">
          <h3 className="mb-3" style={{ color: C.cream, fontSize: 16 }}>
            {t("All Challenges", "جميع التحديات")}
          </h3>
          <div className="flex flex-col gap-3">
            {challenges.map((c, i) => (
              <motion.div
                key={i}
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 + i * 0.06 }}
                className="p-4 flex items-center gap-3.5 relative overflow-hidden"
                style={c.active ? glassCardGold : glassCard}
              >
                {c.active && <GoldShimmer />}
                <div
                  className="flex items-center justify-center rounded-2xl flex-shrink-0 relative z-10"
                  style={{
                    width: 52,
                    height: 52,
                    background: c.locked ? "rgba(255,255,255,0.05)" : c.active ? C.goldDim : "rgba(255,255,255,0.05)",
                    border: `1px solid ${c.active ? C.goldBorder : C.glassBorder}`,
                  }}
                >
                  {c.locked ? <Lock size={20} color={C.creamDim} /> : c.active ? <Trophy size={22} color={C.gold} /> : <Star size={22} color={C.creamDim} />}
                </div>
                <div className="flex-1 relative z-10">
                  <h4 style={{ color: c.locked ? C.creamDim : C.cream, fontSize: 15 }}>{t(c.en, c.ar)}</h4>
                  <div className="flex items-center gap-2.5 mt-1">
                    <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                      <Clock size={10} /> {c.days} {t("days", "يوم")}
                    </span>
                    <span className="flex items-center gap-1" style={{ color: C.creamDim, fontSize: 11 }}>
                      <Users size={10} /> {c.participants}
                    </span>
                  </div>
                  {c.active && c.progress > 0 && (
                    <div className="mt-2 flex items-center gap-2">
                      <div className="flex-1 rounded-full overflow-hidden" style={{ height: 4, background: "rgba(212,175,55,0.12)" }}>
                        <div className="h-full rounded-full" style={{ width: `${c.progress}%`, background: C.gold }} />
                      </div>
                      <span style={{ color: C.gold, fontSize: 10 }}>{c.progress}%</span>
                    </div>
                  )}
                </div>
                <ChevronRight size={16} color={c.locked ? C.creamDim : C.goldBorder} className="relative z-10" />
              </motion.div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
