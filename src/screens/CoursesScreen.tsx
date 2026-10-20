import React, { useState } from 'react';
import { useUniversity, DEFAULT_TASK_CONFIGS } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import { CourseModel, TaskTypeConfig } from '../types';
import {
  BookOpen,
  Plus,
  MoreVertical,
  Edit2,
  Trash2,
  X,
  School,
  FlaskConical,
  Settings2,
  Layers,
  Check,
} from 'lucide-react';

interface CoursesScreenProps {
  onNavigate: (route: string) => void;
}

export const CoursesScreen: React.FC<CoursesScreenProps> = ({ onNavigate }) => {
  const { courses, activePlan, addCourse, updateCourse, deleteCourse } = useUniversity();

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [courseToEdit, setCourseToEdit] = useState<CourseModel | null>(null);

  // Form State
  const [name, setName] = useState('');
  const [instructor, setInstructor] = useState('');
  const [practicalInstructor, setPracticalInstructor] = useState('');
  const [creditHours, setCreditHours] = useState('3');
  const [hasPractical, setHasPractical] = useState(false);
  const [isAutoLectures, setIsAutoLectures] = useState(true);
  const [theoryCount, setTheoryCount] = useState('12');
  const [practicalCount, setPracticalCount] = useState('10');
  const [nameError, setNameError] = useState<string | null>(null);

  // Task configuration per course (التطوير الثالث)
  const [theoryTaskConfigs, setTheoryTaskConfigs] = useState<TaskTypeConfig[]>([
    ...DEFAULT_TASK_CONFIGS,
  ]);
  const [practicalTaskConfigs, setPracticalTaskConfigs] = useState<TaskTypeConfig[]>([
    ...DEFAULT_TASK_CONFIGS,
  ]);
  const [customTaskName, setCustomTaskName] = useState('');
  const [customTaskTarget, setCustomTaskTarget] = useState<'theory' | 'practical'>('theory');

  // Menu and delete confirmation states
  const [activeMenuCourseId, setActiveMenuCourseId] = useState<string | null>(null);
  const [courseToDelete, setCourseToDelete] = useState<CourseModel | null>(null);

  const openAddModal = () => {
    setCourseToEdit(null);
    setName('');
    setInstructor('');
    setPracticalInstructor('');
    setCreditHours('3');
    setHasPractical(false);
    setIsAutoLectures(true);
    setTheoryCount('12');
    setPracticalCount('10');
    setTheoryTaskConfigs(DEFAULT_TASK_CONFIGS.map((c) => ({ ...c })));
    setPracticalTaskConfigs(DEFAULT_TASK_CONFIGS.map((c) => ({ ...c })));
    setNameError(null);
    setIsModalOpen(true);
  };

  const openEditModal = (course: CourseModel) => {
    setCourseToEdit(course);
    setName(course.name);
    setInstructor(course.instructorName);
    setPracticalInstructor(course.practicalInstructorName || '');
    setCreditHours(course.creditHours.toString());
    setHasPractical(course.hasPractical);
    setIsAutoLectures(true);
    setTheoryTaskConfigs(
      course.theoryTaskConfigs && course.theoryTaskConfigs.length > 0
        ? course.theoryTaskConfigs.map((c) => ({ ...c }))
        : DEFAULT_TASK_CONFIGS.map((c) => ({ ...c }))
    );
    setPracticalTaskConfigs(
      course.practicalTaskConfigs && course.practicalTaskConfigs.length > 0
        ? course.practicalTaskConfigs.map((c) => ({ ...c }))
        : DEFAULT_TASK_CONFIGS.map((c) => ({ ...c }))
    );
    setNameError(null);
    setIsModalOpen(true);
  };

  const handleToggleTheoryConfig = (key: string) => {
    setTheoryTaskConfigs((prev) =>
      prev.map((c) => (c.key === key ? { ...c, enabled: !c.enabled } : c))
    );
  };

  const handleTogglePracticalConfig = (key: string) => {
    setPracticalTaskConfigs((prev) =>
      prev.map((c) => (c.key === key ? { ...c, enabled: !c.enabled } : c))
    );
  };

  const handleAddCustomTask = () => {
    const clean = customTaskName.trim();
    if (!clean) return;

    const newConfig: TaskTypeConfig = {
      key: `custom_${Date.now()}`,
      name: clean,
      enabled: true,
      isCustom: true,
    };

    if (customTaskTarget === 'theory') {
      setTheoryTaskConfigs((prev) => [...prev, newConfig]);
    } else {
      setPracticalTaskConfigs((prev) => [...prev, newConfig]);
    }
    setCustomTaskName('');
  };

  const handleDeleteCustomTask = (key: string, isPractical: boolean) => {
    if (isPractical) {
      setPracticalTaskConfigs((prev) => prev.filter((c) => c.key !== key));
    } else {
      setTheoryTaskConfigs((prev) => prev.filter((c) => c.key !== key));
    }
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanName = name.trim();
    if (!cleanName) {
      setNameError('يرجى إدخال اسم المقرر');
      return;
    }

    const hours = parseInt(creditHours) || 3;

    if (courseToEdit) {
      updateCourse(
        courseToEdit.id,
        cleanName,
        hours,
        instructor.trim(),
        hasPractical ? practicalInstructor.trim() : undefined,
        theoryTaskConfigs,
        practicalTaskConfigs
      );
    } else {
      const theory = isAutoLectures ? 12 : parseInt(theoryCount) || 12;
      const practical = hasPractical ? (isAutoLectures ? 10 : parseInt(practicalCount) || 10) : 0;

      addCourse({
        name: cleanName,
        creditHours: hours,
        instructorName: instructor.trim(),
        practicalInstructorName: hasPractical ? practicalInstructor.trim() : undefined,
        hasPractical,
        theoryLecturesCount: theory,
        practicalLecturesCount: practical,
        theoryTaskConfigs,
        practicalTaskConfigs,
        autoTasks: true,
      });
    }

    setIsModalOpen(false);
  };

  const handleConfirmDelete = () => {
    if (!courseToDelete) return;
    deleteCourse(courseToDelete.id);
    setCourseToDelete(null);
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors relative">
      <Navbar title="المقررات الدراسية" onNavigate={onNavigate} currentMode="university" />

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-4">
        {/* Active Plan Indicator Strip */}
        <div className="p-3 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between text-xs">
          <div className="flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-600 dark:text-blue-400" />
            <span className="text-slate-500">الخطة النشطة:</span>
            <span className="font-bold text-slate-900 dark:text-white">
              {activePlan ? activePlan.name : 'لا توجد خطة نشطة'}
            </span>
          </div>
          <button
            onClick={() => onNavigate('/university/plans')}
            className="font-bold text-blue-600 dark:text-blue-400 hover:underline"
          >
            تبديل الخطة
          </button>
        </div>

        {courses.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center bg-white dark:bg-[#1E293B] rounded-3xl border border-slate-200 dark:border-slate-800 p-8 shadow-xs">
            <div className="w-16 h-16 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-3">
              <School className="w-8 h-8" />
            </div>
            <h3 className="text-sm font-bold text-slate-900 dark:text-white mb-1">
              لا توجد مقررات دراسية في هذه الخطة
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mb-5">
              ابدأ بإضافة المقررات الدراسية وتحديد المهام والتقييمات الخاصة بكل مقرر.
            </p>
            <button
              onClick={openAddModal}
              className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-md transition-all flex items-center gap-1.5"
            >
              <Plus className="w-4 h-4" />
              <span>إضافة مقرر دراسي</span>
            </button>
          </div>
        ) : (
          <div className="space-y-3.5">
            {courses.map((course) => {
              const totalLectures = course.lectures.length;
              const recordedLectures = course.lectures.filter(
                (l) => l.attendanceStatus !== 'none' && l.lectureDate
              ).length;
              const progressPct = totalLectures === 0 ? 0 : Math.round((recordedLectures / totalLectures) * 100);

              const totalAssessmentScore = (course.assessments || []).reduce(
                (sum, a) => sum + (a.maxScore || 0),
                0
              );

              return (
                <div
                  key={course.id}
                  className="p-4 sm:p-5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs hover:border-blue-400 dark:hover:border-blue-600 transition-all relative"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div
                      onClick={() => onNavigate(`/university/courses/${course.id}`)}
                      className="flex-1 cursor-pointer"
                    >
                      <div className="flex items-center gap-3 mb-2">
                        <div className="p-2.5 rounded-xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800">
                          <BookOpen className="w-5 h-5" />
                        </div>
                        <div>
                          <h3 className="text-base font-bold text-slate-900 dark:text-white hover:text-blue-600 dark:hover:text-blue-400 transition-colors">
                            {course.name}
                          </h3>
                          <div className="flex flex-wrap items-center gap-3 text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                            <span>دكتور النظري: {course.instructorName || 'غير محدد'}</span>
                            {course.hasPractical && course.practicalInstructorName && (
                              <span>• دكتور العملي: {course.practicalInstructorName}</span>
                            )}
                          </div>
                        </div>
                      </div>

                      {/* Tags Row */}
                      <div className="flex flex-wrap items-center gap-2 mt-3">
                        <span className="px-2.5 py-1 rounded-lg text-[11px] font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800">
                          {course.creditHours} ساعات معتمدة
                        </span>

                        <span
                          className={`px-2.5 py-1 rounded-lg text-[11px] font-bold border ${
                            course.hasPractical
                              ? 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-300 border-emerald-200 dark:border-emerald-800'
                              : 'bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border-slate-200 dark:border-slate-700'
                          }`}
                        >
                          {course.hasPractical ? 'يحتوي على عملي/مختبر' : 'نظري فقط'}
                        </span>

                        <span className="px-2.5 py-1 rounded-lg text-[11px] font-bold bg-slate-100 dark:bg-slate-800 text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-700">
                          {totalLectures} محاضرة
                        </span>

                        {totalAssessmentScore > 0 && (
                          <span className="px-2.5 py-1 rounded-lg text-[11px] font-bold bg-amber-50 dark:bg-amber-950/60 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800">
                            درجات التقييم: {totalAssessmentScore}/100
                          </span>
                        )}
                      </div>

                      {/* Progress Bar */}
                      <div className="mt-4 pt-3 border-t border-slate-100 dark:border-slate-800">
                        <div className="flex items-center justify-between text-xs text-slate-500 dark:text-slate-400 mb-1.5">
                          <span>نسبة الحضور والتسجيل</span>
                          <span className="font-bold text-slate-700 dark:text-slate-300">
                            تم تسجيل {recordedLectures}/{totalLectures} ({progressPct}%)
                          </span>
                        </div>
                        <div className="w-full bg-slate-100 dark:bg-slate-800 h-2 rounded-full overflow-hidden">
                          <div
                            className="bg-blue-600 h-full rounded-full transition-all duration-300"
                            style={{ width: `${progressPct}%` }}
                          />
                        </div>
                      </div>
                    </div>

                    {/* Actions Menu */}
                    <div className="relative">
                      <button
                        onClick={() =>
                          setActiveMenuCourseId(activeMenuCourseId === course.id ? null : course.id)
                        }
                        className="p-1.5 rounded-xl text-slate-400 hover:text-slate-700 dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                        title="خيارات"
                      >
                        <MoreVertical className="w-5 h-5" />
                      </button>

                      {activeMenuCourseId === course.id && (
                        <div className="absolute left-0 top-8 z-20 w-36 bg-white dark:bg-[#1E293B] rounded-xl shadow-xl border border-slate-200 dark:border-slate-700 py-1 text-xs">
                          <button
                            onClick={() => {
                              setActiveMenuCourseId(null);
                              openEditModal(course);
                            }}
                            className="w-full px-3 py-2 text-right flex items-center gap-2 hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors text-slate-700 dark:text-slate-200 font-semibold"
                          >
                            <Edit2 className="w-3.5 h-3.5" />
                            <span>تعديل البيانات</span>
                          </button>
                          <button
                            onClick={() => {
                              setActiveMenuCourseId(null);
                              setCourseToDelete(course);
                            }}
                            className="w-full px-3 py-2 text-right flex items-center gap-2 hover:bg-red-50 dark:hover:bg-red-950/40 text-red-600 dark:text-red-400 transition-colors font-semibold"
                          >
                            <Trash2 className="w-3.5 h-3.5" />
                            <span>حذف المقرر</span>
                          </button>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {/* Floating Action Button */}
      <button
        onClick={openAddModal}
        className="fixed bottom-20 left-6 z-40 px-5 py-3.5 rounded-2xl bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-bold text-sm shadow-xl flex items-center gap-2 transition-all"
        title="إضافة مقرر جديد"
      >
        <Plus className="w-5 h-5 stroke-[2.5]" />
        <span>مقرر جديد</span>
      </button>

      {/* Add / Edit Course Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs overflow-y-auto">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-lg w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 my-8 max-h-[90vh] overflow-y-auto">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                {courseToEdit ? 'تعديل بيانات المقرر' : 'إضافة مقرر دراسي جديد'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* Course Name */}
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  اسم المقرر *
                </label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => {
                    setName(e.target.value);
                    if (nameError) setNameError(null);
                  }}
                  placeholder="مثال: هندسة البرمجيات"
                  className={`w-full px-4 py-2.5 rounded-xl border text-xs bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                    nameError ? 'border-red-500' : 'border-slate-300 dark:border-slate-700'
                  }`}
                />
                {nameError && <p className="text-xs text-red-500 mt-1">{nameError}</p>}
              </div>

              {/* Shared Credit Hours */}
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  عدد الساعات المعتمدة للمقرر ككل
                </label>
                <input
                  type="number"
                  min="1"
                  max="12"
                  value={creditHours}
                  onChange={(e) => setCreditHours(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              {/* Practical Toggle */}
              <div className="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs font-bold text-slate-900 dark:text-white">
                      هل يحتوي المقرر على جانب عملي/مختبر؟
                    </p>
                    <p className="text-[11px] text-slate-500 dark:text-slate-400 mt-0.5">
                      {hasPractical ? 'نعم (فصل بيانات النظري والعملي)' : 'لا (نظري فقط)'}
                    </p>
                  </div>
                  <input
                    type="checkbox"
                    checked={hasPractical}
                    onChange={(e) => setHasPractical(e.target.checked)}
                    className="w-5 h-5 rounded text-blue-600 focus:ring-blue-500 border-slate-300"
                  />
                </div>
              </div>

              {/* Instructors (التطوير السادس: فصل النظري عن العملي) */}
              <div className="space-y-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                    اسم دكتور النظري
                  </label>
                  <input
                    type="text"
                    value={instructor}
                    onChange={(e) => setInstructor(e.target.value)}
                    placeholder="مثال: د. عبدالله السعيد"
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                  />
                </div>

                {hasPractical && (
                  <div>
                    <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                      اسم دكتور / معيد العملي
                    </label>
                    <input
                      type="text"
                      value={practicalInstructor}
                      onChange={(e) => setPracticalInstructor(e.target.value)}
                      placeholder="مثال: م. فهد الأحمد"
                      className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                    />
                  </div>
                )}
              </div>

              {/* Task Configuration Settings (التطوير الثالث: المهام الأكاديمية الاختيارية والمخصصة) */}
              <div className="p-3.5 rounded-xl bg-slate-50 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800 space-y-3">
                <div className="flex items-center gap-2">
                  <Settings2 className="w-4 h-4 text-blue-600 dark:text-blue-400" />
                  <h4 className="text-xs font-bold text-slate-900 dark:text-white">
                    إعدادات المهام الأكاديمية المفعّلة لهذا المقرر
                  </h4>
                </div>

                {/* Theory Tasks */}
                <div>
                  <p className="text-[11px] font-bold text-blue-600 dark:text-blue-400 mb-1.5">
                    مهام النظري:
                  </p>
                  <div className="grid grid-cols-2 gap-2">
                    {theoryTaskConfigs.map((cfg) => (
                      <label
                        key={cfg.key}
                        className={`p-2 rounded-lg border text-xs flex items-center justify-between cursor-pointer ${
                          cfg.enabled
                            ? 'bg-blue-50 dark:bg-blue-950/60 border-blue-300 dark:border-blue-700 text-blue-800 dark:text-blue-300 font-bold'
                            : 'bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-400'
                        }`}
                      >
                        <span className="truncate">{cfg.name}</span>
                        <input
                          type="checkbox"
                          checked={cfg.enabled}
                          onChange={() => handleToggleTheoryConfig(cfg.key)}
                          className="mr-2"
                        />
                      </label>
                    ))}
                  </div>
                </div>

                {/* Practical Tasks if practical */}
                {hasPractical && (
                  <div>
                    <p className="text-[11px] font-bold text-emerald-600 dark:text-emerald-400 mb-1.5 mt-2">
                      مهام العملي:
                    </p>
                    <div className="grid grid-cols-2 gap-2">
                      {practicalTaskConfigs.map((cfg) => (
                        <label
                          key={cfg.key}
                          className={`p-2 rounded-lg border text-xs flex items-center justify-between cursor-pointer ${
                            cfg.enabled
                              ? 'bg-emerald-50 dark:bg-emerald-950/60 border-emerald-300 dark:border-emerald-700 text-emerald-800 dark:text-emerald-300 font-bold'
                              : 'bg-white dark:bg-slate-800 border-slate-200 dark:border-slate-700 text-slate-400'
                          }`}
                        >
                          <span className="truncate">{cfg.name}</span>
                          <input
                            type="checkbox"
                            checked={cfg.enabled}
                            onChange={() => handleTogglePracticalConfig(cfg.key)}
                            className="mr-2"
                          />
                        </label>
                      ))}
                    </div>
                  </div>
                )}

                {/* Add Custom Task Type */}
                <div className="pt-2 border-t border-slate-200 dark:border-slate-700 flex items-center gap-2">
                  <input
                    type="text"
                    value={customTaskName}
                    onChange={(e) => setCustomTaskName(e.target.value)}
                    placeholder="إضافة نوع مهمة مخصص..."
                    className="flex-1 px-3 py-1.5 rounded-lg border border-slate-300 dark:border-slate-700 text-xs bg-white dark:bg-slate-800"
                  />
                  {hasPractical && (
                    <select
                      value={customTaskTarget}
                      onChange={(e) => setCustomTaskTarget(e.target.value as 'theory' | 'practical')}
                      className="px-2 py-1.5 rounded-lg border border-slate-300 dark:border-slate-700 text-xs bg-white dark:bg-slate-800"
                    >
                      <option value="theory">للنظري</option>
                      <option value="practical">للعملي</option>
                    </select>
                  )}
                  <button
                    type="button"
                    onClick={handleAddCustomTask}
                    className="px-3 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs"
                  >
                    إضافة
                  </button>
                </div>
              </div>

              {/* Lecture counts (for new courses) */}
              {!courseToEdit && (
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                    عدد المحاضرات الافتراضي:
                  </label>
                  <div className="grid grid-cols-2 gap-3">
                    <button
                      type="button"
                      onClick={() => setIsAutoLectures(true)}
                      className={`p-2.5 rounded-xl border text-right transition-all text-xs ${
                        isAutoLectures
                          ? 'border-blue-600 bg-blue-50/80 dark:bg-blue-950/50 text-blue-700 dark:text-blue-300 font-bold'
                          : 'border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300'
                      }`}
                    >
                      <p className="font-bold">تلقائي (12 نظري)</p>
                      <p className="text-[10px] mt-0.5 opacity-80">
                        {hasPractical ? '+ 10 عملي' : 'نظري فقط'}
                      </p>
                    </button>

                    <button
                      type="button"
                      onClick={() => setIsAutoLectures(false)}
                      className={`p-2.5 rounded-xl border text-right transition-all text-xs ${
                        !isAutoLectures
                          ? 'border-blue-600 bg-blue-50/80 dark:bg-blue-950/50 text-blue-700 dark:text-blue-300 font-bold'
                          : 'border-slate-200 dark:border-slate-700 hover:bg-slate-50 dark:hover:bg-slate-800 text-slate-600 dark:text-slate-300'
                      }`}
                    >
                      <p className="font-bold">يدوي</p>
                      <p className="text-[10px] mt-0.5 opacity-80">تحديد العدد بنفسك</p>
                    </button>
                  </div>

                  {!isAutoLectures && (
                    <div className="grid grid-cols-2 gap-3 mt-2.5">
                      <div>
                        <label className="block text-[11px] font-semibold text-slate-600 dark:text-slate-400 mb-1">
                          محاضرات النظري
                        </label>
                        <input
                          type="number"
                          min="1"
                          value={theoryCount}
                          onChange={(e) => setTheoryCount(e.target.value)}
                          className="w-full px-3 py-2 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                        />
                      </div>
                      {hasPractical && (
                        <div>
                          <label className="block text-[11px] font-semibold text-slate-600 dark:text-slate-400 mb-1">
                            محاضرات العملي
                          </label>
                          <input
                            type="number"
                            min="1"
                            value={practicalCount}
                            onChange={(e) => setPracticalCount(e.target.value)}
                            className="w-full px-3 py-2 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                          />
                        </div>
                      )}
                    </div>
                  )}
                </div>
              )}

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsModalOpen(false)}
                  className="flex-1 py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-md transition-all"
                >
                  {courseToEdit ? 'حفظ التعديلات' : 'إنشاء المقرر'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      {courseToDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-700 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              حذف المقرر الدراسي
            </h3>
            <p className="text-xs text-slate-600 dark:text-slate-300 mb-6 leading-relaxed">
              هل أنت متأكد من رغبتك في حذف مقرر &quot;{courseToDelete.name}&quot;؟ سيتم حذف كافة المحاضرات وسجلات الحضور والمهام والتقييمات المرتبطة به نهائياً.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setCourseToDelete(null)}
                className="px-4 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={handleConfirmDelete}
                className="px-4 py-2 rounded-xl text-xs font-bold bg-red-600 text-white hover:bg-red-700 transition-colors shadow-xs"
              >
                حذف المقرر
              </button>
            </div>
          </div>
        </div>
      )}

      <UniversityBottomNavBar currentRoute="/university/courses" onNavigate={onNavigate} />
    </div>
  );
};
