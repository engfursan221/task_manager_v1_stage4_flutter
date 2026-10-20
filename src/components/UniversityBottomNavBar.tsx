import React from 'react';
import { LayoutDashboard, BookOpen, CalendarDays, CalendarRange, Settings } from 'lucide-react';

interface UniversityBottomNavBarProps {
  currentRoute: string;
  onNavigate: (route: string) => void;
}

export const UniversityBottomNavBar: React.FC<UniversityBottomNavBarProps> = ({
  currentRoute,
  onNavigate,
}) => {
  const tabs = [
    { label: 'الرئيسية', route: '/university', icon: LayoutDashboard },
    { label: 'المقررات', route: '/university/courses', icon: BookOpen },
    { label: 'اليوم', route: '/university/today', icon: CalendarDays },
    { label: 'الأسبوع', route: '/university/week', icon: CalendarRange },
    { label: 'الإعدادات', route: '/settings', icon: Settings },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-30 bg-white/95 dark:bg-[#0f172a]/95 backdrop-blur-md border-t border-slate-200 dark:border-slate-800 transition-colors">
      <div className="max-w-md mx-auto px-2 h-16 flex items-center justify-around">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive =
            currentRoute === tab.route ||
            (tab.route === '/university/courses' && currentRoute.startsWith('/university/courses'));

          return (
            <button
              key={tab.route}
              onClick={() => onNavigate(tab.route)}
              className={`flex flex-col items-center justify-center flex-1 py-1 transition-colors relative ${
                isActive
                  ? 'text-emerald-600 dark:text-emerald-400 font-bold'
                  : 'text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:hover:text-slate-200'
              }`}
            >
              <div
                className={`p-1 rounded-xl transition-transform ${
                  isActive ? 'scale-110 bg-emerald-50 dark:bg-emerald-950/50' : ''
                }`}
              >
                <Icon className="w-5 h-5" />
              </div>
              <span className="text-[11px] mt-0.5">{tab.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
};
