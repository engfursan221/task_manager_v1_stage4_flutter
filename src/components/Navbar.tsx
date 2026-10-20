import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { useAuth } from '../context/AuthContext';
import { useUniversity } from '../context/UniversityContext';
import { Sun, Moon, LogOut, ArrowRightLeft, School, CheckSquare } from 'lucide-react';

interface NavbarProps {
  title: string;
  onNavigate: (route: string) => void;
  showBack?: boolean;
  onBack?: () => void;
  currentMode?: 'normal' | 'university';
}

export const Navbar: React.FC<NavbarProps> = ({
  title,
  onNavigate,
  showBack = false,
  onBack,
  currentMode,
}) => {
  const { isDarkMode, toggleTheme } = useTheme();
  const { logout } = useAuth();
  const { activeMode, setActiveMode } = useUniversity();

  const [showLogoutConfirm, setShowLogoutConfirm] = React.useState(false);

  const effectiveMode = currentMode || activeMode;

  const handleToggleMode = () => {
    if (effectiveMode === 'normal') {
      setActiveMode('university');
      onNavigate('/university');
    } else {
      setActiveMode('normal');
      onNavigate('/home');
    }
  };

  return (
    <>
      <header className="sticky top-0 z-30 bg-white/90 dark:bg-[#0f172a]/90 backdrop-blur-md border-b border-slate-200 dark:border-slate-800 transition-colors">
        <div className="max-w-4xl mx-auto px-4 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3">
            {showBack && (
              <button
                onClick={onBack || (() => window.history.back())}
                className="p-2 rounded-xl text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                title="رجوع"
              >
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  width="20"
                  height="20"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                >
                  <path d="m9 18 6-6-6-6" />
                </svg>
              </button>
            )}
            <h1 className="text-lg font-bold text-slate-900 dark:text-white truncate">
              {title}
            </h1>
          </div>

          <div className="flex items-center gap-1 sm:gap-2">
            {/* Mode Switcher Button */}
            <button
              onClick={handleToggleMode}
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs sm:text-sm font-semibold bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/50 transition-colors border border-blue-200 dark:border-blue-800/60"
              title="تبديل وضع المهام"
            >
              {effectiveMode === 'normal' ? (
                <>
                  <School className="w-4 h-4 text-emerald-600 dark:text-emerald-400" />
                  <span className="hidden sm:inline">المهام الجامعية</span>
                  <span className="sm:hidden">جامعي</span>
                </>
              ) : (
                <>
                  <CheckSquare className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                  <span className="hidden sm:inline">المهام العادية</span>
                  <span className="sm:hidden">عادي</span>
                </>
              )}
            </button>

            {/* Dark / Light Toggle */}
            <button
              onClick={toggleTheme}
              className="p-2 rounded-xl text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              title={isDarkMode ? 'التبديل إلى الوضع الفاتح' : 'التبديل إلى الوضع الداكن'}
              aria-label="Toggle Theme"
            >
              {isDarkMode ? <Sun className="w-5 h-5 text-amber-400" /> : <Moon className="w-5 h-5" />}
            </button>

            {/* Logout Button */}
            <button
              onClick={() => setShowLogoutConfirm(true)}
              className="p-2 rounded-xl text-slate-600 dark:text-slate-300 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/30 transition-colors"
              title="تسجيل الخروج"
              aria-label="Logout"
            >
              <LogOut className="w-5 h-5" />
            </button>
          </div>
        </div>
      </header>

      {/* Logout Dialog */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-700 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">
              تسجيل الخروج
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-300 mb-6 leading-relaxed">
              هل أنت متأكد من رغبتك في تسجيل الخروج؟ سيتم مسح جلسة الدخول الحالية والعودة لشاشة الدخول.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setShowLogoutConfirm(false)}
                className="px-4 py-2 rounded-xl text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={() => {
                  setShowLogoutConfirm(false);
                  logout();
                  onNavigate('/login');
                }}
                className="px-4 py-2 rounded-xl text-sm font-bold bg-red-600 text-white hover:bg-red-700 transition-colors shadow-xs"
              >
                تسجيل الخروج
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};
