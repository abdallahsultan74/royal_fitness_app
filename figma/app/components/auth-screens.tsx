import { useState } from "react";
import { motion, AnimatePresence } from "motion/react";
import {
  Crown, Dumbbell, ChevronLeft, Eye, EyeOff, Mail, Lock, User,
  Target, ChevronRight, ChevronDown,
} from "lucide-react";
import { useRoyal, C, GeometricBg, GoldShimmer, StatusBar, glassCard } from "./royal-theme";

const inputStyle: React.CSSProperties = {
  background: `linear-gradient(135deg, rgba(1,50,32,0.5), rgba(13,17,23,0.5))`,
  backdropFilter: "blur(16px)",
  border: `1px solid ${C.goldBorder}`,
  borderRadius: 16,
  color: C.cream,
  fontSize: 14,
  outline: "none",
  width: "100%",
};

const inputFocusStyle: React.CSSProperties = {
  border: `1px solid ${C.gold}`,
  boxShadow: `0 0 16px rgba(212,175,55,0.12)`,
};

function GoldButton({ children, onClick, disabled }: { children: React.ReactNode; onClick?: () => void; disabled?: boolean }) {
  return (
    <motion.button
      onClick={onClick}
      disabled={disabled}
      whileTap={disabled ? undefined : { scale: 0.97 }}
      className="w-full py-4 rounded-2xl flex items-center justify-center gap-2 relative overflow-hidden transition-all duration-300"
      style={{
        background: disabled
          ? "rgba(212,175,55,0.15)"
          : `linear-gradient(135deg, ${C.gold}, ${C.goldLight})`,
        color: disabled ? "rgba(245,234,212,0.3)" : C.emeraldDark,
        fontSize: 16,
        letterSpacing: 1,
        boxShadow: disabled ? "none" : `0 8px 32px rgba(212,175,55,0.35), 0 0 60px rgba(212,175,55,0.1)`,
      }}
    >
      {!disabled && <GoldShimmer />}
      <span className="relative z-10">{children}</span>
    </motion.button>
  );
}

function InputField({
  icon: Icon,
  placeholder,
  type = "text",
  value,
  onChange,
}: {
  icon: React.ElementType;
  placeholder: string;
  type?: string;
  value: string;
  onChange: (v: string) => void;
}) {
  const [focused, setFocused] = useState(false);
  const [showPw, setShowPw] = useState(false);
  const isPassword = type === "password";

  return (
    <div
      className="flex items-center gap-3 px-4 transition-all duration-300"
      style={{
        height: 56,
        ...inputStyle,
        ...(focused ? inputFocusStyle : {}),
      }}
    >
      <Icon size={18} color={focused ? C.gold : C.creamDim} className="flex-shrink-0 transition-colors duration-300" />
      <input
        type={isPassword && !showPw ? "password" : "text"}
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange(e.target.value)}
        onFocus={() => setFocused(true)}
        onBlur={() => setFocused(false)}
        className="flex-1 bg-transparent outline-none placeholder-opacity-50"
        style={{ color: C.cream, fontSize: 14, fontFamily: "inherit" }}
      />
      {isPassword && (
        <button onClick={() => setShowPw(!showPw)} className="flex-shrink-0">
          {showPw ? <EyeOff size={18} color={C.creamDim} /> : <Eye size={18} color={C.creamDim} />}
        </button>
      )}
    </div>
  );
}

function SocialButton({ icon, label }: { icon: React.ReactNode; label: string }) {
  return (
    <motion.button
      whileTap={{ scale: 0.96 }}
      className="flex-1 flex items-center justify-center gap-2.5 py-3.5 rounded-2xl relative overflow-hidden"
      style={{
        border: `1px solid ${C.goldBorder}`,
        background: `linear-gradient(135deg, rgba(1,50,32,0.4), rgba(13,17,23,0.4))`,
        backdropFilter: "blur(12px)",
      }}
    >
      {icon}
      <span style={{ color: C.cream, fontSize: 13 }}>{label}</span>
    </motion.button>
  );
}

// Google SVG icon
function GoogleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24">
      <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92a5.06 5.06 0 01-2.2 3.32v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.1z" fill="#4285F4" />
      <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853" />
      <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z" fill="#FBBC05" />
      <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335" />
    </svg>
  );
}

function AppleIcon() {
  return (
    <svg width="18" height="18" viewBox="0 0 24 24" fill={C.cream}>
      <path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.48-3.24 0-1.44.62-2.2.44-3.06-.4C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.54 4.09zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
    </svg>
  );
}

function Logo() {
  return (
    <motion.div
      initial={{ scale: 0, rotate: -180 }}
      animate={{ scale: 1, rotate: 0 }}
      transition={{ duration: 0.8, type: "spring", bounce: 0.3 }}
      className="flex flex-col items-center"
    >
      <div
        className="relative flex items-center justify-center"
        style={{
          width: 100,
          height: 100,
          borderRadius: "50%",
          border: `2px solid ${C.gold}`,
          boxShadow: `0 0 50px rgba(212,175,55,0.2), inset 0 0 20px rgba(212,175,55,0.06)`,
          background: `radial-gradient(circle at 30% 30%, rgba(212,175,55,0.08), transparent 60%)`,
        }}
      >
        <GoldShimmer />
        <Dumbbell size={40} color={C.gold} style={{ filter: `drop-shadow(0 0 6px rgba(212,175,55,0.4))` }} />
        <motion.div
          initial={{ opacity: 0, y: -8 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="absolute -top-3"
        >
          <Crown size={22} color={C.gold} style={{ filter: `drop-shadow(0 0 8px rgba(212,175,55,0.5))` }} />
        </motion.div>
      </div>
      <motion.div
        initial={{ opacity: 0, y: 10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ delay: 0.3 }}
        className="mt-4 flex flex-col items-center"
      >
        <h1 style={{ color: C.gold, fontSize: 22, letterSpacing: 5 }}>ROYAL</h1>
        <h1 style={{ color: C.cream, fontSize: 22, letterSpacing: 5, marginTop: -2 }}>FITNESS</h1>
      </motion.div>
    </motion.div>
  );
}

export function AuthScreens({ onComplete }: { onComplete: () => void }) {
  const { lang, setLang, t } = useRoyal();
  const [screen, setScreen] = useState<"login" | "signup">("login");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [goal, setGoal] = useState("");
  const [goalOpen, setGoalOpen] = useState(false);

  const goals = [
    { en: "Lose Weight", ar: "خسارة الوزن" },
    { en: "Build Muscle", ar: "بناء العضلات" },
    { en: "Stay Fit", ar: "الحفاظ على اللياقة" },
    { en: "Flexibility", ar: "المرونة" },
  ];

  return (
    <div
      className="fixed inset-0 flex flex-col overflow-y-auto"
      style={{ background: `linear-gradient(180deg, ${C.emerald} 0%, ${C.emeraldDark} 100%)` }}
    >
      <GeometricBg />

      <div className="relative z-10 flex flex-col flex-1 max-w-md mx-auto w-full">
        <StatusBar />

        {/* Top bar: back arrow (signup) + language toggle */}
        <div className="flex items-center justify-between px-5 mt-1 mb-2">
          {screen === "signup" ? (
            <motion.button
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              whileTap={{ scale: 0.9 }}
              onClick={() => setScreen("login")}
              className="flex items-center justify-center"
              style={{
                width: 40,
                height: 40,
                borderRadius: 12,
                ...glassCard,
              }}
            >
              <ChevronLeft size={20} color={C.gold} />
            </motion.button>
          ) : (
            <div />
          )}

          {/* Language Toggle */}
          <motion.button
            whileTap={{ scale: 0.95 }}
            onClick={() => setLang(lang === "en" ? "ar" : "en")}
            className="flex items-center gap-1.5 px-3.5 py-2 rounded-full"
            style={{
              border: `1px solid ${C.glassBorder}`,
              background: "rgba(0,0,0,0.15)",
            }}
          >
            <span style={{ color: lang === "en" ? C.gold : C.creamDim, fontSize: 12 }}>EN</span>
            <div style={{ width: 1, height: 12, background: C.glassBorder }} />
            <span style={{ color: lang === "ar" ? C.gold : C.creamDim, fontSize: 12 }}>عر</span>
          </motion.button>
        </div>

        <AnimatePresence mode="wait">
          {screen === "login" ? (
            <motion.div
              key="login"
              initial={{ opacity: 0, x: -30 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 30 }}
              transition={{ duration: 0.3 }}
              className="flex-1 flex flex-col px-6"
            >
              {/* Logo */}
              <div className="flex justify-center mt-4 mb-8">
                <Logo />
              </div>

              {/* Welcome text */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.4 }}
                className="mb-6"
              >
                <h2 style={{ color: C.cream, fontSize: 24 }}>
                  {t("Welcome Back", "مرحباً بعودتك")}
                </h2>
                <p className="mt-1" style={{ color: C.creamDim, fontSize: 13 }}>
                  {t("Sign in to continue your royal journey", "سجّل دخولك لمتابعة رحلتك الملكية")}
                </p>
              </motion.div>

              {/* Input Fields */}
              <div className="flex flex-col gap-3 mb-4">
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.5 }}>
                  <InputField
                    icon={Mail}
                    placeholder={t("Email Address", "البريد الإلكتروني")}
                    type="text"
                    value={email}
                    onChange={setEmail}
                  />
                </motion.div>
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.55 }}>
                  <InputField
                    icon={Lock}
                    placeholder={t("Password", "كلمة المرور")}
                    type="password"
                    value={password}
                    onChange={setPassword}
                  />
                </motion.div>
              </div>

              {/* Forgot Password */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.6 }}
                className="flex justify-end mb-6"
              >
                <button style={{ color: C.gold, fontSize: 12 }}>
                  {t("Forgot Password?", "نسيت كلمة المرور؟")}
                </button>
              </motion.div>

              {/* Sign In Button */}
              <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.65 }}>
                <GoldButton onClick={onComplete}>
                  {t("Sign In", "تسجيل الدخول")}
                </GoldButton>
              </motion.div>

              {/* Divider */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.7 }}
                className="flex items-center gap-4 my-6"
              >
                <div className="flex-1" style={{ height: 1, background: C.glassBorder }} />
                <span style={{ color: C.creamDim, fontSize: 11, letterSpacing: 1 }}>
                  {t("OR", "أو")}
                </span>
                <div className="flex-1" style={{ height: 1, background: C.glassBorder }} />
              </motion.div>

              {/* Social Login */}
              <motion.div
                initial={{ opacity: 0, y: 15 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.75 }}
                className="flex gap-3"
              >
                <SocialButton icon={<GoogleIcon />} label="Google" />
                <SocialButton icon={<AppleIcon />} label="Apple" />
              </motion.div>

              {/* Sign Up Link */}
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.8 }}
                className="flex-1 flex items-end justify-center pb-8 pt-6"
                style={{ paddingBottom: "max(env(safe-area-inset-bottom, 24px), 32px)" }}
              >
                <p style={{ color: C.creamDim, fontSize: 13 }}>
                  {t("Don't have an account? ", "ليس لديك حساب؟ ")}
                  <button onClick={() => setScreen("signup")} style={{ color: C.gold }}>
                    {t("Sign Up", "إنشاء حساب")}
                  </button>
                </p>
              </motion.div>
            </motion.div>
          ) : (
            <motion.div
              key="signup"
              initial={{ opacity: 0, x: 30 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: -30 }}
              transition={{ duration: 0.3 }}
              className="flex-1 flex flex-col px-6"
            >
              {/* Logo smaller */}
              <div className="flex justify-center mt-2 mb-5">
                <motion.div
                  initial={{ scale: 0.8 }}
                  animate={{ scale: 1 }}
                  className="relative flex items-center justify-center"
                  style={{
                    width: 70,
                    height: 70,
                    borderRadius: "50%",
                    border: `1.5px solid ${C.gold}`,
                    boxShadow: `0 0 40px rgba(212,175,55,0.15)`,
                    background: `radial-gradient(circle at 30% 30%, rgba(212,175,55,0.06), transparent 60%)`,
                  }}
                >
                  <GoldShimmer />
                  <Dumbbell size={28} color={C.gold} />
                  <div className="absolute -top-2.5">
                    <Crown size={16} color={C.gold} />
                  </div>
                </motion.div>
              </div>

              {/* Title */}
              <motion.div
                initial={{ opacity: 0, y: -10 }}
                animate={{ opacity: 1, y: 0 }}
                className="mb-5"
              >
                <h2 style={{ color: C.cream, fontSize: 24 }}>
                  {t("Create Account", "إنشاء حساب")}
                </h2>
                <p className="mt-1" style={{ color: C.creamDim, fontSize: 13 }}>
                  {t("Join the royal fitness family", "انضم لعائلة اللياقة الملكية")}
                </p>
              </motion.div>

              {/* Fields */}
              <div className="flex flex-col gap-3 mb-5">
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }}>
                  <InputField
                    icon={User}
                    placeholder={t("Full Name", "الاسم الكامل")}
                    value={name}
                    onChange={setName}
                  />
                </motion.div>
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}>
                  <InputField
                    icon={Mail}
                    placeholder={t("Email Address", "البريد الإلكتروني")}
                    value={email}
                    onChange={setEmail}
                  />
                </motion.div>
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
                  <InputField
                    icon={Lock}
                    placeholder={t("Password", "كلمة المرور")}
                    type="password"
                    value={password}
                    onChange={setPassword}
                  />
                </motion.div>

                {/* Goal Selector */}
                <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 }}>
                  <button
                    onClick={() => setGoalOpen(!goalOpen)}
                    className="flex items-center gap-3 px-4 w-full transition-all duration-300"
                    style={{
                      height: 56,
                      ...inputStyle,
                      ...(goalOpen ? inputFocusStyle : {}),
                    }}
                  >
                    <Target size={18} color={goal ? C.gold : C.creamDim} className="flex-shrink-0" />
                    <span className="flex-1 text-left" style={{ color: goal ? C.cream : C.creamDim, fontSize: 14 }}>
                      {goal || t("Select Your Goal", "اختر هدفك")}
                    </span>
                    <motion.div animate={{ rotate: goalOpen ? 180 : 0 }} transition={{ duration: 0.2 }}>
                      <ChevronDown size={18} color={C.creamDim} />
                    </motion.div>
                  </button>

                  <AnimatePresence>
                    {goalOpen && (
                      <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: "auto" }}
                        exit={{ opacity: 0, height: 0 }}
                        transition={{ duration: 0.2 }}
                        className="overflow-hidden mt-1.5 rounded-2xl"
                        style={{
                          border: `1px solid ${C.glassBorder}`,
                          background: `linear-gradient(135deg, rgba(1,50,32,0.7), rgba(13,17,23,0.7))`,
                          backdropFilter: "blur(20px)",
                        }}
                      >
                        {goals.map((g, i) => (
                          <button
                            key={i}
                            onClick={() => { setGoal(t(g.en, g.ar)); setGoalOpen(false); }}
                            className="flex items-center gap-3 px-4 py-3.5 w-full transition-all duration-200 hover:bg-white/5"
                            style={{
                              borderBottom: i < goals.length - 1 ? `1px solid rgba(212,175,55,0.08)` : "none",
                              color: t(g.en, g.ar) === goal ? C.gold : C.cream,
                              fontSize: 14,
                            }}
                          >
                            <div
                              className="flex items-center justify-center rounded-lg"
                              style={{
                                width: 28,
                                height: 28,
                                background: t(g.en, g.ar) === goal ? C.goldDim : "rgba(255,255,255,0.05)",
                                border: `1px solid ${t(g.en, g.ar) === goal ? C.goldBorder : "transparent"}`,
                              }}
                            >
                              {["🔥", "💪", "⚡", "🧘"][i]}
                            </div>
                            {t(g.en, g.ar)}
                          </button>
                        ))}
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              </div>

              {/* Terms */}
              <motion.p
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ delay: 0.3 }}
                className="mb-5 text-center"
                style={{ color: C.creamDim, fontSize: 11, lineHeight: 1.6 }}
              >
                {t(
                  "By signing up, you agree to our ",
                  "بالتسجيل، أنت توافق على "
                )}
                <span style={{ color: C.gold }}>{t("Terms", "الشروط")}</span>
                {t(" & ", " و ")}
                <span style={{ color: C.gold }}>{t("Privacy Policy", "سياسة الخصوصية")}</span>
              </motion.p>

              {/* Create Account Button */}
              <motion.div initial={{ opacity: 0, y: 15 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.35 }}>
                <GoldButton onClick={onComplete}>
                  {t("Create Account", "إنشاء حساب")}
                  <ChevronRight size={18} className="relative z-10" />
                </GoldButton>
              </motion.div>

              {/* Divider */}
              <div className="flex items-center gap-4 my-5">
                <div className="flex-1" style={{ height: 1, background: C.glassBorder }} />
                <span style={{ color: C.creamDim, fontSize: 11, letterSpacing: 1 }}>
                  {t("OR", "أو")}
                </span>
                <div className="flex-1" style={{ height: 1, background: C.glassBorder }} />
              </div>

              {/* Social */}
              <div className="flex gap-3">
                <SocialButton icon={<GoogleIcon />} label="Google" />
                <SocialButton icon={<AppleIcon />} label="Apple" />
              </div>

              {/* Sign In Link */}
              <div
                className="flex-1 flex items-end justify-center pb-8 pt-6"
                style={{ paddingBottom: "max(env(safe-area-inset-bottom, 24px), 32px)" }}
              >
                <p style={{ color: C.creamDim, fontSize: 13 }}>
                  {t("Already have an account? ", "لديك حساب بالفعل؟ ")}
                  <button onClick={() => setScreen("login")} style={{ color: C.gold }}>
                    {t("Sign In", "تسجيل الدخول")}
                  </button>
                </p>
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}
