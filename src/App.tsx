import React, { useState, useEffect } from 'react';
import { ThemeProvider } from './context/ThemeContext';
import { AuthProvider, useAuth } from './context/AuthContext';
import { TasksProvider } from './context/TasksContext';
import { UniversityProvider, useUniversity } from './context/UniversityContext';

import { SplashScreen } from './screens/SplashScreen';
import { LoginScreen } from './screens/LoginScreen';
import { ModeSelectionScreen } from './screens/ModeSelectionScreen';
import { HomeScreen } from './screens/HomeScreen';
import { TasksScreen } from './screens/TasksScreen';
import { ArchiveScreen } from './screens/ArchiveScreen';
import { SettingsScreen } from './screens/SettingsScreen';
import { FoundationScreen } from './screens/FoundationScreen';
import { PlansScreen } from './screens/PlansScreen';
import { UniversityDashboardScreen } from './screens/UniversityDashboardScreen';
import { CoursesScreen } from './screens/CoursesScreen';
import { CourseDetailsScreen } from './screens/CourseDetailsScreen';
import { LectureDetailsScreen } from './screens/LectureDetailsScreen';
import { TodayTasksScreen } from './screens/TodayTasksScreen';
import { WeeklyTasksScreen } from './screens/WeeklyTasksScreen';

function getInitialRoute(): string {
  if (typeof window === 'undefined') return '/splash';
  const path = window.location.pathname;
  if (path && path !== '/') return path;
  return '/splash';
}

const AppContent: React.FC = () => {
  const [currentRoute, setCurrentRoute] = useState<string>(getInitialRoute());
  const { isAuthenticated, isLoading } = useAuth();
  const { activeMode } = useUniversity();

  // Listen to popstate (back/forward navigation)
  useEffect(() => {
    const handlePopState = () => {
      setCurrentRoute(window.location.pathname || '/splash');
    };
    window.addEventListener('popstate', handlePopState);
    return () => window.removeEventListener('popstate', handlePopState);
  }, []);

  const navigate = (route: string) => {
    window.history.pushState({}, '', route);
    setCurrentRoute(route);
    window.scrollTo(0, 0);
  };

  // Auth Protection: If not loading and not authenticated, redirect to /login
  useEffect(() => {
    if (!isLoading && !isAuthenticated) {
      if (currentRoute !== '/login' && currentRoute !== '/splash') {
        navigate('/login');
      }
    }
  }, [isLoading, isAuthenticated, currentRoute]);

  // Route matching
  // Course details: /university/courses/:courseId
  const courseMatch = currentRoute.match(/^\/university\/courses\/([^/]+)$/);
  if (courseMatch) {
    const courseId = courseMatch[1];
    return <CourseDetailsScreen courseId={courseId} onNavigate={navigate} />;
  }

  // Lecture details: /university/lectures/:courseId/:lectureId
  const lectureMatch = currentRoute.match(/^\/university\/lectures\/([^/]+)\/([^/]+)$/);
  if (lectureMatch) {
    const courseId = lectureMatch[1];
    const lectureId = lectureMatch[2];
    return (
      <LectureDetailsScreen
        courseId={courseId}
        lectureId={lectureId}
        onNavigate={navigate}
      />
    );
  }

  switch (currentRoute) {
    case '/splash':
      return <SplashScreen onNavigate={navigate} />;
    case '/login':
      return <LoginScreen onNavigate={navigate} />;
    case '/mode-selection':
      return <ModeSelectionScreen onNavigate={navigate} />;
    case '/home':
      return <HomeScreen onNavigate={navigate} />;
    case '/tasks':
      return <TasksScreen onNavigate={navigate} />;
    case '/archive':
      return <ArchiveScreen onNavigate={navigate} />;
    case '/settings':
      return <SettingsScreen onNavigate={navigate} />;
    case '/foundation':
      return <FoundationScreen onNavigate={navigate} />;
    case '/university':
      return <UniversityDashboardScreen onNavigate={navigate} />;
    case '/university/plans':
      return <PlansScreen onNavigate={navigate} />;
    case '/university/courses':
      return <CoursesScreen onNavigate={navigate} />;
    case '/university/today':
      return <TodayTasksScreen onNavigate={navigate} />;
    case '/university/week':
      return <WeeklyTasksScreen onNavigate={navigate} />;
    default:
      // Fallback: If logged in, go to home or university dashboard based on active mode
      if (isAuthenticated) {
        return activeMode === 'university' ? (
          <UniversityDashboardScreen onNavigate={navigate} />
        ) : (
          <HomeScreen onNavigate={navigate} />
        );
      }
      return <SplashScreen onNavigate={navigate} />;
  }
};

export const App: React.FC = () => {
  return (
    <ThemeProvider>
      <AuthProvider>
        <TasksProvider>
          <UniversityProvider>
            <AppContent />
          </UniversityProvider>
        </TasksProvider>
      </AuthProvider>
    </ThemeProvider>
  );
};

export default App;
