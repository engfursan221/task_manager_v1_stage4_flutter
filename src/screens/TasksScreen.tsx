import React, { useState } from 'react';
import { useTasks } from '../context/TasksContext';
import { Navbar } from '../components/Navbar';
import { AppBottomNavBar } from '../components/AppBottomNavBar';
import { TaskCard } from '../components/TaskCard';
import { TaskModel } from '../types';
import { Plus, CheckSquare, X, Archive, Sparkles } from 'lucide-react';

interface TasksScreenProps {
  onNavigate: (route: string) => void;
}

export const TasksScreen: React.FC<TasksScreenProps> = ({ onNavigate }) => {
  const { activeTasks, createTask, updateTask, toggleTaskCompletion, deleteTask } = useTasks();

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingTask, setEditingTask] = useState<TaskModel | null>(null);
  const [taskTitle, setTaskTitle] = useState('');
  const [taskDescription, setTaskDescription] = useState('');
  const [titleError, setTitleError] = useState<string | null>(null);

  // Archive confirmation dialog state
  const [taskToArchive, setTaskToArchive] = useState<TaskModel | null>(null);
  const [snackbarMessage, setSnackbarMessage] = useState<string | null>(null);

  const openCreateModal = () => {
    setEditingTask(null);
    setTaskTitle('');
    setTaskDescription('');
    setTitleError(null);
    setIsModalOpen(true);
  };

  const openEditModal = (task: TaskModel) => {
    setEditingTask(task);
    setTaskTitle(task.title);
    setTaskDescription(task.description);
    setTitleError(null);
    setIsModalOpen(true);
  };

  const closeModal = () => {
    setIsModalOpen(false);
    setEditingTask(null);
    setTaskTitle('');
    setTaskDescription('');
  };

  const handleSaveTask = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanTitle = taskTitle.trim();
    if (!cleanTitle) {
      setTitleError('يرجى إدخال عنوان المهمة');
      return;
    }

    if (editingTask) {
      updateTask(editingTask.id, cleanTitle, taskDescription);
    } else {
      createTask(cleanTitle, taskDescription);
    }
    closeModal();
  };

  const handleConfirmArchive = () => {
    if (!taskToArchive) return;
    deleteTask(taskToArchive.id);
    setTaskToArchive(null);
    setSnackbarMessage('تم نقل المهمة إلى الأرشيف بنجاح');
    setTimeout(() => setSnackbarMessage(null), 3000);
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors relative">
      <Navbar title="قائمة المهام" onNavigate={onNavigate} currentMode="normal" />

      <main className="max-w-2xl mx-auto px-4 py-6">
        {/* Empty State */}
        {activeTasks.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center">
            <div className="w-20 h-20 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-4 border border-blue-200 dark:border-blue-800">
              <CheckSquare className="w-10 h-10" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-1">
              لا توجد مهام حالياً
            </h3>
            <p className="text-xs sm:text-sm text-slate-500 dark:text-slate-400 max-w-xs mb-6">
              اضغط على زر (مهمة جديدة) لإضافة أول مهمة لك وإدارتها.
            </p>
            <button
              onClick={openCreateModal}
              className="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-sm shadow-md transition-all flex items-center gap-2"
            >
              <Plus className="w-4 h-4" />
              <span>إضافة مهمة جديدة</span>
            </button>
          </div>
        ) : (
          <div className="space-y-3">
            {activeTasks.map((task) => (
              <TaskCard
                key={task.id}
                task={task}
                onToggleCompleted={toggleTaskCompletion}
                onEdit={openEditModal}
                onDelete={(t) => setTaskToArchive(t)}
              />
            ))}
          </div>
        )}
      </main>

      {/* Floating Action Button */}
      <button
        onClick={openCreateModal}
        className="fixed bottom-20 left-6 z-40 px-5 py-3.5 rounded-2xl bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-bold text-sm shadow-xl flex items-center gap-2 transition-all"
        title="إنشاء مهمة جديدة"
      >
        <Plus className="w-5 h-5 stroke-[2.5]" />
        <span>مهمة جديدة</span>
      </button>

      {/* Add / Edit Task Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center sm:items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-lg font-bold text-slate-900 dark:text-white">
                {editingTask ? 'تعديل المهمة' : 'إنشاء مهمة جديدة'}
              </h3>
              <button
                onClick={closeModal}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveTask} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  عنوان المهمة *
                </label>
                <input
                  type="text"
                  autoFocus
                  value={taskTitle}
                  onChange={(e) => {
                    setTaskTitle(e.target.value);
                    if (titleError) setTitleError(null);
                  }}
                  placeholder="مثال: مراجعة الفصل الثالث للامتحان"
                  className={`w-full px-4 py-3 rounded-xl border text-sm bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                    titleError
                      ? 'border-red-500 focus:ring-red-500'
                      : 'border-slate-300 dark:border-slate-700'
                  }`}
                />
                {titleError && (
                  <p className="text-xs text-red-500 mt-1 font-semibold">{titleError}</p>
                )}
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  الوصف (اختياري)
                </label>
                <textarea
                  rows={3}
                  value={taskDescription}
                  onChange={(e) => setTaskDescription(e.target.value)}
                  placeholder="أضف ملاحظات أو تفاصيل حول المهمة..."
                  className="w-full px-4 py-3 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 text-sm transition-all resize-none"
                />
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={closeModal}
                  className="flex-1 py-3 px-4 rounded-xl text-sm font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="flex-1 py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-bold text-sm shadow-md transition-all"
                >
                  {editingTask ? 'حفظ التعديلات' : 'إضافة المهمة'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Archive Confirmation Dialog */}
      {taskToArchive && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-700 animate-in fade-in zoom-in-95 duration-150">
            <div className="w-12 h-12 rounded-2xl bg-purple-100 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center mb-3">
              <Archive className="w-6 h-6" />
            </div>
            <h3 className="text-lg font-bold text-slate-900 dark:text-white mb-2">
              نقل إلى الأرشيف؟
            </h3>
            <p className="text-sm text-slate-600 dark:text-slate-300 mb-6 leading-relaxed">
              سيتم نقل المهمة &quot;{taskToArchive.title}&quot; إلى شاشة الأرشيف وحفظها بأمان دون فقدانها.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setTaskToArchive(null)}
                className="px-4 py-2 rounded-xl text-sm font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleConfirmArchive}
                className="px-4 py-2 rounded-xl text-sm font-bold bg-purple-600 text-white hover:bg-purple-700 transition-colors shadow-xs"
              >
                أرشفة المهمة
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Floating Snackbar */}
      {snackbarMessage && (
        <div className="fixed bottom-24 right-4 left-4 sm:left-auto sm:right-6 z-50 bg-slate-900 text-white dark:bg-white dark:text-slate-900 px-4 py-3 rounded-2xl shadow-xl flex items-center justify-between gap-4 text-xs font-bold animate-in fade-in slide-in-from-bottom-2 duration-200">
          <span>{snackbarMessage}</span>
          <button
            onClick={() => onNavigate('/archive')}
            className="text-blue-400 dark:text-blue-600 underline font-extrabold"
          >
            عرض الأرشيف
          </button>
        </div>
      )}

      <AppBottomNavBar currentRoute="/tasks" onNavigate={onNavigate} />
    </div>
  );
};
