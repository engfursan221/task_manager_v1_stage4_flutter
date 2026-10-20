import React from 'react';
import { Home, CheckSquare, Archive, Settings } from 'lucide-react';

interface AppBottomNavBarProps {
  currentRoute: string;
  onNavigate: (route: string) => void;
}

export const AppBottomNavBar: React.FC<AppBottomNavBarProps> = ({ currentRoute, onNavigate }) => {
  const tabs = [
    { label: 'الرئيسية', route: '/home', icon: Home },
    { label: 'المهام', route: '/tasks', icon: CheckSquare },
    { label: 'الأرشيف', route: '/archive', icon: Archive },
    { label: 'الإعدادات', route: '/settings', icon: Settings },
  ];

  return (
    <nav className="fixed bottom-0 left-0 right-0 z-30 bg-white/95 dark:bg-[#0f172a]/95 backdrop-blur-md border-t border-slate-200 dark:border-slate-800 transition-colors">
      <div className="max-w-md mx-auto px-4 h-16 flex items-center justify-around">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = currentRoute === tab.route;

          return (
            <button
              key={tab.route}
              onClick={() => onNavigate(tab.route)}
              className={`flex flex-col items-center justify-center flex-1 py-1 transition-colors relative ${
                isActive
                  ? 'text-blue-600 dark:text-blue-400 font-bold'
                  : 'text-slate-500 dark:text-slate-400 hover:text-slate-700 dark:hover:text-slate-200'
              }`}
            >
              <div
                className={`p-1 rounded-xl transition-transform ${
                  isActive ? 'scale-110 bg-blue-50 dark:bg-blue-950/50' : ''
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
