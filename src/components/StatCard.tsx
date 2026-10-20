import React from 'react';
import { LucideIcon } from 'lucide-react';

interface StatCardProps {
  title: string;
  count: number | string;
  icon: LucideIcon;
  color: string;
  onClick?: () => void;
  subtitle?: string;
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  count,
  icon: Icon,
  color,
  onClick,
  subtitle,
}) => {
  return (
    <div
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      className={`p-4 rounded-2xl border transition-all ${
        onClick
          ? 'cursor-pointer hover:shadow-md hover:-translate-y-0.5 active:translate-y-0 active:scale-[0.98]'
          : ''
      } bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800 flex flex-col justify-between`}
    >
      <div className="flex items-center justify-between">
        <span className="text-xs font-semibold text-slate-600 dark:text-slate-400">
          {title}
        </span>
        <div
          className="p-2.5 rounded-xl flex items-center justify-center"
          style={{ backgroundColor: `${color}18`, color }}
        >
          <Icon className="w-5 h-5" />
        </div>
      </div>

      <div className="mt-3">
        <div className="text-2xl font-black text-slate-900 dark:text-white" style={{ color }}>
          {count}
        </div>
        {subtitle && (
          <div className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">
            {subtitle}
          </div>
        )}
      </div>
    </div>
  );
};
