import { useState } from "react";
import { motion } from "motion/react";
import { Crown, Dumbbell, ChevronRight } from "lucide-react";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar } from "./royal-theme";

export function Onboarding({ onComplete }: { onComplete: () => void }) {
  const { lang, setLang, t } = useRoyal();
  const [step, setStep] = useState(0);
  const [selected, setSelected] = useState<number | null>(null);

  if (step === 0) {
    return (
      <div
        className="fixed inset-0 flex flex-col"
        style={{ background: `linear-gradient(180deg, ${C.emerald} 0%, ${C.emeraldDark} 100%)` }}
      >
        <GeometricBg />
        <StatusBar />

        <div className="flex-1 flex flex-col items-center justify-center px-8">
          {/* Logo */}
          <motion.div
            initial={{ scale: 0, rotate: -180 }}
            animate={{ scale: 1, rotate: 0 }}
            transition={{ duration: 1.2, type: "spring", bounce: 0.3 }}
            className="relative flex items-center justify-center"
            style={{
              width: 150,
              height: 150,
              borderRadius: "50%",
              border: `2px solid ${C.gold}`,
              boxShadow: `0 0 60px rgba(212,175,55,0.25), 0 0 120px rgba(212,175,55,0.08), inset 0 0 30px rgba(212,175,55,0.08)`,
              background: `radial-gradient(circle at 30% 30%, rgba(212,175,55,0.1), transparent 60%)`,
            }}
          >
            <GoldShimmer />
            <Dumbbell size={56} color={C.gold} style={{ filter: `drop-shadow(0 0 8px rgba(212,175,55,0.5))` }} />
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8 }}
              className="absolute -top-4"
            >
              <Crown size={28} color={C.gold} style={{ filter: `drop-shadow(0 0 10px rgba(212,175,55,0.6))` }} />
            </motion.div>
          </motion.div>

          {/* Title */}
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.5, duration: 0.6 }}
            className="mt-10 flex flex-col items-center"
          >
            <h1 style={{ color: C.gold, fontSize: 30, letterSpacing: 6 }}>ROYAL</h1>
            <h1 style={{ color: C.cream, fontSize: 30, letterSpacing: 6, marginTop: -4 }}>FITNESS</h1>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.9 }}
            className="mt-3 flex items-center gap-3"
          >
            <div style={{ width: 24, height: 1, background: C.goldBorder }} />
            <span style={{ color: C.creamDim, fontSize: 12, letterSpacing: 3 }}>
              {t("TRAIN LIKE ROYALTY", "تدرّب كالملوك")}
            </span>
            <div style={{ width: 24, height: 1, background: C.goldBorder }} />
          </motion.div>

          {/* Language toggle */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 1.2 }}
            className="mt-14 flex rounded-2xl overflow-hidden"
            style={{ border: `1px solid ${C.goldBorder}`, background: "rgba(0,0,0,0.2)" }}
          >
            {(["en", "ar"] as const).map((l) => (
              <button
                key={l}
                onClick={() => setLang(l)}
                className="px-8 py-3.5 transition-all duration-300 relative"
                style={{
                  background: lang === l ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "transparent",
                  color: lang === l ? C.emeraldDark : C.creamDim,
                  fontSize: 14,
                  minWidth: 120,
                }}
              >
                {lang === l && <GoldShimmer />}
                {l === "en" ? "English" : "العربية"}
              </button>
            ))}
          </motion.div>
        </div>

        {/* Bottom CTA — thumb-friendly placement */}
        <motion.div
          initial={{ opacity: 0, y: 40 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 1.5 }}
          className="px-6 pb-10"
          style={{ paddingBottom: "max(env(safe-area-inset-bottom, 24px), 24px)" }}
        >
          <motion.button
            onClick={() => setStep(1)}
            className="w-full py-4.5 rounded-2xl flex items-center justify-center gap-2 relative overflow-hidden"
            style={{
              background: `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
              color: C.emeraldDark,
              fontSize: 16,
              boxShadow: `0 8px 32px rgba(212,175,55,0.35)`,
              letterSpacing: 1,
            }}
            whileTap={{ scale: 0.97 }}
          >
            <GoldShimmer />
            <span className="relative z-10">{t("Get Started", "ابدأ الآن")}</span>
            <ChevronRight size={18} className="relative z-10" />
          </motion.button>
        </motion.div>
      </div>
    );
  }

  // Step 1: Goal selection
  const goals = [
    { en: "Lose Weight", ar: "خسارة الوزن", icon: "🔥", desc: { en: "Burn fat & get lean", ar: "احرق الدهون" } },
    { en: "Build Muscle", ar: "بناء العضلات", icon: "💪", desc: { en: "Gain strength & size", ar: "اكتسب القوة والحجم" } },
    { en: "Stay Fit", ar: "الحفاظ على اللياقة", icon: "⚡", desc: { en: "Maintain your health", ar: "حافظ على صحتك" } },
    { en: "Flexibility", ar: "المرونة", icon: "🧘", desc: { en: "Improve mobility", ar: "حسّن مرونتك" } },
  ];

  return (
    <div
      className="fixed inset-0 flex flex-col"
      style={{ background: `linear-gradient(180deg, ${C.emerald} 0%, ${C.emeraldDark} 100%)` }}
    >
      <GeometricBg />
      <StatusBar />

      <div className="flex-1 flex flex-col px-6 pt-4">
        {/* Progress dots */}
        <div className="flex gap-2 mb-8 justify-center">
          {[0, 1].map((i) => (
            <div
              key={i}
              className="rounded-full transition-all duration-500"
              style={{
                width: i === 1 ? 24 : 8,
                height: 8,
                background: i === 1 ? C.gold : C.goldBorder,
                boxShadow: i === 1 ? `0 0 8px rgba(212,175,55,0.4)` : "none",
              }}
            />
          ))}
        </div>

        <motion.h2
          initial={{ opacity: 0, y: -20 }}
          animate={{ opacity: 1, y: 0 }}
          style={{ color: C.cream, fontSize: 24, textAlign: "center" }}
        >
          {t("What's Your Goal?", "ما هو هدفك؟")}
        </motion.h2>
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.2 }}
          className="mt-2 mb-8 text-center"
          style={{ color: C.creamDim, fontSize: 14 }}
        >
          {t("Select your primary fitness goal", "اختر هدفك الرئيسي في اللياقة")}
        </motion.p>

        <div className="flex flex-col gap-3">
          {goals.map((g, i) => (
            <motion.button
              key={i}
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              transition={{ delay: 0.1 + i * 0.08 }}
              onClick={() => setSelected(i)}
              className="flex items-center gap-4 p-4 rounded-2xl transition-all duration-300 relative overflow-hidden"
              style={{
                background: selected === i
                  ? `linear-gradient(135deg, rgba(212,175,55,0.15), rgba(212,175,55,0.05))`
                  : `linear-gradient(135deg, rgba(1,50,32,0.5), rgba(13,17,23,0.5))`,
                backdropFilter: "blur(16px)",
                border: `1px solid ${selected === i ? C.gold : C.glassBorder}`,
                boxShadow: selected === i ? `0 0 24px rgba(212,175,55,0.15)` : "none",
              }}
            >
              {selected === i && <GoldShimmer />}
              <div
                className="flex items-center justify-center rounded-xl relative z-10"
                style={{
                  width: 50,
                  height: 50,
                  background: selected === i ? C.goldDim : "rgba(255,255,255,0.05)",
                  border: `1px solid ${selected === i ? C.goldBorder : "rgba(255,255,255,0.05)"}`,
                  fontSize: 24,
                }}
              >
                {g.icon}
              </div>
              <div className="flex-1 text-left relative z-10">
                <p style={{ color: selected === i ? C.gold : C.cream, fontSize: 15 }}>{t(g.en, g.ar)}</p>
                <p style={{ color: C.creamDim, fontSize: 12, marginTop: 2 }}>{t(g.desc.en, g.desc.ar)}</p>
              </div>
              <div
                className="flex items-center justify-center rounded-full relative z-10"
                style={{
                  width: 22,
                  height: 22,
                  border: `2px solid ${selected === i ? C.gold : C.goldBorder}`,
                  background: selected === i ? C.gold : "transparent",
                }}
              >
                {selected === i && (
                  <div className="rounded-full" style={{ width: 8, height: 8, background: C.emeraldDark }} />
                )}
              </div>
            </motion.button>
          ))}
        </div>
      </div>

      {/* Bottom CTA */}
      <div className="px-6 pb-6" style={{ paddingBottom: "max(env(safe-area-inset-bottom, 24px), 24px)" }}>
        <motion.button
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.5 }}
          onClick={onComplete}
          disabled={selected === null}
          className="w-full py-4.5 rounded-2xl flex items-center justify-center gap-2 relative overflow-hidden transition-all duration-300"
          style={{
            background: selected !== null
              ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`
              : "rgba(212,175,55,0.15)",
            color: selected !== null ? C.emeraldDark : "rgba(245,234,212,0.3)",
            fontSize: 16,
            letterSpacing: 1,
            boxShadow: selected !== null ? `0 8px 32px rgba(212,175,55,0.35)` : "none",
          }}
          whileTap={selected !== null ? { scale: 0.97 } : undefined}
        >
          {selected !== null && <GoldShimmer />}
          <span className="relative z-10">{t("Continue", "متابعة")}</span>
          <ChevronRight size={18} className="relative z-10" />
        </motion.button>
      </div>
    </div>
  );
}
