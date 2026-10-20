import React from 'react';
import { useUniversity } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import { StatCard } from '../components/StatCard';
import {
  BookOpen,
  GraduationCap,
  CheckCircle2,
  XCircle,
  CalendarDays,
  CalendarRange,
  ChevronLeft,
  Layers,
  Sparkles,
  Clock,
  Ban,
  Plus,
} from 'lucide-react';

interface UniversityDashboardScreenProps {
  onNavigate: (route: string) => void;
}

export const UniversityDashboardScreen: React.FC<UniversityDashboardScreenProps> = ({
  onNavigate,
}) => {
  const {
    plans,
    activePlan,
    activePlanId,
    setActivePlan,
    totalCourses,
    totalCreditHours,
    totalLectures,
    recordedLectures,
    totalPresent,
    totalAbsent,
    totalCancelled,
    attendanceRate,
    completedLecturesCount,
    lectureCompletionRate,
    totalTasks,
    completedTasks,
    pendingTasks,
    overallProgress,
  } = useUniversity();

  const activePlans = plans.filter((p) => p.status === 'active');
  const percent = (overallProgress * 100).toFixed(1);

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar title="لوحة التحكم الجامعية" onNavigate={onNavigate} currentMode="university" />

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-5">
        {/* Active Plan Selector Strip (التطوير الثاني: ربط إحصائيات الرئيسية بالخطة النشطة) */}
        <div className="p-3.5 sm:p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between gap-3">
          <div className="flex items-center gap-3 min-w-0">
            <div className="p-2.5 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800 shrink-0">
              <Layers className="w-5 h-5" />
            </div>
            <div className="min-w-0">
              <span className="text-[11px] font-semibold text-slate-400 dark:text-slate-500">
                الخطة الدراسية النشطة:
              </span>
              {activePlan ? (
                <div className="flex items-center gap-2 mt-0.5">
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white truncate">
                    {activePlan.name}
                  </h3>
                  {activePlan.academicYear && (
                    <span className="hidden sm:inline text-[10px] px-2 py-0.5 rounded-md bg-slate-100 dark:bg-slate-800 text-slate-500">
                      {activePlan.academicYear}
                    </span>
                  )}
                </div>
              ) : (
                <p className="text-xs font-bold text-amber-600 dark:text-amber-400">
                  لم يتم تحديد خطة نشطة
                </p>
              )}
            </div>
          </div>

          <div className="flex items-center gap-2 shrink-0">
            {activePlans.length > 1 && (
              <select
                value={activePlanId || ''}
                onChange={(e) => setActivePlan(e.target.value)}
                className="px-2.5 py-1.5 rounded-xl text-xs font-bold bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 text-slate-700 dark:text-slate-300 focus:outline-none"
              >
                {activePlans.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.name}
                  </option>
                ))}
              </select>
            )}

            <button
              onClick={() => onNavigate('/university/plans')}
              className="px-3 py-1.5 rounded-xl text-xs font-bold text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-950/60 hover:bg-blue-100 dark:hover:bg-blue-900/50 border border-blue-200 dark:border-blue-800 transition-colors"
            >
              الخطط
            </button>
          </div>
        </div>

        {/* If no plan available */}
        {!activePlan ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center bg-white dark:bg-[#1E293B] rounded-3xl border border-slate-200 dark:border-slate-800 p-8 shadow-xs">
            <Layers className="w-12 h-12 text-blue-500 mb-3" />
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-1">
              لا توجد خطة دراسية حالياً
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mb-5">
              أنشئ خطتك الدراسية الأولى لبدء إضافة المقررات ومتابعة الحضور وإنجاز المحاضرات.
            </p>
            <button
              onClick={() => onNavigate('/university/plans')}
              className="px-5 py-2.5 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-md transition-all flex items-center gap-2"
            >
              <Plus className="w-4 h-4" />
              <span>إنشاء خطة دراسية</span>
            </button>
          </div>
        ) : (
          <>
            {/* Progress Banner Card */}
            <div className="p-5 rounded-3xl bg-gradient-to-br from-emerald-50 to-teal-50/50 dark:from-emerald-950/40 dark:to-slate-800/80 border border-emerald-200/80 dark:border-emerald-900/40 shadow-xs">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <h2 className="text-sm sm:text-base font-bold text-slate-900 dark:text-white">
                    نسبة التقدم الأكاديمي للخطة
                  </h2>
                  <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">
                    إنجاز المحاضرات: {completedLecturesCount} محاضرة مكتملة ({lectureCompletionRate}%)
                  </p>
                </div>
                <span className="px-3 py-1 rounded-full text-xs font-black bg-emerald-600 text-white shadow-xs">
                  {percent}%
                </span>
              </div>

              {/* Progress Bar */}
              <div className="w-full bg-slate-200 dark:bg-slate-700/80 h-3 rounded-full overflow-hidden mb-2.5">
                <div
                  className="bg-emerald-500 h-full rounded-full transition-all duration-500 ease-out"
                  style={{ width: `${Math.min(100, Math.max(0, overallProgress * 100))}%` }}
                />
              </div>

              <div className="flex flex-wrap items-center justify-between text-xs text-slate-600 dark:text-slate-300">
                <span>
                  تم تسجيل {recordedLectures} من {totalLectures} محاضرة
                </span>
                {totalCancelled > 0 && (
                  <span className="text-[11px] font-semibold text-red-500 dark:text-red-400">
                    ({totalCancelled} محاضرة ملغاة مستبعدة من الحسابات)
                  </span>
                )}
              </div>
            </div>

            {/* Core Statistics (Courses & Attendance) */}
            <div>
              <div className="flex items-center justify-between mb-3 px-1">
                <h2 className="text-sm font-bold text-slate-900 dark:text-white">
                  إحصائيات المقررات والحضور
                </h2>
                <span className="text-xs font-bold text-emerald-600 dark:text-emerald-400">
                  نسبة الحضور: {attendanceRate}%
                </span>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <StatCard
                  title="عدد المقررات"
                  count={totalCourses}
                  subtitle={`${totalCreditHours} ساعة معتمدة`}
                  icon={BookOpen}
                  color="#2563EB"
                  onClick={() => onNavigate('/university/courses')}
                />
                <StatCard
                  title="إجمالي المحاضرات"
                  count={totalLectures}
                  subtitle={`${completedLecturesCount} مكتملة`}
                  icon={GraduationCap}
                  color="#4F46E5"
                  onClick={() => onNavigate('/university/courses')}
                />
                <StatCard
                  title="مرات الحضور"
                  count={totalPresent}
                  subtitle="حاضر فعلياً"
                  icon={CheckCircle2}
                  color="#059669"
                  onClick={() => onNavigate('/university/today')}
                />
                <StatCard
                  title="مرات الغياب"
                  count={totalAbsent}
                  subtitle={totalCancelled > 0 ? `${totalCancelled} ملغاة` : 'غياب مسجل'}
                  icon={XCircle}
                  color="#DC2626"
                  onClick={() => onNavigate('/university/courses')}
                />
              </div>
            </div>

            {/* Tasks Summary Pills */}
            <div>
              <h2 className="text-sm font-bold text-slate-900 dark:text-white mb-2.5 px-1">
                إحصائيات مهام المحاضرات للخطة النشطة
              </h2>
              <div className="grid grid-cols-3 gap-2.5">
                <div className="p-3.5 rounded-2xl bg-blue-50/60 dark:bg-blue-950/30 border border-blue-200 dark:border-blue-900/40 text-center">
                  <div className="text-lg sm:text-xl font-black text-blue-600 dark:text-blue-400">
                    {totalTasks}
                  </div>
                  <div className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 mt-0.5">
                    إجمالي المهام
                  </div>
                </div>
                <div className="p-3.5 rounded-2xl bg-emerald-50/60 dark:bg-emerald-950/30 border border-emerald-200 dark:border-emerald-900/40 text-center">
                  <div className="text-lg sm:text-xl font-black text-emerald-600 dark:text-emerald-400">
                    {completedTasks}
                  </div>
                  <div className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 mt-0.5">
                    المهام المكتملة
                  </div>
                </div>
                <div className="p-3.5 rounded-2xl bg-amber-50/60 dark:bg-amber-950/30 border border-amber-200 dark:border-amber-900/40 text-center">
                  <div className="text-lg sm:text-xl font-black text-amber-600 dark:text-amber-400">
                    {pendingTasks}
                  </div>
                  <div className="text-[11px] font-semibold text-slate-500 dark:text-slate-400 mt-0.5">
                    المهام المعلقة
                  </div>
                </div>
              </div>
            </div>

            {/* Quick Access Cards */}
            <div className="space-y-3">
              {/* Card 1: Study Plans */}
              <div
                onClick={() => onNavigate('/university/plans')}
                role="button"
                tabIndex={0}
                className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs hover:border-blue-400 dark:hover:border-blue-600 transition-all flex items-center justify-between cursor-pointer"
              >
                <div className="flex items-center gap-3.5">
                  <div className="w-12 h-12 rounded-2xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800 flex items-center justify-center">
                    <Layers className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                      إدارة الخطط الدراسية ({plans.length})
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                      إنشاء خطط دراسية والتبديل بين الفصول والأعوام الأكاديمية
                    </p>
                  </div>
                </div>
                <ChevronLeft className="w-5 h-5 text-slate-400" />
              </div>

              {/* Card 2: Courses */}
              <div
                onClick={() => onNavigate('/university/courses')}
                role="button"
                tabIndex={0}
                className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs hover:border-emerald-400 dark:hover:border-emerald-600 transition-all flex items-center justify-between cursor-pointer"
              >
                <div className="flex items-center gap-3.5">
                  <div className="w-12 h-12 rounded-2xl bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800 flex items-center justify-center">
                    <BookOpen className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                      مقررات الخطة النشطة ({totalCourses})
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                      {totalCreditHours} ساعة معتمدة • تفاصيل النظري والعملي والتقييمات
                    </p>
                  </div>
                </div>
                <ChevronLeft className="w-5 h-5 text-slate-400" />
              </div>

              {/* Card 3: Today */}
              <div
                onClick={() => onNavigate('/university/today')}
                role="button"
                tabIndex={0}
                className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs hover:border-emerald-400 dark:hover:border-emerald-600 transition-all flex items-center justify-between cursor-pointer"
              >
                <div className="flex items-center gap-3.5">
                  <div className="w-12 h-12 rounded-2xl bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800 flex items-center justify-center">
                    <CalendarDays className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                      يومية (المحاضرات التي سجلت اليوم)
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                      عرض المهام الخاصة بالمحاضرات المسجلة لتاريخ اليوم
                    </p>
                  </div>
                </div>
                <ChevronLeft className="w-5 h-5 text-slate-400" />
              </div>

              {/* Card 4: Week */}
              <div
                onClick={() => onNavigate('/university/week')}
                role="button"
                tabIndex={0}
                className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs hover:border-purple-400 dark:hover:border-purple-600 transition-all flex items-center justify-between cursor-pointer"
              >
                <div className="flex items-center gap-3.5">
                  <div className="w-12 h-12 rounded-2xl bg-purple-50 dark:bg-purple-950/80 text-purple-600 dark:text-purple-400 border border-purple-200 dark:border-purple-800 flex items-center justify-center">
                    <CalendarRange className="w-6 h-6" />
                  </div>
                  <div>
                    <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                      أسبوعية (محاضرات الأسبوع الحالي)
                    </h3>
                    <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                      عرض منظم حسب اليوم -&gt; المقرر -&gt; المحاضرة -&gt; المهام
                    </p>
                  </div>
                </div>
                <ChevronLeft className="w-5 h-5 text-slate-400" />
              </div>
            </div>
          </>
        )}
      </main>

      <UniversityBottomNavBar currentRoute="/university" onNavigate={onNavigate} />
    </div>
  );
};
