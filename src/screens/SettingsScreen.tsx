import React, { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { useUniversity } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { AppBottomNavBar } from '../components/AppBottomNavBar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import {
  Sun,
  Moon,
  User,
  ShieldCheck,
  ArrowRightLeft,
  School,
  Info,
  Hash,
  Code2,
  Languages,
  LogOut,
  ChevronLeft,
  Layers,
} from 'lucide-react';

interface SettingsScreenProps {
  onNavigate: (route: string) => void;
}

export const SettingsScreen: React.FC<SettingsScreenProps> = ({ onNavigate }) => {
  const { userEmail, logout } = useAuth();
  const { isDarkMode, toggleTheme } = useTheme();
  const { activeMode } = useUniversity();

  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar title="الإعدادات" onNavigate={onNavigate} />

      <main className="max-w-2xl mx-auto px-4 py-6 space-y-6">
        {/* Section 1: Appearance & Theme */}
        <div>
          <h2 className="text-xs font-bold text-blue-600 dark:text-blue-400 mb-2 px-1">
            المظهر والسمة
          </h2>
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 p-4 shadow-xs">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div
                  className={`p-2.5 rounded-xl ${
                    isDarkMode
                      ? 'bg-blue-950/80 text-blue-400 border border-blue-800'
                      : 'bg-blue-50 text-blue-600 border border-blue-200'
                  }`}
                >
                  {isDarkMode ? <Moon className="w-5 h-5 text-amber-400" /> : <Sun className="w-5 h-5" />}
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    {isDarkMode ? 'الوضع الداكن (مفعّل)' : 'الوضع الفاتح (مفعّل)'}
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    {isDarkMode
                      ? 'استخدام ستايل ليلي مريح للعينين'
                      : 'استخدام ستايل نهاري أنيق وعالي التباين'}
                  </p>
                </div>
              </div>

              {/* Switch Toggle */}
              <button
                type="button"
                role="switch"
                aria-checked={isDarkMode}
                onClick={toggleTheme}
                className={`relative inline-flex h-6 w-11 shrink-0 cursor-pointer rounded-full border-2 border-transparent transition-colors duration-200 ease-in-out focus:outline-none ${
                  isDarkMode ? 'bg-blue-600' : 'bg-slate-300'
                }`}
              >
                <span
                  aria-hidden="true"
                  className={`pointer-events-none inline-block h-5 w-5 transform rounded-full bg-white shadow-lg ring-0 transition duration-200 ease-in-out ${
                    isDarkMode ? '-translate-x-5' : 'translate-x-0'
                  }`}
                />
              </button>
            </div>
          </div>
        </div>

        {/* Section 2: Account Details */}
        <div>
          <h2 className="text-xs font-bold text-blue-600 dark:text-blue-400 mb-2 px-1">
            معلومات الحساب
          </h2>
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 p-4 shadow-xs divide-y divide-slate-100 dark:divide-slate-800">
            <div className="flex items-center justify-between pb-3">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold">
                  <User className="w-6 h-6" />
                </div>
                <div>
                  <span className="text-[11px] font-medium text-slate-400 dark:text-slate-500">
                    المستخدم الحالي
                  </span>
                  <p className="text-sm font-bold text-slate-900 dark:text-white truncate max-w-[200px] sm:max-w-xs">
                    {userEmail}
                  </p>
                </div>
              </div>
              <span className="px-2.5 py-1 rounded-full text-xs font-bold bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800">
                متصل
              </span>
            </div>

            <div className="flex items-center justify-between pt-3">
              <div className="flex items-center gap-3 text-xs text-slate-600 dark:text-slate-300">
                <ShieldCheck className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
                <div>
                  <p className="font-bold text-slate-900 dark:text-white">حالة الحساب</p>
                  <p className="text-[11px] text-slate-400 dark:text-slate-500">تم التحقق ومحمي بكلمة مرور محلياً</p>
                </div>
              </div>
              <span className="w-2 h-2 rounded-full bg-emerald-500" />
            </div>
          </div>
        </div>

        {/* Section 3: Task System Mode */}
        <div>
          <h2 className="text-xs font-bold text-blue-600 dark:text-blue-400 mb-2 px-1">
            نظام إدارة المهام النشط
          </h2>
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-xs divide-y divide-slate-100 dark:divide-slate-800">
            <button
              onClick={() => onNavigate('/mode-selection')}
              className="w-full p-4 flex items-center justify-between text-right hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="p-2.5 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800">
                  <ArrowRightLeft className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    شاشة اختيار نوع المهام
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    الانتقال بين المهام العادية والمهام الجامعية
                  </p>
                </div>
              </div>
              <ChevronLeft className="w-4 h-4 text-slate-400" />
            </button>

            <button
              onClick={() => onNavigate('/university/plans')}
              className="w-full p-4 flex items-center justify-between text-right hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="p-2.5 rounded-xl bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800">
                  <Layers className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    إدارة الخطط الدراسية الأكاديمية
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    إنشاء الخطط للفصول الدراسية وأرشفتها وتبديل الخطة النشطة
                  </p>
                </div>
              </div>
              <ChevronLeft className="w-4 h-4 text-slate-400" />
            </button>

            <button
              onClick={() => onNavigate('/foundation')}
              className="w-full p-4 flex items-center justify-between text-right hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors"
            >
              <div className="flex items-center gap-3">
                <div className="p-2.5 rounded-xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 border border-purple-200 dark:border-purple-800">
                  <Code2 className="w-5 h-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    شاشة التحقق التأسيسية (Foundation)
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    التحقق من جاهزية المكونات والثيمات
                  </p>
                </div>
              </div>
              <ChevronLeft className="w-4 h-4 text-slate-400" />
            </button>
          </div>
        </div>

        {/* Section 4: App Information */}
        <div>
          <h2 className="text-xs font-bold text-blue-600 dark:text-blue-400 mb-2 px-1">
            عن التطبيق
          </h2>
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 p-4 shadow-xs divide-y divide-slate-100 dark:divide-slate-800">
            <div className="flex items-center justify-between py-2 text-xs">
              <div className="flex items-center gap-2.5 text-slate-600 dark:text-slate-300 font-semibold">
                <Info className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                <span>اسم التطبيق</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">
                مدير المهام الجامعية (Task Manager)
              </span>
            </div>

            <div className="flex items-center justify-between py-2 text-xs">
              <div className="flex items-center gap-2.5 text-slate-600 dark:text-slate-300 font-semibold">
                <Hash className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                <span>الإصدار</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">
                v : 2.0.0 (React)
              </span>
            </div>

            <div className="flex items-center justify-between py-2 text-xs">
              <div className="flex items-center gap-2.5 text-slate-600 dark:text-slate-300 font-semibold">
                <Code2 className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                <span>بيئة العمل</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">
                React 19 & Vite & TypeScript
              </span>
            </div>

            <div className="flex items-center justify-between py-2 text-xs">
              <div className="flex items-center gap-2.5 text-slate-600 dark:text-slate-300 font-semibold">
                <Languages className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                <span>اللغة الاساسية</span>
              </div>
              <span className="font-bold text-slate-900 dark:text-white">
                اللغة العربية (RTL)
              </span>
            </div>
          </div>
        </div>

        {/* Section 5: Logout Action */}
        <button
          onClick={() => setShowLogoutConfirm(true)}
          className="w-full py-3.5 px-4 rounded-xl border border-red-300 dark:border-red-800/80 text-red-600 dark:text-red-400 font-bold text-sm hover:bg-red-50 dark:hover:bg-red-950/30 transition-colors flex items-center justify-center gap-2"
        >
          <LogOut className="w-5 h-5" />
          <span>تسجيل الخروج من الحساب</span>
        </button>
      </main>

      {/* Logout confirmation dialog */}
      {showLogoutConfirm && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-700 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">
              تسجيل الخروج
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-300 mb-6 leading-relaxed">
              هل أنت متأكد من رغبتك في تسجيل الخروج؟ سيتم مسح جلسة الدخول والعودة لشاشة الدخول.
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

      {activeMode === 'university' ? (
        <UniversityBottomNavBar currentRoute="/settings" onNavigate={onNavigate} />
      ) : (
        <AppBottomNavBar currentRoute="/settings" onNavigate={onNavigate} />
      )}
    </div>
  );
};
