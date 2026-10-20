import React, { useState } from 'react';
import { useTasks } from '../context/TasksContext';
import { Navbar } from '../components/Navbar';
import { AppBottomNavBar } from '../components/AppBottomNavBar';
import { TaskCard } from '../components/TaskCard';
import { Archive, PackageOpen } from 'lucide-react';

interface ArchiveScreenProps {
  onNavigate: (route: string) => void;
}

export const ArchiveScreen: React.FC<ArchiveScreenProps> = ({ onNavigate }) => {
  const { archivedTasks, restoreTask } = useTasks();
  const [toastMessage, setToastMessage] = useState<string | null>(null);

  const handleRestore = (id: string) => {
    const task = archivedTasks.find((t) => t.id === id);
    restoreTask(id);
    if (task) {
      setToastMessage(`تمت استعادة "${task.title}" إلى المهام النشطة`);
      setTimeout(() => setToastMessage(null), 3000);
    }
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors relative">
      <Navbar title="الأرشيف" onNavigate={onNavigate} currentMode="normal" />

      <main className="max-w-2xl mx-auto px-4 py-6">
        {archivedTasks.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center">
            <div className="w-20 h-20 rounded-full bg-purple-100 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center mb-4 border border-purple-200 dark:border-purple-800">
              <PackageOpen className="w-10 h-10" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-1">
              الأرشيف فارغ
            </h3>
            <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 max-w-xs leading-relaxed">
              عند حذف أي مهمة من قائمة المهام، ستظهر هنا بأمان دون فقدانها ويمكنك استعادتها لاحقاً.
            </p>
          </div>
        ) : (
          <div>
            <div className="flex items-center gap-2 mb-3 px-1 text-xs font-bold text-purple-600 dark:text-purple-400">
              <Archive className="w-4 h-4" />
              <span>المهام المحفوظة ({archivedTasks.length})</span>
            </div>

            <div className="space-y-3">
              {archivedTasks.map((task) => (
                <TaskCard
                  key={task.id}
                  task={task}
                  isArchived={true}
                  onRestore={handleRestore}
                />
              ))}
            </div>
          </div>
        )}
      </main>

      {/* Toast Notification */}
      {toastMessage && (
        <div className="fixed bottom-24 right-4 left-4 sm:left-auto sm:right-6 z-50 bg-slate-900 text-white dark:bg-white dark:text-slate-900 px-4 py-3 rounded-2xl shadow-xl text-xs font-bold animate-in fade-in slide-in-from-bottom-2 duration-200">
          {toastMessage}
        </div>
      )}

      <AppBottomNavBar currentRoute="/archive" onNavigate={onNavigate} />
    </div>
  );
};
