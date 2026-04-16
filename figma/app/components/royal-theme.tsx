import React, { createContext, useContext, useState } from "react";

type Lang = "en" | "ar";
interface ThemeCtx {
  lang: Lang;
  setLang: (l: Lang) => void;
  t: (en: string, ar: string) => string;
  dir: "ltr" | "rtl";
}

const Ctx = createContext<ThemeCtx>({
  lang: "en",
  setLang: () => {},
  t: (en) => en,
  dir: "ltr",
});

export const useRoyal = () => useContext(Ctx);

export function RoyalProvider({ children }: { children: React.ReactNode }) {
  const [lang, setLang] = useState<Lang>("en");
  const dir = lang === "ar" ? "rtl" : "ltr";
  const t = (en: string, ar: string) => (lang === "ar" ? ar : en);

  return (
    <Ctx.Provider value={{ lang, setLang, t, dir }}>
      <div dir={dir} style={{ fontFamily: lang === "ar" ? "'Cairo', sans-serif" : "'Montserrat', sans-serif" }}>
        {children}
      </div>
    </Ctx.Provider>
  );
}

export const C = {
  emerald: "#013220",
  emeraldLight: "#01472d",
  emeraldMid: "#024a30",
  emeraldDark: "#001a10",
  gold: "#D4AF37",
  goldLight: "#e6c65c",
  goldDim: "rgba(212,175,55,0.12)",
  goldBorder: "rgba(212,175,55,0.25)",
  goldGlow: "rgba(212,175,55,0.35)",
  obsidian: "#0d1117",
  obsidianCard: "rgba(13,17,23,0.55)",
  cream: "#F5EAD4",
  creamDim: "rgba(245,234,212,0.55)",
  white: "#ffffff",
  glass: "rgba(1,50,32,0.45)",
  glassBorder: "rgba(212,175,55,0.18)",
};

// Glassmorphism card style
export const glassCard: React.CSSProperties = {
  background: `linear-gradient(135deg, ${C.glass}, ${C.obsidianCard})`,
  backdropFilter: "blur(24px)",
  WebkitBackdropFilter: "blur(24px)",
  border: `1px solid ${C.glassBorder}`,
  borderRadius: 24,
};

export const glassCardGold: React.CSSProperties = {
  ...glassCard,
  border: `1px solid ${C.goldBorder}`,
  boxShadow: `0 0 30px rgba(212,175,55,0.06), inset 0 1px 0 rgba(212,175,55,0.1)`,
};

// Safe area wrapper for mobile
export function SafeArea({ children, className = "", style = {} }: { children: React.ReactNode; className?: string; style?: React.CSSProperties }) {
  return (
    <div
      className={className}
      style={{
        paddingTop: "env(safe-area-inset-top, 20px)",
        paddingBottom: "env(safe-area-inset-bottom, 0px)",
        paddingLeft: "env(safe-area-inset-left, 0px)",
        paddingRight: "env(safe-area-inset-right, 0px)",
        ...style,
      }}
    >
      {children}
    </div>
  );
}

// Status bar mock for mobile feel
export function StatusBar() {
  return (
    <div
      className="flex items-center justify-between px-6 relative z-50"
      style={{
        height: 44,
        paddingTop: "env(safe-area-inset-top, 12px)",
      }}
    >
      <span style={{ color: C.cream, fontSize: 13 }}>9:41</span>
      <div className="flex items-center gap-1.5">
        <div className="flex items-end gap-[2px]">
          {[6, 8, 10, 12].map((h, i) => (
            <div key={i} style={{ width: 3, height: h, borderRadius: 1, background: C.cream }} />
          ))}
        </div>
        <svg width="16" height="12" viewBox="0 0 16 12" fill="none">
          <path d="M8 2.5C9.9 2.5 11.6 3.3 12.8 4.5L14 3.3C12.5 1.8 10.4 0.8 8 0.8C5.6 0.8 3.5 1.8 2 3.3L3.2 4.5C4.4 3.3 6.1 2.5 8 2.5Z" fill={C.cream} />
          <path d="M8 5.5C9.1 5.5 10.2 5.9 10.9 6.7L12.1 5.5C11.1 4.5 9.6 3.8 8 3.8C6.4 3.8 4.9 4.5 3.9 5.5L5.1 6.7C5.8 5.9 6.9 5.5 8 5.5Z" fill={C.cream} />
          <circle cx="8" cy="9.5" r="1.5" fill={C.cream} />
        </svg>
        <div style={{ width: 24, height: 11, borderRadius: 3, border: `1px solid ${C.cream}`, position: "relative", overflow: "hidden" }}>
          <div style={{ position: "absolute", left: 1, top: 1, bottom: 1, width: "70%", borderRadius: 2, background: "#4caf50" }} />
        </div>
      </div>
    </div>
  );
}

// Islamic geometric pattern SVG as background
export function GeometricBg() {
  return (
    <div className="absolute inset-0 overflow-hidden pointer-events-none" style={{ opacity: 0.035 }}>
      <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
        <defs>
          <pattern id="islamic" x="0" y="0" width="80" height="80" patternUnits="userSpaceOnUse">
            <path d="M40 0L80 20L80 60L40 80L0 60L0 20Z" fill="none" stroke="#D4AF37" strokeWidth="0.8" />
            <circle cx="40" cy="40" r="12" fill="none" stroke="#D4AF37" strokeWidth="0.5" />
            <circle cx="40" cy="40" r="4" fill="none" stroke="#D4AF37" strokeWidth="0.3" />
            <path d="M40 0L40 80M0 40L80 40" stroke="#D4AF37" strokeWidth="0.2" />
            <path d="M20 10L60 10M20 70L60 70" stroke="#D4AF37" strokeWidth="0.2" />
            <path d="M0 20L40 0L80 20M0 60L40 80L80 60" stroke="#D4AF37" strokeWidth="0.2" />
          </pattern>
        </defs>
        <rect width="100%" height="100%" fill="url(#islamic)" />
      </svg>
    </div>
  );
}

// Gold shimmer animation
export function GoldShimmer({ className = "" }: { className?: string }) {
  return (
    <div
      className={`absolute inset-0 pointer-events-none overflow-hidden rounded-[inherit] ${className}`}
    >
      <div
        className="absolute inset-0"
        style={{
          background: "linear-gradient(105deg, transparent 20%, rgba(212,175,55,0.07) 45%, rgba(212,175,55,0.12) 50%, rgba(212,175,55,0.07) 55%, transparent 80%)",
          animation: "shimmer 4s ease-in-out infinite",
        }}
      />
      <style>{`
        @keyframes shimmer {
          0%, 100% { transform: translateX(-100%); }
          50% { transform: translateX(100%); }
        }
      `}</style>
    </div>
  );
}

// Gold glow pulse for active elements
export function GoldPulse({ size = 80 }: { size?: number }) {
  return (
    <div
      className="absolute rounded-full pointer-events-none"
      style={{
        width: size,
        height: size,
        left: "50%",
        top: "50%",
        transform: "translate(-50%, -50%)",
        background: `radial-gradient(circle, rgba(212,175,55,0.15) 0%, transparent 70%)`,
        animation: "pulse-glow 2s ease-in-out infinite",
      }}
    >
      <style>{`
        @keyframes pulse-glow {
          0%, 100% { opacity: 0.5; transform: translate(-50%,-50%) scale(1); }
          50% { opacity: 1; transform: translate(-50%,-50%) scale(1.3); }
        }
      `}</style>
    </div>
  );
}
