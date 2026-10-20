import React, { useState } from 'react';
import { useUniversity, formatDate } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import { LectureModel, UniversityTaskModel, getCategoryDisplayName } from '../types';
import {
  CalendarRange,
  ChevronRight,
  ChevronLeft,
  Calendar,
  BookOpen,
  CheckCircle2,
  Circle,
} from 'lucide-react';

interface WeeklyTasksScreenProps {
  onNavigate: (route: string) => void;
}

export const WeeklyTasksScreen: React.FC<WeeklyTasksScreenProps> = ({ onNavigate }) => {
  const { getLecturesRecordedInDates, updateTaskStatus } = useUniversity();
  const [weekOffset, setWeekOffset] = useState<number>(0);

  // Generate 7 days for the selected week
  const getWeekDates = () => {
    const now = new Date();
    // Offset by weeks
    const base = new Date(now.getTime() + weekOffset * 7 * 24 * 60 * 60 * 1000);
    const dayOfWeek = base.getDay(); // 0 is Sunday, 6 is Saturday
    // Normalizing so week runs Saturday to Friday or Sunday to Saturday
    const startOfWeek = new Date(base.getTime() - dayOfWeek * 24 * 60 * 60 * 1000);

    const dates: Date[] = [];
    for (let i = 0; i < 7; i++) {
      dates.push(new Date(startOfWeek.getTime() + i * 24 * 60 * 60 * 1000));
    }
    return dates;
  };

  const weekDates = getWeekDates();
  const weekDateStrings = new Set(weekDates.map((d) => formatDate(d)));
  const recordedLectures = getLecturesRecordedInDates(weekDateStrings);

  const startDateStr = formatDate(weekDates[0]);
  const endDateStr = formatDate(weekDates[weekDates.length - 1]);

  const getDayNameArabic = (date: Date) => {
    const days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
    return days[date.getDay()];
  };

  const handleCycleStatus = (lecture: LectureModel, task: UniversityTaskModel) => {
    const nextStatus =
      task.status === 'notStarted'
        ? 'inProgress'
        : task.status === 'inProgress'
        ? 'completed'
        : 'notStarted';

    updateTaskStatus(lecture.courseId, lecture.id, task.id, nextStatus);
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar title="مهام الأسبوع" onNavigate={onNavigate} currentMode="university" />

      {/* Week Navigator Bar */}
      <div className="bg-white dark:bg-[#1E293B] border-b border-slate-200 dark:border-slate-800 p-3 shadow-xs sticky top-16 z-20">
        <div className="max-w-2xl mx-auto flex items-center justify-between">
          <button
            onClick={() => setWeekOffset((prev) => prev - 1)}
            className="p-1.5 rounded-xl text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
            title="الأسبوع السابق"
          >
            <ChevronRight className="w-5 h-5" />
          </button>

          <div className="text-center">
            <h3 className="text-xs font-bold text-slate-900 dark:text-white">
              {weekOffset === 0
                ? 'الأسبوع الحالي'
                : weekOffset < 0
                ? `منذ ${-weekOffset} أسبوع`
                : `بعد ${weekOffset} أسبوع`}
            </h3>
            <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">
              {startDateStr} إلى {endDateStr}
            </p>
          </div>

          <button
            onClick={() => setWeekOffset((prev) => prev + 1)}
            className="p-1.5 rounded-xl text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
            title="الأسبوع التالي"
          >
            <ChevronLeft className="w-5 h-5" />
          </button>
        </div>
      </div>

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-4">
        {recordedLectures.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center">
            <div className="w-20 h-20 rounded-full bg-purple-100 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 flex items-center justify-center mb-4 border border-purple-200 dark:border-purple-800">
              <CalendarRange className="w-10 h-10" />
            </div>
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-1">
              لا توجد محاضرات مسجلة خلال هذا الأسبوع
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-sm leading-relaxed">
              تسجيل حضورك أو غيابك للمحاضرات في الأيام الدراسية سيقوم بإظهار مهامها هنا تلقائياً.
            </p>
          </div>
        ) : (
          <div className="space-y-4">
            {weekDates.map((date) => {
              const dateStr = formatDate(date);
              const lecturesForDay = recordedLectures.filter((l) => l.lectureDate === dateStr);

              if (lecturesForDay.length === 0) return null;

              // Group by course
              const byCourse: { [courseName: string]: LectureModel[] } = {};
              for (const l of lecturesForDay) {
                if (!byCourse[l.courseName]) byCourse[l.courseName] = [];
                byCourse[l.courseName].push(l);
              }

              return (
                <div
                  key={dateStr}
                  className="rounded-2xl border border-slate-200 dark:border-slate-800 bg-white dark:bg-[#1E293B] shadow-xs overflow-hidden"
                >
                  {/* Day Header */}
                  <div className="bg-slate-100/80 dark:bg-slate-800/80 px-4 py-2.5 flex items-center justify-between border-b border-slate-200 dark:border-slate-800">
                    <div className="flex items-center gap-2">
                      <Calendar className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                      <span className="text-xs font-bold text-slate-900 dark:text-white">
                        {getDayNameArabic(date)} • {dateStr}
                      </span>
                    </div>
                    <span className="text-[11px] font-bold text-blue-600 dark:text-blue-400">
                      {lecturesForDay.length} محاضرة
                    </span>
                  </div>

                  {/* Course -> Lecture -> Tasks */}
                  <div className="p-4 space-y-4">
                    {Object.entries(byCourse).map(([courseName, courseLectures]) => (
                      <div key={courseName} className="space-y-2.5">
                        <div className="flex items-center gap-2 text-xs font-bold text-blue-600 dark:text-blue-400">
                          <BookOpen className="w-4 h-4" />
                          <span>{courseName}</span>
                        </div>

                        {courseLectures.map((lecture) => (
                          <div
                            key={lecture.id}
                            className="mr-3 p-3 rounded-xl bg-slate-50 dark:bg-slate-900/50 border border-slate-200 dark:border-slate-800/80 space-y-2"
                          >
                            <div className="flex items-center justify-between">
                              <span className="text-xs font-bold text-slate-900 dark:text-white">
                                {lecture.title} ({lecture.section === 'theoretical' ? 'نظري' : 'عملي'})
                              </span>
                              <span
                                className={`px-2 py-0.5 rounded-md text-[10px] font-bold ${
                                  lecture.attendanceStatus === 'present'
                                    ? 'bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300'
                                    : 'bg-red-100 dark:bg-red-950/80 text-red-700 dark:text-red-300'
                                }`}
                              >
                                {lecture.attendanceStatus === 'present' ? 'حاضر' : 'غائب'}
                              </span>
                            </div>

                            {/* Tasks list */}
                            {lecture.tasks.length === 0 ? (
                              <p className="text-[11px] text-slate-400">لا توجد مهام محددة</p>
                            ) : (
                              <div className="space-y-1.5 pt-1">
                                {lecture.tasks.map((task) => (
                                  <div
                                    key={task.id}
                                    className="flex items-center gap-2 text-xs"
                                  >
                                    <button
                                      onClick={() => handleCycleStatus(lecture, task)}
                                      className="shrink-0"
                                    >
                                      {task.status === 'completed' ? (
                                        <CheckCircle2 className="w-4 h-4 text-emerald-600" />
                                      ) : (
                                        <Circle className="w-4 h-4 text-slate-400" />
                                      )}
                                    </button>
                                    <span className="px-1.5 py-0.5 rounded text-[9px] font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400">
                                      {getCategoryDisplayName(task.category)}
                                    </span>
                                    <span
                                      className={`truncate ${
                                        task.status === 'completed'
                                          ? 'line-through text-slate-400 dark:text-slate-500'
                                          : 'text-slate-700 dark:text-slate-300'
                                      }`}
                                    >
                                      {task.title}
                                    </span>
                                  </div>
                                ))}
                              </div>
                            )}
                          </div>
                        ))}
                      </div>
                    ))}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      <UniversityBottomNavBar currentRoute="/university/week" onNavigate={onNavigate} />
    </div>
  );
};
