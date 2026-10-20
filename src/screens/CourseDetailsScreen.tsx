import React, { useState } from 'react';
import { useUniversity } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import {
  LectureModel,
  AssessmentModel,
  AssessmentSection,
  getAttendanceStatusDisplayName,
} from '../types';
import {
  User,
  BookOpen,
  FlaskConical,
  FileText,
  ChevronLeft,
  CheckCircle2,
  XCircle,
  Award,
  Plus,
  Edit2,
  Trash2,
  X,
  AlertCircle,
  Ban,
  Clock,
  Sparkles,
} from 'lucide-react';

interface CourseDetailsScreenProps {
  courseId: string;
  onNavigate: (route: string) => void;
}

export const CourseDetailsScreen: React.FC<CourseDetailsScreenProps> = ({
  courseId,
  onNavigate,
}) => {
  const { getCourse, addAssessment, updateAssessment, deleteAssessment } = useUniversity();
  const course = getCourse(courseId);

  // Tab State: 'theoretical' | 'practical' | 'assessments'
  const [activeTab, setActiveTab] = useState<'theoretical' | 'practical' | 'assessments'>(
    'theoretical'
  );

  // Assessment Modal State
  const [isAssessmentModalOpen, setIsAssessmentModalOpen] = useState(false);
  const [editingAssessment, setEditingAssessment] = useState<AssessmentModel | null>(null);
  const [assessmentName, setAssessmentName] = useState('');
  const [assessmentSection, setAssessmentSection] = useState<AssessmentSection>('theoretical');
  const [maxScore, setMaxScore] = useState<string>('20');
  const [actualScore, setActualScore] = useState<string>('');
  const [isCompleted, setIsCompleted] = useState<boolean>(false);
  const [assessmentNotes, setAssessmentNotes] = useState('');
  const [modalError, setModalError] = useState<string | null>(null);

  if (!course) {
    return (
      <div className="min-h-screen bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white flex flex-col">
        <Navbar
          title="تفاصيل المقرر"
          onNavigate={onNavigate}
          showBack={true}
          onBack={() => onNavigate('/university/courses')}
        />
        <div className="flex-1 flex items-center justify-center p-4">
          <p className="text-slate-500">المقرر المطلوب غير موجود</p>
        </div>
      </div>
    );
  }

  const theoreticalLectures = course.lectures.filter((l) => l.section === 'theoretical');
  const practicalLectures = course.lectures.filter((l) => l.section === 'practical');

  const totalRecorded = course.lectures.filter(
    (l) => l.attendanceStatus !== 'none' && l.lectureDate
  ).length;

  // Assessments calculations
  const assessments = course.assessments || [];
  const totalAllocatedScore = assessments.reduce((sum, a) => sum + (Number(a.maxScore) || 0), 0);
  const remainingScore = Math.max(0, 100 - totalAllocatedScore);
  const completedAssessmentsCount = assessments.filter((a) => a.isCompleted).length;

  const theoryAssessments = assessments.filter((a) => a.section === 'theoretical');
  const practicalAssessments = assessments.filter((a) => a.section === 'practical');
  const finalExamAssessments = assessments.filter((a) => a.section === 'final');

  const openAddAssessmentModal = (defaultSection: AssessmentSection = 'theoretical') => {
    setEditingAssessment(null);
    setAssessmentName('');
    setAssessmentSection(defaultSection);
    setMaxScore(Math.min(20, remainingScore).toString() || '10');
    setActualScore('');
    setIsCompleted(false);
    setAssessmentNotes('');
    setModalError(null);
    setIsAssessmentModalOpen(true);
  };

  const openEditAssessmentModal = (assessment: AssessmentModel) => {
    setEditingAssessment(assessment);
    setAssessmentName(assessment.name);
    setAssessmentSection(assessment.section);
    setMaxScore(assessment.maxScore.toString());
    setActualScore(assessment.actualScore != null ? assessment.actualScore.toString() : '');
    setIsCompleted(assessment.isCompleted);
    setAssessmentNotes(assessment.notes || '');
    setModalError(null);
    setIsAssessmentModalOpen(true);
  };

  const handleSaveAssessment = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanName = assessmentName.trim();
    if (!cleanName) {
      setModalError('يرجى إدخال اسم عنصر التقييم');
      return;
    }

    const numMax = Number(maxScore);
    if (isNaN(numMax) || numMax <= 0) {
      setModalError('يجب أن تكون الدرجة القصوى رقماً موجباً');
      return;
    }

    const numActual = actualScore !== '' ? Number(actualScore) : null;
    if (numActual != null && (isNaN(numActual) || numActual < 0)) {
      setModalError('الدرجة الفعلية يجب أن تكون رقماً غير سالب');
      return;
    }

    if (numActual != null && numActual > numMax) {
      setModalError('لا يمكن أن تتجاوز الدرجة الفعلية الدرجة القصوى المخصصة');
      return;
    }

    if (editingAssessment) {
      const res = updateAssessment(course.id, editingAssessment.id, {
        name: cleanName,
        section: assessmentSection,
        maxScore: numMax,
        actualScore: numActual,
        isCompleted,
        notes: assessmentNotes.trim() || undefined,
      });

      if (!res.success) {
        setModalError(res.error || 'فشل تحديث التقييم');
        return;
      }
    } else {
      const res = addAssessment(course.id, {
        name: cleanName,
        section: assessmentSection,
        maxScore: numMax,
        actualScore: numActual,
        isCompleted,
        notes: assessmentNotes.trim() || undefined,
      });

      if (!res.success) {
        setModalError(res.error || 'فشل إضافة التقييم');
        return;
      }
    }

    setIsAssessmentModalOpen(false);
  };

  return (
    <div className="min-h-screen pb-16 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar
        title={course.name}
        onNavigate={onNavigate}
        showBack={true}
        onBack={() => onNavigate('/university/courses')}
        currentMode="university"
      />

      <main className="max-w-2xl mx-auto px-4 py-4 space-y-4">
        {/* Top Info Header Bar */}
        <div className="p-4 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs">
          <div className="flex items-center justify-between gap-3">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center font-bold">
                <User className="w-5 h-5" />
              </div>
              <div>
                <h2 className="text-sm font-bold text-slate-900 dark:text-white">
                  دكتور النظري: {course.instructorName || 'غير محدد'}
                </h2>
                {course.hasPractical && (
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    دكتور العملي: {course.practicalInstructorName || 'غير محدد'}
                  </p>
                )}
              </div>
            </div>

            <div className="text-left">
              <span className="px-3 py-1 rounded-xl text-xs font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800">
                {course.creditHours} ساعات معتمدة
              </span>
            </div>
          </div>
        </div>

        {/* Section Tabs */}
        <div className="flex p-1 bg-slate-200/80 dark:bg-slate-800 rounded-2xl">
          <button
            onClick={() => setActiveTab('theoretical')}
            className={`flex-1 py-2 px-3 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
              activeTab === 'theoretical'
                ? 'bg-white dark:bg-[#1E293B] text-blue-600 dark:text-blue-400 shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
            }`}
          >
            <BookOpen className="w-4 h-4" />
            <span>النظري ({theoreticalLectures.length})</span>
          </button>

          {course.hasPractical && (
            <button
              onClick={() => setActiveTab('practical')}
              className={`flex-1 py-2 px-3 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
                activeTab === 'practical'
                  ? 'bg-white dark:bg-[#1E293B] text-emerald-600 dark:text-emerald-400 shadow-xs'
                  : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
              }`}
            >
              <FlaskConical className="w-4 h-4" />
              <span>العملي ({practicalLectures.length})</span>
            </button>
          )}

          <button
            onClick={() => setActiveTab('assessments')}
            className={`flex-1 py-2 px-3 rounded-xl text-xs font-bold flex items-center justify-center gap-1.5 transition-all ${
              activeTab === 'assessments'
                ? 'bg-white dark:bg-[#1E293B] text-amber-600 dark:text-amber-400 shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
            }`}
          >
            <Award className="w-4 h-4" />
            <span>التقييمات والدرجات ({assessments.length})</span>
          </button>
        </div>

        {/* TAB 1: THEORETICAL LECTURES */}
        {activeTab === 'theoretical' && (
          <LecturesList
            course={course}
            lectures={theoreticalLectures}
            onNavigate={onNavigate}
          />
        )}

        {/* TAB 2: PRACTICAL LECTURES */}
        {activeTab === 'practical' && (
          <LecturesList
            course={course}
            lectures={practicalLectures}
            onNavigate={onNavigate}
          />
        )}

        {/* TAB 3: ASSESSMENTS & GRADING (التطوير السابع) */}
        {activeTab === 'assessments' && (
          <div className="space-y-4">
            {/* Grades Score Summary Banner */}
            <div className="p-4 rounded-2xl bg-gradient-to-br from-amber-50 to-orange-50/50 dark:from-amber-950/30 dark:to-slate-800 border border-amber-200 dark:border-amber-900/40 shadow-xs space-y-3">
              <div className="flex items-center justify-between">
                <div>
                  <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                    توزيع درجات المقرر (المجموع 100 درجة)
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    المنجز: {completedAssessmentsCount} من {assessments.length} عنصر تقييم
                  </p>
                </div>
                <div className="text-left">
                  <span className="text-lg font-black text-amber-600 dark:text-amber-400">
                    {totalAllocatedScore}/100
                  </span>
                  <p className="text-[10px] text-slate-500 font-bold">
                    المتبقي: {remainingScore} درجة
                  </p>
                </div>
              </div>

              {/* Progress bar for 100 marks */}
              <div className="w-full bg-slate-200 dark:bg-slate-700 h-2.5 rounded-full overflow-hidden">
                <div
                  className={`h-full rounded-full transition-all duration-300 ${
                    totalAllocatedScore === 100
                      ? 'bg-emerald-500'
                      : totalAllocatedScore > 80
                      ? 'bg-blue-500'
                      : 'bg-amber-500'
                  }`}
                  style={{ width: `${Math.min(100, totalAllocatedScore)}%` }}
                />
              </div>

              {totalAllocatedScore > 100 && (
                <div className="flex items-center gap-1.5 text-xs text-red-600 dark:text-red-400 font-bold">
                  <AlertCircle className="w-4 h-4" />
                  <span>تنبيه: مجموع الدرجات القصوى تجاوز 100 درجة! يرجى تصحيح الدرجات.</span>
                </div>
              )}
            </div>

            {/* Quick Action: Add Assessment */}
            <div className="flex justify-end">
              <button
                onClick={() => openAddAssessmentModal('theoretical')}
                className="px-3.5 py-1.5 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-xs flex items-center gap-1.5"
              >
                <Plus className="w-4 h-4" />
                <span>إضافة عنصر تقييم</span>
              </button>
            </div>

            {/* Section A: Theoretical Assessments */}
            <div className="space-y-2">
              <div className="flex items-center justify-between text-xs font-bold text-blue-600 dark:text-blue-400 px-1">
                <span>أ. تقييمات النظري ({theoryAssessments.length})</span>
                <button
                  onClick={() => openAddAssessmentModal('theoretical')}
                  className="hover:underline text-[11px]"
                >
                  + إضافة للنظري
                </button>
              </div>

              {theoryAssessments.length === 0 ? (
                <div className="p-3 text-center text-xs text-slate-400 bg-white dark:bg-[#1E293B] rounded-xl border border-slate-200 dark:border-slate-800">
                  لا توجد تقييمات نظرية محددة بعد
                </div>
              ) : (
                theoryAssessments.map((item) => (
                  <AssessmentCard
                    key={item.id}
                    item={item}
                    onEdit={() => openEditAssessmentModal(item)}
                    onDelete={() => deleteAssessment(course.id, item.id)}
                  />
                ))
              )}
            </div>

            {/* Section B: Practical Assessments (if practical) */}
            {course.hasPractical && (
              <div className="space-y-2 pt-2">
                <div className="flex items-center justify-between text-xs font-bold text-emerald-600 dark:text-emerald-400 px-1">
                  <span>ب. تقييمات العملي ({practicalAssessments.length})</span>
                  <button
                    onClick={() => openAddAssessmentModal('practical')}
                    className="hover:underline text-[11px]"
                  >
                    + إضافة للعملي
                  </button>
                </div>

                {practicalAssessments.length === 0 ? (
                  <div className="p-3 text-center text-xs text-slate-400 bg-white dark:bg-[#1E293B] rounded-xl border border-slate-200 dark:border-slate-800">
                    لا توجد تقييمات عملية محددة بعد
                  </div>
                ) : (
                  practicalAssessments.map((item) => (
                    <AssessmentCard
                      key={item.id}
                      item={item}
                      onEdit={() => openEditAssessmentModal(item)}
                      onDelete={() => deleteAssessment(course.id, item.id)}
                    />
                  ))
                )}
              </div>
            )}

            {/* Section C: Final Exam (عام على مستوى المقرر) */}
            <div className="space-y-2 pt-2">
              <div className="flex items-center justify-between text-xs font-bold text-purple-600 dark:text-purple-400 px-1">
                <span>ج. الاختبار النهائي العام ({finalExamAssessments.length})</span>
                {finalExamAssessments.length === 0 && (
                  <button
                    onClick={() => openAddAssessmentModal('final')}
                    className="hover:underline text-[11px]"
                  >
                    + إضافة الاختبار النهائي
                  </button>
                )}
              </div>

              {finalExamAssessments.length === 0 ? (
                <div className="p-3 text-center text-xs text-slate-400 bg-white dark:bg-[#1E293B] rounded-xl border border-slate-200 dark:border-slate-800">
                  لم يتم تسجيل الاختبار النهائي العام بعد (يُسجل مرة واحدة للمقرر)
                </div>
              ) : (
                finalExamAssessments.map((item) => (
                  <AssessmentCard
                    key={item.id}
                    item={item}
                    onEdit={() => openEditAssessmentModal(item)}
                    onDelete={() => deleteAssessment(course.id, item.id)}
                  />
                ))
              )}
            </div>
          </div>
        )}
      </main>

      {/* Add / Edit Assessment Modal */}
      {isAssessmentModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                {editingAssessment ? 'تعديل عنصر التقييم' : 'إضافة عنصر تقييم جديد'}
              </h3>
              <button
                onClick={() => setIsAssessmentModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {modalError && (
              <div className="mb-4 p-3 rounded-xl bg-red-50 dark:bg-red-950/40 border border-red-200 dark:border-red-800 text-red-600 dark:text-red-400 text-xs font-semibold flex items-center gap-2">
                <AlertCircle className="w-4 h-4 shrink-0" />
                <span>{modalError}</span>
              </div>
            )}

            <form onSubmit={handleSaveAssessment} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  اسم عنصر التقييم *
                </label>
                <input
                  type="text"
                  required
                  autoFocus
                  value={assessmentName}
                  onChange={(e) => {
                    setAssessmentName(e.target.value);
                    if (modalError) setModalError(null);
                  }}
                  placeholder="مثال: اختبار نصفي / مشروع نهائي / أعمال فصلية"
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-amber-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  القسم التابع له
                </label>
                <select
                  value={assessmentSection}
                  onChange={(e) => setAssessmentSection(e.target.value as AssessmentSection)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                >
                  <option value="theoretical">تقييمات النظري</option>
                  {course.hasPractical && <option value="practical">تقييمات العملي</option>}
                  <option value="final">الاختبار النهائي العام للمقرر</option>
                </select>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                    الدرجة القصوى * (من 100)
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="100"
                    required
                    value={maxScore}
                    onChange={(e) => setMaxScore(e.target.value)}
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                    الدرجة الفعلية (اختياري)
                  </label>
                  <input
                    type="number"
                    min="0"
                    max={maxScore}
                    value={actualScore}
                    onChange={(e) => setActualScore(e.target.value)}
                    placeholder="إن وُجدت"
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                  />
                </div>
              </div>

              <div className="p-3 rounded-xl bg-slate-50 dark:bg-slate-900/60 border border-slate-200 dark:border-slate-800 flex items-center justify-between">
                <div>
                  <span className="text-xs font-bold text-slate-900 dark:text-white">
                    حالة الإنجاز (منجز / غير منجز)
                  </span>
                  <p className="text-[11px] text-slate-400">
                    منفصلة عن تسجيل الدرجة الفعلية
                  </p>
                </div>
                <input
                  type="checkbox"
                  checked={isCompleted}
                  onChange={(e) => setIsCompleted(e.target.checked)}
                  className="w-5 h-5 rounded text-amber-600 focus:ring-amber-500 border-slate-300"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  ملاحظات اختيارية
                </label>
                <input
                  type="text"
                  value={assessmentNotes}
                  onChange={(e) => setAssessmentNotes(e.target.value)}
                  placeholder="موعد الاختبار أو تفاصيل التكليف..."
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs"
                />
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsAssessmentModalOpen(false)}
                  className="flex-1 py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 px-4 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-md transition-all"
                >
                  {editingAssessment ? 'حفظ التعديلات' : 'إضافة عنصر التقييم'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};

// Sub-component: Lectures List
const LecturesList: React.FC<{
  course: any;
  lectures: LectureModel[];
  onNavigate: (route: string) => void;
}> = ({ course, lectures, onNavigate }) => {
  if (lectures.length === 0) {
    return (
      <div className="p-8 text-center text-slate-500 text-xs bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800">
        لا توجد محاضرات في هذا القسم
      </div>
    );
  }

  return (
    <div className="space-y-2.5">
      {lectures.map((lecture) => {
        const completedTasks = lecture.tasks.filter((t) => t.status === 'completed').length;
        const isPresent = lecture.attendanceStatus === 'present';
        const isAbsent = lecture.attendanceStatus === 'absent';
        const isCancelled = lecture.attendanceStatus === 'cancelled';

        return (
          <div
            key={lecture.id}
            onClick={() => onNavigate(`/university/lectures/${course.id}/${lecture.id}`)}
            role="button"
            tabIndex={0}
            className={`p-3.5 sm:p-4 rounded-2xl border transition-all cursor-pointer flex items-center justify-between ${
              isCancelled
                ? 'bg-slate-100/60 dark:bg-slate-800/40 border-slate-300 dark:border-slate-700 opacity-75'
                : isPresent
                ? 'bg-emerald-50/40 dark:bg-emerald-950/20 border-emerald-200 dark:border-emerald-800/60'
                : isAbsent
                ? 'bg-red-50/40 dark:bg-red-950/20 border-red-200 dark:border-red-800/60'
                : 'bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800 hover:border-slate-300 dark:hover:border-slate-700'
            }`}
          >
            <div className="flex items-center gap-3 min-w-0 flex-1">
              {/* Number Avatar */}
              <div
                className={`w-9 h-9 rounded-full flex items-center justify-center font-bold text-xs shrink-0 ${
                  isCancelled
                    ? 'bg-slate-400 text-white'
                    : isPresent
                    ? 'bg-emerald-600 text-white'
                    : isAbsent
                    ? 'bg-red-600 text-white'
                    : 'bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400'
                }`}
              >
                {lecture.lectureNumber}
              </div>

              {/* Details */}
              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <h4 className="text-sm font-bold text-slate-900 dark:text-white truncate">
                    {lecture.title}
                  </h4>
                  {lecture.notes.trim().length > 0 && (
                    <span title="يوجد ملاحظات">
                      <FileText className="w-3.5 h-3.5 text-blue-500 shrink-0" />
                    </span>
                  )}
                </div>

                <div className="flex flex-wrap items-center gap-2 mt-1.5">
                  <span
                    className={`px-2 py-0.5 rounded-md text-[10.5px] font-bold ${
                      isCancelled
                        ? 'bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300'
                        : isPresent
                        ? 'bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300'
                        : isAbsent
                        ? 'bg-red-100 dark:bg-red-950/80 text-red-700 dark:text-red-300'
                        : 'bg-slate-100 dark:bg-slate-800 text-slate-500 dark:text-slate-400'
                    }`}
                  >
                    {isCancelled
                      ? `ملغاة (${lecture.cancellationReason || 'بدون سبب'})`
                      : isPresent
                      ? `حاضر (${lecture.lectureDate || ''})`
                      : isAbsent
                      ? `غائب (${lecture.lectureDate || ''})`
                      : 'لم يسجل بعد'}
                  </span>

                  {!isCancelled && (
                    <span className="px-2 py-0.5 rounded-md text-[10.5px] font-bold bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400">
                      {completedTasks}/{lecture.tasks.length} مهام
                    </span>
                  )}
                </div>
              </div>
            </div>

            <ChevronLeft className="w-4 h-4 text-slate-400 shrink-0 mr-2" />
          </div>
        );
      })}
    </div>
  );
};

// Sub-component: Assessment Card
const AssessmentCard: React.FC<{
  item: AssessmentModel;
  onEdit: () => void;
  onDelete: () => void;
}> = ({ item, onEdit, onDelete }) => {
  return (
    <div className="p-3.5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs flex items-center justify-between gap-3">
      <div className="flex items-center gap-3 flex-1 min-w-0">
        <div
          className={`w-9 h-9 rounded-xl flex items-center justify-center shrink-0 ${
            item.isCompleted
              ? 'bg-emerald-100 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400'
              : 'bg-amber-100 dark:bg-amber-950/80 text-amber-600 dark:text-amber-400'
          }`}
        >
          {item.isCompleted ? <CheckCircle2 className="w-5 h-5" /> : <Clock className="w-5 h-5" />}
        </div>

        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            <h4 className="text-xs font-bold text-slate-900 dark:text-white truncate">
              {item.name}
            </h4>
            <span
              className={`px-2 py-0.2 rounded-md text-[10px] font-bold ${
                item.isCompleted
                  ? 'bg-emerald-50 dark:bg-emerald-950/60 text-emerald-700 dark:text-emerald-300'
                  : 'bg-amber-50 dark:bg-amber-950/60 text-amber-700 dark:text-amber-300'
              }`}
            >
              {item.isCompleted ? 'منجز' : 'غير منجز'}
            </span>
          </div>

          <div className="flex items-center gap-3 text-[11px] text-slate-500 mt-1">
            <span className="font-bold text-slate-700 dark:text-slate-300">
              الدرجة القصوى: {item.maxScore} درجة
            </span>
            {item.actualScore != null ? (
              <span className="text-emerald-600 dark:text-emerald-400 font-bold">
                (الدرجة المسجلة: {item.actualScore}/{item.maxScore})
              </span>
            ) : (
              <span className="text-slate-400">(الدرجة الفعلية لم تُسجل بعد)</span>
            )}
          </div>

          {item.notes && (
            <p className="text-[11px] text-slate-400 dark:text-slate-500 mt-0.5 truncate">
              {item.notes}
            </p>
          )}
        </div>
      </div>

      <div className="flex items-center gap-1 shrink-0">
        <button
          onClick={onEdit}
          className="p-1.5 rounded-lg text-slate-400 hover:text-amber-600 transition-colors"
          title="تعديل"
        >
          <Edit2 className="w-3.5 h-3.5" />
        </button>
        <button
          onClick={onDelete}
          className="p-1.5 rounded-lg text-slate-400 hover:text-red-600 transition-colors"
          title="حذف"
        >
          <Trash2 className="w-3.5 h-3.5" />
        </button>
      </div>
    </div>
  );
};
