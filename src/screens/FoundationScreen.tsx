import React from 'react';
import { useTheme } from '../context/ThemeContext';
import { Navbar } from '../components/Navbar';
import { CheckCircle2, ShieldCheck, Sun, Moon } from 'lucide-react';

interface FoundationScreenProps {
  onNavigate: (route: string) => void;
}

export const FoundationScreen: React.FC<FoundationScreenProps> = ({ onNavigate }) => {
  const { isDarkMode, toggleTheme } = useTheme();

  return (
    <div className="min-h-screen pb-16 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar
        title="مدير المهام V1"
        onNavigate={onNavigate}
        showBack={true}
        onBack={() => onNavigate('/settings')}
      />

      <main className="max-w-md mx-auto px-4 py-8 flex flex-col items-center">
        {/* App Badge Icon */}
        <div className="w-20 h-20 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-5 border border-blue-200 dark:border-blue-800 shadow-md">
          <CheckCircle2 className="w-10 h-10" />
        </div>

        <h2 className="text-2xl font-black text-slate-900 dark:text-white">مدير المهام</h2>
        <p className="text-sm font-bold text-blue-600 dark:text-blue-400 mt-1">الإصدار 1.0 (عربي)</p>
        <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">المرحلة التأسيسية المتكاملة</p>

        {/* Foundation Status Card */}
        <div className="w-full mt-6 bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 p-5 shadow-xs">
          <div className="flex items-center gap-2 mb-3 pb-3 border-b border-slate-100 dark:border-slate-800">
            <ShieldCheck className="w-5 h-5 text-emerald-600 dark:text-emerald-400" />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">حالة المكونات الجاهزة</h3>
          </div>

          <div className="space-y-3">
            {[
              {
                title: 'إدارة الحالة باستخدام React Hooks & Context',
                desc: 'ThemeContext, AuthContext, TasksContext, UniversityContext',
              },
              {
                title: 'ثيمات متطورة (Tailwind & Material Design)',
                desc: 'الوضع الفاتح والداكن مهيأ بالكامل ومطابق للنسخة الأصلية',
              },
              {
                title: 'التخزين المحلي',
                desc: 'localStorage لحفظ الجلسة والمقررات والمهام وسجلات الحضور',
              },
              {
                title: 'نموذج البيانات المتكامل',
                desc: 'TaskModel (العنوان، الوصف، حالة الإكمال) ونماذج المقررات والمحاضرات',
              },
              {
                title: 'مسارات التنقل المكتملة',
                desc: '/login, /home, /tasks, /archive, /settings, /university...',
              },
            ].map((item, idx) => (
              <div key={idx} className="flex items-start gap-2.5 text-xs">
                <span className="w-1.5 h-1.5 rounded-full bg-blue-600 dark:bg-blue-400 mt-1.5 shrink-0" />
                <div>
                  <p className="font-bold text-slate-900 dark:text-white">{item.title}</p>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">{item.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Interactive Theme Switcher Button */}
        <button
          onClick={toggleTheme}
          className="w-full mt-6 py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm shadow-md transition-all flex items-center justify-center gap-2"
        >
          {isDarkMode ? (
            <>
              <Sun className="w-4 h-4 text-amber-300" />
              <span>التبديل إلى الوضع الفاتح</span>
            </>
          ) : (
            <>
              <Moon className="w-4 h-4" />
              <span>التبديل إلى الوضع الداكن</span>
            </>
          )}
        </button>
      </main>
    </div>
  );
};
