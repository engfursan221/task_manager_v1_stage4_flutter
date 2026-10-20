import React from 'react';
import { TaskModel } from '../types';
import { Check, Edit2, Archive, RotateCcw, Calendar } from 'lucide-react';

interface TaskCardProps {
  task: TaskModel;
  isArchived?: boolean;
  onToggleCompleted?: (id: string) => void;
  onEdit?: (task: TaskModel) => void;
  onDelete?: (task: TaskModel) => void;
  onRestore?: (id: string) => void;
}

export const TaskCard: React.FC<TaskCardProps> = ({
  task,
  isArchived = false,
  onToggleCompleted,
  onEdit,
  onDelete,
  onRestore,
}) => {
  const formattedDate = new Date(task.createdAt).toLocaleDateString('ar-EG', {
    month: 'short',
    day: 'numeric',
    year: 'numeric',
  });

  return (
    <div
      className={`p-4 rounded-2xl border transition-all ${
        task.isCompleted && !isArchived
          ? 'bg-slate-50/80 dark:bg-slate-900/40 border-slate-200 dark:border-slate-800/80 opacity-85'
          : 'bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800 shadow-xs hover:border-slate-300 dark:hover:border-slate-700'
      }`}
    >
      <div className="flex items-start gap-3">
        {/* Toggle checkbox (only for active tasks) */}
        {!isArchived ? (
          <button
            onClick={() => onToggleCompleted?.(task.id)}
            className={`mt-1 w-6 h-6 rounded-lg border flex items-center justify-center transition-all ${
              task.isCompleted
                ? 'bg-emerald-600 border-emerald-600 text-white'
                : 'border-slate-300 dark:border-slate-600 hover:border-blue-500 dark:hover:border-blue-400 bg-white dark:bg-slate-800'
            }`}
            title={task.isCompleted ? 'إلغاء الإكمال' : 'تحديد كمكتملة'}
            aria-label="Toggle Complete"
          >
            {task.isCompleted && <Check className="w-4 h-4 stroke-[3]" />}
          </button>
        ) : (
          <div className="mt-1 w-6 h-6 rounded-lg bg-purple-100 dark:bg-purple-950/60 border border-purple-200 dark:border-purple-800 flex items-center justify-center text-purple-600 dark:text-purple-400">
            <Archive className="w-3.5 h-3.5" />
          </div>
        )}

        {/* Content */}
        <div className="flex-1 min-w-0">
          <div className="flex items-center justify-between gap-2">
            <h3
              className={`text-base font-bold truncate ${
                task.isCompleted && !isArchived
                  ? 'line-through text-slate-400 dark:text-slate-500'
                  : 'text-slate-900 dark:text-white'
              }`}
            >
              {task.title}
            </h3>

            {/* Badges */}
            {isArchived ? (
              <span className="shrink-0 px-2 py-0.5 rounded-md text-[11px] font-semibold bg-purple-100 dark:bg-purple-950/60 text-purple-700 dark:text-purple-300">
                مؤرشفة
              </span>
            ) : task.isCompleted ? (
              <span className="shrink-0 px-2 py-0.5 rounded-md text-[11px] font-semibold bg-emerald-100 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-300">
                مكتملة
              </span>
            ) : (
              <span className="shrink-0 px-2 py-0.5 rounded-md text-[11px] font-semibold bg-amber-100 dark:bg-amber-950/60 text-amber-700 dark:text-amber-300">
                معلقة
              </span>
            )}
          </div>

          {task.description && (
            <p
              className={`text-sm mt-1 line-clamp-2 leading-relaxed ${
                task.isCompleted && !isArchived
                  ? 'text-slate-400 dark:text-slate-500'
                  : 'text-slate-600 dark:text-slate-300'
              }`}
            >
              {task.description}
            </p>
          )}

          {/* Footer info & Actions */}
          <div className="flex items-center justify-between mt-3 pt-2.5 border-t border-slate-100 dark:border-slate-800/80 text-xs text-slate-400 dark:text-slate-500">
            <div className="flex items-center gap-1.5">
              <Calendar className="w-3.5 h-3.5" />
              <span>{formattedDate}</span>
            </div>

            <div className="flex items-center gap-1">
              {!isArchived ? (
                <>
                  <button
                    onClick={() => onEdit?.(task)}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                    title="تعديل المهمة"
                  >
                    <Edit2 className="w-4 h-4" />
                  </button>
                  <button
                    onClick={() => onDelete?.(task)}
                    className="p-1.5 rounded-lg text-slate-500 hover:text-purple-600 dark:hover:text-purple-400 hover:bg-purple-50 dark:hover:bg-purple-950/30 transition-colors"
                    title="أرشفة المهمة"
                  >
                    <Archive className="w-4 h-4" />
                  </button>
                </>
              ) : (
                <button
                  onClick={() => onRestore?.(task.id)}
                  className="flex items-center gap-1 px-2.5 py-1 rounded-lg text-xs font-bold text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-950/40 hover:bg-emerald-100 dark:hover:bg-emerald-900/40 transition-colors border border-emerald-200 dark:border-emerald-800"
                  title="استعادة إلى المهام النشطة"
                >
                  <RotateCcw className="w-3.5 h-3.5" />
                  <span>استعادة</span>
                </button>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
