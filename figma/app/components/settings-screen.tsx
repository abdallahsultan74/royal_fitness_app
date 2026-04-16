import { motion } from "motion/react";
import { Crown, Bell, Moon, Globe, Shield, Star, ChevronRight, LogOut, Heart, HelpCircle, Share2, Volume2 } from "lucide-react";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard, glassCardGold } from "./royal-theme";

export function SettingsScreen() {
  const { t, lang, setLang } = useRoyal();

  const sections = [
    {
      title: { en: "Account", ar: "الحساب" },
      items: [
        { icon: Bell, en: "Notifications", ar: "الإشعارات", toggle: false },
        { icon: Globe, en: "Language", ar: "اللغة", value: lang === "ar" ? "العربية" : "English" },
        { icon: Volume2, en: "Voice Coach", ar: "المدرب الصوتي", toggle: true, on: true },
        { icon: Moon, en: "Dark Mode", ar: "الوضع الداكن", toggle: true, on: true },
      ],
    },
    {
      title: { en: "General", ar: "عام" },
      items: [
        { icon: Heart, en: "Health Data", ar: "البيانات الصحية" },
        { icon: Shield, en: "Privacy", ar: "الخصوصية" },
        { icon: Share2, en: "Share App", ar: "مشاركة التطبيق" },
        { icon: Star, en: "Rate Us", ar: "قيّمنا" },
        { icon: HelpCircle, en: "Help & FAQ", ar: "المساعدة" },
      ],
    },
  ];

  return (
    <div className="min-h-screen pb-24" style={{ background: `linear-gradient(180deg, ${C.emerald}, ${C.emeraldDark})` }}>
      <GeometricBg />

      <div className="relative z-10">
        <StatusBar />

        <div className="px-5 mt-1 mb-5">
          <h1 style={{ color: C.cream, fontSize: 22 }}>{t("Settings", "الإعدادات")}</h1>
        </div>

        {/* Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="mx-5 p-5 flex items-center gap-4 relative overflow-hidden mb-5"
          style={glassCardGold}
        >
          <GoldShimmer />
          <div
            className="relative flex items-center justify-center rounded-2xl flex-shrink-0"
            style={{
              width: 64,
              height: 64,
              border: `2px solid ${C.gold}`,
              background: `radial-gradient(circle at 30% 30%, rgba(212,175,55,0.15), transparent)`,
              boxShadow: `0 0 20px rgba(212,175,55,0.15)`,
            }}
          >
            <Crown size={28} color={C.gold} />
          </div>
          <div className="flex-1 relative z-10">
            <h3 style={{ color: C.cream, fontSize: 17 }}>{t("Royal Member", "عضو ملكي")}</h3>
            <p style={{ color: C.creamDim, fontSize: 12 }}>{t("Premium Plan", "الخطة المميزة")}</p>
            <div className="flex gap-4 mt-2">
              {[
                { val: "28", label: t("Workouts", "تمارين") },
                { val: "8", label: t("Day Streak", "أيام") },
              ].map((s, i) => (
                <div key={i} className="flex items-baseline gap-1">
                  <span style={{ color: C.gold, fontSize: 15 }}>{s.val}</span>
                  <span style={{ color: C.creamDim, fontSize: 10 }}>{s.label}</span>
                </div>
              ))}
            </div>
          </div>
          <ChevronRight size={16} color={C.goldBorder} className="relative z-10" />
        </motion.div>

        {/* Language Toggle */}
        <div className="mx-5 mb-5 flex rounded-2xl overflow-hidden" style={{ border: `1px solid ${C.glassBorder}`, background: "rgba(0,0,0,0.15)" }}>
          {(["en", "ar"] as const).map((l) => (
            <button
              key={l}
              onClick={() => setLang(l)}
              className="flex-1 py-3 transition-all duration-300 relative overflow-hidden"
              style={{
                background: lang === l ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "transparent",
                color: lang === l ? C.emeraldDark : C.creamDim,
                fontSize: 14,
              }}
            >
              {lang === l && <GoldShimmer />}
              <span className="relative z-10">{l === "en" ? "English" : "العربية"}</span>
            </button>
          ))}
        </div>

        {/* Menu Sections */}
        {sections.map((section, si) => (
          <div key={si} className="px-5 mb-5">
            <p className="mb-2" style={{ color: C.creamDim, fontSize: 11, letterSpacing: 1 }}>
              {t(section.title.en, section.title.ar).toUpperCase()}
            </p>
            <div className="flex flex-col gap-2">
              {section.items.map((item, i) => (
                <motion.button
                  key={i}
                  initial={{ opacity: 0, x: -15 }}
                  animate={{ opacity: 1, x: 0 }}
                  transition={{ delay: si * 0.1 + i * 0.04 }}
                  className="flex items-center gap-3 p-3.5 relative overflow-hidden"
                  style={glassCard}
                  whileTap={{ scale: 0.98 }}
                >
                  <div
                    className="flex items-center justify-center rounded-xl flex-shrink-0"
                    style={{ width: 38, height: 38, background: C.goldDim, border: `1px solid ${C.glassBorder}` }}
                  >
                    <item.icon size={17} color={C.gold} />
                  </div>
                  <span className="flex-1 text-left" style={{ color: C.cream, fontSize: 14 }}>
                    {t(item.en, item.ar)}
                  </span>
                  {item.value && (
                    <span style={{ color: C.creamDim, fontSize: 12 }}>{item.value}</span>
                  )}
                  {item.toggle ? (
                    <div
                      className="rounded-full relative"
                      style={{
                        width: 46,
                        height: 26,
                        background: item.on ? `linear-gradient(135deg, ${C.gold}, ${C.goldLight})` : "rgba(255,255,255,0.1)",
                        padding: 3,
                        transition: "background 0.3s",
                        boxShadow: item.on ? `0 0 10px rgba(212,175,55,0.2)` : "none",
                      }}
                    >
                      <div
                        className="rounded-full transition-all duration-300"
                        style={{
                          width: 20,
                          height: 20,
                          background: item.on ? C.emeraldDark : C.creamDim,
                          marginLeft: item.on ? 20 : 0,
                        }}
                      />
                    </div>
                  ) : (
                    <ChevronRight size={16} color={C.goldBorder} />
                  )}
                </motion.button>
              ))}
            </div>
          </div>
        ))}

        {/* Logout */}
        <div className="px-5 mb-6">
          <motion.button
            whileTap={{ scale: 0.97 }}
            className="flex items-center gap-3 p-3.5 w-full rounded-3xl"
            style={{ background: "rgba(255,70,70,0.08)", border: "1px solid rgba(255,70,70,0.15)" }}
          >
            <LogOut size={18} color="#ff6b6b" />
            <span style={{ color: "#ff6b6b", fontSize: 14 }}>{t("Log Out", "تسجيل الخروج")}</span>
          </motion.button>
        </div>

        {/* App Version */}
        <p className="text-center mb-4" style={{ color: "rgba(245,234,212,0.2)", fontSize: 11 }}>
          Royal Fitness v2.1.0
        </p>
      </div>
    </div>
  );
}
