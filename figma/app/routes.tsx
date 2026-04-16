import { createBrowserRouter, Outlet } from "react-router";
import { BottomNav } from "./components/bottom-nav";
import { HomeScreen } from "./components/home-screen";
import { WorkoutLibrary } from "./components/workout-library";
import { ActiveExercise } from "./components/active-exercise";
import { ProgressTracker } from "./components/progress-tracker";
import { ChallengesScreen } from "./components/challenges-screen";
import { SettingsScreen } from "./components/settings-screen";

function Layout() {
  return (
    <div className="max-w-md mx-auto relative min-h-screen" style={{ boxShadow: "0 0 80px rgba(0,0,0,0.6)" }}>
      <Outlet />
      <BottomNav />
    </div>
  );
}

function ExerciseLayout() {
  return (
    <div className="max-w-md mx-auto relative min-h-screen" style={{ boxShadow: "0 0 80px rgba(0,0,0,0.6)" }}>
      <ActiveExercise />
    </div>
  );
}

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Layout,
    children: [
      { index: true, Component: HomeScreen },
      { path: "workouts", Component: WorkoutLibrary },
      { path: "challenges", Component: ChallengesScreen },
      { path: "progress", Component: ProgressTracker },
      { path: "settings", Component: SettingsScreen },
    ],
  },
  { path: "/exercise", Component: ExerciseLayout },
]);
