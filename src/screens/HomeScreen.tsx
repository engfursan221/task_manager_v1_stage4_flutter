import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useTasks } from '../context/TasksContext';
import { Navbar } from '../components/Navbar';
import { AppBottomNavBar } from '../components/AppBottomNavBar';
import { StatCard } from '../components/StatCard';
import {
  User,
  CheckCircle2,
  Clock,
  Archive,
  ListTodo,
  ArrowLeft,
  ChevronLeft,
} from 'lucide-react';

interface HomeScreenProps {
  onNavigate: (route: string) => void;
}

export const HomeScreen: React.FC<HomeScreenProps> = ({ onNavigate }) => {
  const { userEmail } = useAuth();
  const { totalTasks, completedTasks, pendingTasks, archivedCount } = useTasks();

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar title="المهام العادية" onNavigate={onNavigate} currentMode="normal" />

      <main className="max-w-2xl mx-auto px-4 py-6 space-y-6">
        {/* User Profile Card */}
        <div className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold">
              <User className="w-6 h-6" />
            </div>
            <div>
              <span className="text-[11px] font-medium text-slate-400 dark:text-slate-500">
                تم تسجيل الدخول كـ
              </span>
              <p className="text-sm font-bold text-slate-900 dark:text-white truncate max-w-[200px] sm:max-w-xs">
                {userEmail}
              </p>
            </div>
          </div>
          <span className="px-3 py-1 rounded-full text-xs font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800">
            نشط
          </span>
        </div>

        {/* Real-time Dashboard Statistics */}
        <div>
          <div className="flex items-center justify-between mb-3 px-1">
            <h2 className="text-base font-bold text-slate-900 dark:text-white">
              لوحة البيانات والإحصائيات
            </h2>
            <span className="text-xs font-bold text-blue-600 dark:text-blue-400">
              إجمالي: {totalTasks + archivedCount}
            </span>
          </div>

          <div className="grid grid-cols-2 gap-3">
            <StatCard
              title="إجمالي المهام"
              count={totalTasks}
              icon={ListTodo}
              color="#2563EB"
              onClick={() => onNavigate('/tasks')}
            />
            <StatCard
              title="المهام المكتملة"
              count={completedTasks}
              icon={CheckCircle2}
              color="#059669"
              onClick={() => onNavigate('/tasks')}
            />
            <StatCard
              title="المهام المعلقة"
              count={pendingTasks}
              icon={Clock}
              color="#D97706"
              onClick={() => onNavigate('/tasks')}
            />
            <StatCard
              title="المهام المؤرشفة"
              count={archivedCount}
              icon={Archive}
              color="#7C3AED"
              onClick={() => onNavigate('/archive')}
            />
          </div>
        </div>

        {/* Quick Navigation Cards */}
        <div className="space-y-3">
          {/* Card 1: Manage Tasks */}
          <div
            onClick={() => onNavigate('/tasks')}
            role="button"
            tabIndex={0}
            className="p-4 rounded-2xl bg-blue-50/70 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-900/50 hover:bg-blue-100/60 dark:hover:bg-blue-900/40 transition-all flex items-center justify-between cursor-pointer"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-12 h-12 rounded-full bg-blue-600 text-white flex items-center justify-center shadow-xs">
                <ListTodo className="w-6 h-6" />
              </div>
              <div>
                <h3 className="text-base font-bold text-slate-900 dark:text-white">
                  إدارة المهام
                </h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                  {totalTasks} مهمة نشطة ({completedTasks} مكتملة)
                </p>
              </div>
            </div>
            <ChevronLeft className="w-5 h-5 text-blue-600 dark:text-blue-400" />
          </div>

          {/* Card 2: Archive */}
          <div
            onClick={() => onNavigate('/archive')}
            role="button"
            tabIndex={0}
            className="p-4 rounded-2xl bg-purple-50/60 dark:bg-purple-950/20 border border-purple-200 dark:border-purple-900/40 hover:bg-purple-100/60 dark:hover:bg-purple-900/30 transition-all flex items-center justify-between cursor-pointer"
          >
            <div className="flex items-center gap-3.5">
              <div className="w-12 h-12 rounded-full bg-purple-600 text-white flex items-center justify-center shadow-xs">
                <Archive className="w-6 h-6" />
              </div>
              <div>
                <h3 className="text-base font-bold text-slate-900 dark:text-white">
                  أرشيف المهام
                </h3>
                <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                  {archivedCount} مهمة في الأرشيف
                </p>
              </div>
            </div>
            <ChevronLeft className="w-5 h-5 text-purple-600 dark:text-purple-400" />
          </div>
        </div>
      </main>

      <AppBottomNavBar currentRoute="/home" onNavigate={onNavigate} />
    </div>
  );
};
