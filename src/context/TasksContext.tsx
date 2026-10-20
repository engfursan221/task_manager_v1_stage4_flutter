import React, { createContext, useContext, useEffect, useState } from 'react';
import { TaskModel } from '../types';

interface TasksContextType {
  activeTasks: TaskModel[];
  archivedTasks: TaskModel[];
  createTask: (title: string, description: string) => void;
  updateTask: (id: string, title: string, description: string) => void;
  toggleTaskCompletion: (id: string) => void;
  deleteTask: (id: string) => void; // Moves to archive
  restoreTask: (id: string) => void; // Restores from archive to active
  totalTasks: number;
  completedTasks: number;
  pendingTasks: number;
  archivedCount: number;
}

const TasksContext = createContext<TasksContextType | undefined>(undefined);

const KEY_ACTIVE_TASKS = 'v1_active_tasks';
const KEY_ARCHIVED_TASKS = 'v1_archived_tasks';

const INITIAL_ACTIVE_TASKS: TaskModel[] = [
  {
    id: 'task_1',
    title: 'مراجعة إدارة الحالة والتطوير في React',
    description: 'فهم كيفية تحديث الحالة والخطافات (Hooks) وتحديث الواجهات تلقائياً.',
    isCompleted: false,
    createdAt: new Date().toISOString(),
  },
  {
    id: 'task_2',
    title: 'إعداد مشروع برمجة تطبيقات الويب',
    description: 'إكمال عمليات CRUD وإضافة ميزة الأرشفة ودعم اللغة العربية.',
    isCompleted: true,
    createdAt: new Date(Date.now() - 86400000).toISOString(),
  },
];

const INITIAL_ARCHIVED_TASKS: TaskModel[] = [
  {
    id: 'archived_1',
    title: 'تثبيت بيئة العمل وإعداد الحزم',
    description: 'إعداد ومزامنة أدوات التطوير ومكتبات الواجهة الحديثة.',
    isCompleted: true,
    createdAt: new Date(Date.now() - 172800000).toISOString(),
  },
];

export const TasksProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [activeTasks, setActiveTasks] = useState<TaskModel[]>(() => {
    const saved = localStorage.getItem(KEY_ACTIVE_TASKS);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error('Error parsing active tasks', e);
      }
    }
    return INITIAL_ACTIVE_TASKS;
  });

  const [archivedTasks, setArchivedTasks] = useState<TaskModel[]>(() => {
    const saved = localStorage.getItem(KEY_ARCHIVED_TASKS);
    if (saved) {
      try {
        return JSON.parse(saved);
      } catch (e) {
        console.error('Error parsing archived tasks', e);
      }
    }
    return INITIAL_ARCHIVED_TASKS;
  });

  useEffect(() => {
    localStorage.setItem(KEY_ACTIVE_TASKS, JSON.stringify(activeTasks));
  }, [activeTasks]);

  useEffect(() => {
    localStorage.setItem(KEY_ARCHIVED_TASKS, JSON.stringify(archivedTasks));
  }, [archivedTasks]);

  // Create
  const createTask = (title: string, description: string) => {
    const cleanTitle = title.trim();
    if (!cleanTitle) return;

    const newTask: TaskModel = {
      id: `task_${Date.now()}`,
      title: cleanTitle,
      description: description.trim(),
      isCompleted: false,
      createdAt: new Date().toISOString(),
    };

    setActiveTasks((prev) => [newTask, ...prev]);
  };

  // Update
  const updateTask = (id: string, title: string, description: string) => {
    setActiveTasks((prev) =>
      prev.map((task) =>
        task.id === id
          ? { ...task, title: title.trim(), description: description.trim() }
          : task
      )
    );
  };

  // Toggle completion
  const toggleTaskCompletion = (id: string) => {
    setActiveTasks((prev) =>
      prev.map((task) =>
        task.id === id ? { ...task, isCompleted: !task.isCompleted } : task
      )
    );
  };

  // Delete -> Archive
  const deleteTask = (id: string) => {
    const taskToArchive = activeTasks.find((t) => t.id === id);
    if (!taskToArchive) return;

    setActiveTasks((prev) => prev.filter((t) => t.id !== id));
    setArchivedTasks((prev) => [taskToArchive, ...prev]);
  };

  // Restore from Archive
  const restoreTask = (id: string) => {
    const taskToRestore = archivedTasks.find((t) => t.id === id);
    if (!taskToRestore) return;

    setArchivedTasks((prev) => prev.filter((t) => t.id !== id));
    setActiveTasks((prev) => [taskToRestore, ...prev]);
  };

  const totalTasks = activeTasks.length;
  const completedTasks = activeTasks.filter((t) => t.isCompleted).length;
  const pendingTasks = totalTasks - completedTasks;
  const archivedCount = archivedTasks.length;

  return (
    <TasksContext.Provider
      value={{
        activeTasks,
        archivedTasks,
        createTask,
        updateTask,
        toggleTaskCompletion,
        deleteTask,
        restoreTask,
        totalTasks,
        completedTasks,
        pendingTasks,
        archivedCount,
      }}
    >
      {children}
    </TasksContext.Provider>
  );
};

export const useTasks = () => {
  const context = useContext(TasksContext);
  if (!context) {
    throw new Error('useTasks must be used within a TasksProvider');
  }
  return context;
};
