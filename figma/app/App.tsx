import { useState } from "react";
import { RouterProvider } from "react-router";
import { router } from "./routes";
import { RoyalProvider } from "./components/royal-theme";
import { Onboarding } from "./components/onboarding";
import { AuthScreens } from "./components/auth-screens";

export default function App() {
  const [step, setStep] = useState<"onboarding" | "auth" | "app">("onboarding");

  return (
    <div style={{ background: "#001a10", minHeight: "100vh" }}>
      <RoyalProvider>
        {step === "onboarding" ? (
          <Onboarding onComplete={() => setStep("auth")} />
        ) : step === "auth" ? (
          <AuthScreens onComplete={() => setStep("app")} />
        ) : (
          <RouterProvider router={router} />
        )}
      </RoyalProvider>
    </div>
  );
}
