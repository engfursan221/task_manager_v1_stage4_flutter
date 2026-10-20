import React, { useState } from 'react';
import { useUniversity, getTodayString } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import {
  UniversityTaskCategory,
  UniversityTaskStatus,
  LectureModel,
  UniversityTaskModel,
  getStatusDisplayName,
} from '../types';
import {
  CalendarDays,
  Calendar,
  CheckCircle2,
  XCircle,
  Clock,
  Circle,
  BookOpen,
  Code,
  FileCheck2,
  FileText,
} from 'lucide-react';

interface TodayTasksScreenProps {
  onNavigate: (route: string) => void;
}

export const TodayTasksScreen: React.FC<TodayTasksScreenProps> = ({ onNavigate }) => {
  const { getLecturesRecordedOn, updateTaskStatus } = useUniversity();
  const [selectedDate, setSelectedDate] = useState<string>(getTodayString());

  const recordedLectures = getLecturesRecordedOn(selectedDate);
  const isToday = selectedDate === getTodayString();

  // Collect tasks with parent lecture context
  const allTasks: { lecture: LectureModel; task: UniversityTaskModel }[] = [];
  for (const lecture of recordedLectures) {
    for (const task of lecture.tasks) {
      allTasks.push({ lecture, task });
    }
  }

  // Group by category
  const studyTasks = allTasks.filter((t) => t.task.category === 'study');
  const practiceTasks = allTasks.filter((t) => t.task.category === 'practice');
  const homeworkTasks = allTasks.filter((t) => t.task.category === 'homework');
  const otherTasks = allTasks.filter(
    (t) =>
      t.task.category !== 'study' &&
      t.task.category !== 'practice' &&
      t.task.category !== 'homework'
  );

  const handleCycleStatus = (lecture: LectureModel, task: UniversityTaskModel) => {
    let nextStatus: UniversityTaskStatus = 'notStarted';
    if (task.status === 'notStarted') nextStatus = 'inProgress';
    else if (task.status === 'inProgress') nextStatus = 'completed';
    else nextStatus = 'notStarted';

    updateTaskStatus(lecture.courseId, lecture.id, task.id, nextStatus);
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar
        title={isToday ? 'مهام اليوم' : `مهام تاريخ: ${selectedDate}`}
        onNavigate={onNavigate}
        currentMode="university"
      />

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-5">
        {/* Date Selector Strip */}
        <div className="p-3.5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Calendar className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            <span className="text-xs font-bold text-slate-900 dark:text-white">
              {isToday ? 'تاريخ اليوم:' : 'التاريخ المحدد:'}
            </span>
          </div>

          <div className="flex items-center gap-2">
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="px-3 py-1.5 rounded-xl border border-slate-200 dark:border-slate-700 bg-slate-50 dark:bg-slate-900 text-xs font-bold text-slate-900 dark:text-white focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
            {!isToday && (
              <button
                onClick={() => setSelectedDate(getTodayString())}
                className="px-2.5 py-1.5 rounded-xl text-xs font-bold text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/60"
              >
                اليوم
              </button>
            )}
          </div>
        </div>

        {recordedLectures.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center">
            <div className="w-20 h-20 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-4 border border-blue-200 dark:border-blue-800">
              <CalendarDays className="w-10 h-10" />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-1">
              لا توجد محاضرات مسجلة لتاريخ {selectedDate}
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-sm mb-6 leading-relaxed">
              تظهر المهام اليومية فقط للمحاضرات التي قمت بتسجيل حضورك أو غيابك فيها لهذا اليوم.
            </p>
            <button
              onClick={() => onNavigate('/university/courses')}
              className="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-md transition-all flex items-center gap-2"
            >
              <BookOpen className="w-4 h-4" />
              <span>الانتقال إلى المقررات لتسجيل الحضور</span>
            </button>
          </div>
        ) : (
          <div className="space-y-5">
            {/* Recorded Lectures Chips */}
            <div className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs">
              <h3 className="text-xs font-bold text-slate-900 dark:text-white mb-2.5">
                المحاضرات المسجلة في هذا اليوم ({recordedLectures.length}):
              </h3>
              <div className="flex flex-wrap gap-2">
                {recordedLectures.map((l) => (
                  <button
                    key={l.id}
                    onClick={() =>
                      onNavigate(`/university/lectures/${l.courseId}/${l.id}`)
                    }
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-xl text-xs font-bold bg-slate-50 dark:bg-slate-800/80 hover:bg-slate-100 dark:hover:bg-slate-700 border border-slate-200 dark:border-slate-700 transition-colors"
                  >
                    {l.attendanceStatus === 'present' ? (
                      <CheckCircle2 className="w-3.5 h-3.5 text-emerald-600" />
                    ) : (
                      <XCircle className="w-3.5 h-3.5 text-red-600" />
                    )}
                    <span>
                      {l.courseName} - {l.title}
                    </span>
                  </button>
                ))}
              </div>
            </div>

            {/* Category 1: مذاكرة */}
            {studyTasks.length > 0 && (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-blue-600 dark:text-blue-400 text-xs font-bold px-1">
                  <BookOpen className="w-4 h-4" />
                  <span>مذاكرة ({studyTasks.length})</span>
                </div>
                {studyTasks.map(({ lecture, task }) => (
                  <TaskItem
                    key={task.id}
                    task={task}
                    lecture={lecture}
                    onCycleStatus={() => handleCycleStatus(lecture, task)}
                  />
                ))}
              </div>
            )}

            {/* Category 2: تطبيق عملي */}
            {practiceTasks.length > 0 && (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-emerald-600 dark:text-emerald-400 text-xs font-bold px-1">
                  <Code className="w-4 h-4" />
                  <span>تطبيق عملي ({practiceTasks.length})</span>
                </div>
                {practiceTasks.map(({ lecture, task }) => (
                  <TaskItem
                    key={task.id}
                    task={task}
                    lecture={lecture}
                    onCycleStatus={() => handleCycleStatus(lecture, task)}
                  />
                ))}
              </div>
            )}

            {/* Category 3: واجبات / تكاليف */}
            {homeworkTasks.length > 0 && (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-amber-600 dark:text-amber-400 text-xs font-bold px-1">
                  <FileCheck2 className="w-4 h-4" />
                  <span>واجبات ({homeworkTasks.length})</span>
                </div>
                {homeworkTasks.map(({ lecture, task }) => (
                  <TaskItem
                    key={task.id}
                    task={task}
                    lecture={lecture}
                    onCycleStatus={() => handleCycleStatus(lecture, task)}
                  />
                ))}
              </div>
            )}

            {/* Category 4: ملخصات ومراجعات */}
            {otherTasks.length > 0 && (
              <div className="space-y-2">
                <div className="flex items-center gap-2 text-purple-600 dark:text-purple-400 text-xs font-bold px-1">
                  <FileText className="w-4 h-4" />
                  <span>ملخصات ومراجعات ({otherTasks.length})</span>
                </div>
                {otherTasks.map(({ lecture, task }) => (
                  <TaskItem
                    key={task.id}
                    task={task}
                    lecture={lecture}
                    onCycleStatus={() => handleCycleStatus(lecture, task)}
                  />
                ))}
              </div>
            )}
          </div>
        )}
      </main>

      <UniversityBottomNavBar currentRoute="/university/today" onNavigate={onNavigate} />
    </div>
  );
};

const TaskItem: React.FC<{
  task: UniversityTaskModel;
  lecture: LectureModel;
  onCycleStatus: () => void;
}> = ({ task, lecture, onCycleStatus }) => {
  const isCompleted = task.status === 'completed';
  const isInProgress = task.status === 'inProgress';

  return (
    <div
      className={`p-3 rounded-2xl border transition-all flex items-center justify-between gap-3 ${
        isCompleted
          ? 'bg-slate-50/70 dark:bg-slate-900/30 border-slate-200 dark:border-slate-800/60'
          : 'bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800'
      }`}
    >
      <button
        onClick={onCycleStatus}
        className="p-1 rounded-lg text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 shrink-0"
        title="تبديل الحالة (لم تبدأ / قيد التنفيذ / مكتملة)"
      >
        {isCompleted ? (
          <CheckCircle2 className="w-5 h-5 text-emerald-600" />
        ) : isInProgress ? (
          <Clock className="w-5 h-5 text-amber-500" />
        ) : (
          <Circle className="w-5 h-5 text-slate-300 dark:text-slate-600" />
        )}
      </button>

      <div className="flex-1 min-w-0">
        <p
          className={`text-xs font-bold truncate ${
            isCompleted
              ? 'line-through text-slate-400 dark:text-slate-500'
              : 'text-slate-900 dark:text-white'
          }`}
        >
          {task.title}
        </p>
        <p className="text-[11px] text-blue-600 dark:text-blue-400 font-semibold mt-0.5">
          {lecture.courseName} • {lecture.title}
        </p>
      </div>

      <span className="px-2 py-0.5 rounded-md text-[10px] font-bold bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400 shrink-0">
        {getStatusDisplayName(task.status)}
      </span>
    </div>
  );
};
