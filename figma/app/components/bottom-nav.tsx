import { Home, Dumbbell, Trophy, TrendingUp, Settings } from "lucide-react";
import { useNavigate, useLocation } from "react-router";
import { useRoyal, C, GoldPulse } from "./royal-theme";

const tabs = [
  { path: "/", icon: Home, en: "Home", ar: "الرئيسية" },
  { path: "/workouts", icon: Dumbbell, en: "Workouts", ar: "التمارين" },
  { path: "/challenges", icon: Trophy, en: "Challenges", ar: "التحديات" },
  { path: "/progress", icon: TrendingUp, en: "Progress", ar: "التقدم" },
  { path: "/settings", icon: Settings, en: "Settings", ar: "الإعدادات" },
];

export function BottomNav() {
  const nav = useNavigate();
  const loc = useLocation();
  const { t } = useRoyal();

  return (
    <nav
      className="fixed bottom-0 left-0 right-0 z-50"
      style={{
        paddingBottom: "env(safe-area-inset-bottom, 8px)",
      }}
    >
      {/* Blur backdrop */}
      <div
        className="max-w-md mx-auto flex items-center justify-around relative"
        style={{
          background: `linear-gradient(180deg, rgba(1,26,16,0.88), rgba(1,26,16,0.96))`,
          backdropFilter: "blur(24px)",
          WebkitBackdropFilter: "blur(24px)",
          borderTop: `1px solid ${C.glassBorder}`,
          height: 72,
        }}
      >
        {/* Gold line highlight on top */}
        {tabs.map((tab) => {
          const active = loc.pathname === tab.path;
          const Icon = tab.icon;
          return (
            <button
              key={tab.path}
              onClick={() => nav(tab.path)}
              className="flex flex-col items-center gap-0.5 transition-all duration-300 relative"
              style={{ color: active ? C.gold : "rgba(245,234,212,0.4)", minWidth: 56, paddingTop: 6 }}
            >
              {active && (
                <>
                  <div
                    className="absolute top-0 left-1/2 -translate-x-1/2 rounded-full"
                    style={{
                      width: 24,
                      height: 3,
                      background: C.gold,
                      boxShadow: `0 0 12px ${C.goldGlow}`,
                    }}
                  />
                  <GoldPulse size={50} />
                </>
              )}
              <div
                className="relative flex items-center justify-center transition-all duration-300"
                style={{
                  width: 40,
                  height: 32,
                  borderRadius: 10,
                  background: active ? C.goldDim : "transparent",
                }}
              >
                <Icon size={21} strokeWidth={active ? 2.2 : 1.5} />
              </div>
              <span
                className="transition-all duration-300"
                style={{
                  fontSize: 9,
                  letterSpacing: active ? 0.5 : 0,
                  opacity: active ? 1 : 0.7,
                }}
              >
                {t(tab.en, tab.ar)}
              </span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
