import React, { useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import { useUniversity } from '../context/UniversityContext';
import { CheckCircle2, Loader2 } from 'lucide-react';

interface SplashScreenProps {
  onNavigate: (route: string) => void;
}

export const SplashScreen: React.FC<SplashScreenProps> = ({ onNavigate }) => {
  const { isAuthenticated, isLoading } = useAuth();
  const { activeMode } = useUniversity();

  useEffect(() => {
    if (!isLoading) {
      if (isAuthenticated) {
        if (activeMode === 'university') {
          onNavigate('/university');
        } else {
          onNavigate('/home');
        }
      } else {
        onNavigate('/login');
      }
    }
  }, [isLoading, isAuthenticated, activeMode, onNavigate]);

  return (
    <div className="min-h-screen flex flex-col items-center justify-center p-6 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <div className="w-24 h-24 rounded-full bg-blue-100 dark:bg-blue-950/80 flex items-center justify-center text-blue-600 dark:text-blue-400 mb-6 shadow-md border border-blue-200 dark:border-blue-800">
        <CheckCircle2 className="w-12 h-12" />
      </div>

      <h1 className="text-3xl font-extrabold text-slate-900 dark:text-white tracking-tight mb-2">
        مدير المهام
      </h1>
      <p className="text-sm font-medium text-slate-600 dark:text-slate-400 text-center max-w-xs mb-8 leading-relaxed">
        نظّم مهامك الدراسية والجامعية بكل سهولة
      </p>

      <div className="flex items-center gap-2 text-blue-600 dark:text-blue-400">
        <Loader2 className="w-6 h-6 animate-spin" />
        <span className="text-xs font-semibold">جاري التهيئة...</span>
      </div>
    </div>
  );
};
