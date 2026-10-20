import React, { useState } from 'react';
import { useUniversity, getTodayString } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import {
  UniversityTaskModel,
  UniversityTaskCategory,
  UniversityTaskStatus,
  AttendanceStatus,
  UNIVERSITY_TASK_CATEGORIES,
  getCategoryDisplayName,
  getStatusDisplayName,
} from '../types';
import {
  UserCheck,
  CheckCircle2,
  XCircle,
  RotateCcw,
  FileText,
  Edit2,
  Plus,
  Trash2,
  X,
  Clock,
  Circle,
  Calendar,
  Ban,
  CheckCheck,
} from 'lucide-react';

interface LectureDetailsScreenProps {
  courseId: string;
  lectureId: string;
  onNavigate: (route: string) => void;
}

export const LectureDetailsScreen: React.FC<LectureDetailsScreenProps> = ({
  courseId,
  lectureId,
  onNavigate,
}) => {
  const {
    getCourse,
    getLecture,
    recordAttendance,
    completeAllLectureTasks,
    updateLectureNotes,
    addLectureTask,
    updateTaskStatus,
    updateTask,
    deleteTask,
  } = useUniversity();

  const course = getCourse(courseId);
  const lecture = getLecture(courseId, lectureId);

  // Cancellation modal state
  const [isCancelModalOpen, setIsCancelModalOpen] = useState(false);
  const [cancelReason, setCancelReason] = useState('عطلة رسمية');
  const [customCancelReason, setCustomCancelReason] = useState('');

  // Date edit modal state
  const [isDateModalOpen, setIsDateModalOpen] = useState(false);
  const [lectureDateInput, setLectureDateInput] = useState(lecture?.lectureDate || getTodayString());

  // Notes state
  const [isEditingNotes, setIsEditingNotes] = useState(false);
  const [notesText, setNotesText] = useState(lecture?.notes || '');

  // Add / Edit task modal state
  const [isTaskModalOpen, setIsTaskModalOpen] = useState(false);
  const [editingTask, setEditingTask] = useState<UniversityTaskModel | null>(null);
  const [taskTitle, setTaskTitle] = useState('');
  const [taskCategory, setTaskCategory] = useState<UniversityTaskCategory>('study');
  const [titleError, setTitleError] = useState<string | null>(null);

  if (!course || !lecture) {
    return (
      <div className="min-h-screen bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white flex flex-col">
        <Navbar
          title="تفاصيل المحاضرة"
          onNavigate={onNavigate}
          showBack={true}
          onBack={() => onNavigate(`/university/courses/${courseId}`)}
        />
        <div className="flex-1 flex items-center justify-center p-4">
          <p className="text-slate-500">المحاضرة المطلوبة غير موجودة</p>
        </div>
      </div>
    );
  }

  const handleSaveNotes = () => {
    updateLectureNotes(courseId, lectureId, notesText.trim());
    setIsEditingNotes(false);
  };

  const openAddTaskModal = () => {
    setEditingTask(null);
    setTaskTitle('');
    setTaskCategory('study');
    setTitleError(null);
    setIsTaskModalOpen(true);
  };

  const openEditTaskModal = (task: UniversityTaskModel) => {
    setEditingTask(task);
    setTaskTitle(task.title);
    setTaskCategory(task.category as UniversityTaskCategory);
    setTitleError(null);
    setIsTaskModalOpen(true);
  };

  const handleSaveTask = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanTitle = taskTitle.trim();
    if (!cleanTitle) {
      setTitleError('يرجى إدخال عنوان المهمة');
      return;
    }

    if (editingTask) {
      updateTask(courseId, lectureId, editingTask.id, cleanTitle, taskCategory);
    } else {
      addLectureTask(courseId, lectureId, cleanTitle, taskCategory);
    }

    setIsTaskModalOpen(false);
  };

  const handleCycleStatus = (task: UniversityTaskModel) => {
    let nextStatus: UniversityTaskStatus = 'notStarted';
    if (task.status === 'notStarted') nextStatus = 'inProgress';
    else if (task.status === 'inProgress') nextStatus = 'completed';
    else nextStatus = 'notStarted';

    updateTaskStatus(courseId, lectureId, task.id, nextStatus);
  };

  const isPresent = lecture.attendanceStatus === 'present';
  const isAbsent = lecture.attendanceStatus === 'absent';
  const isCancelled = lecture.attendanceStatus === 'cancelled';
  const isRecorded = isPresent || isAbsent || isCancelled;

  const handleOpenCancelModal = () => {
    setCancelReason('عطلة رسمية');
    setCustomCancelReason('');
    setIsCancelModalOpen(true);
  };

  const handleConfirmCancel = (e: React.FormEvent) => {
    e.preventDefault();
    const finalReason =
      cancelReason === 'أخرى' ? customCancelReason.trim() || 'سبب غير محدد' : cancelReason;
    recordAttendance(courseId, lectureId, 'cancelled', undefined, finalReason);
    setIsCancelModalOpen(false);
  };

  const handleSaveCustomDate = (e: React.FormEvent) => {
    e.preventDefault();
    if (lectureDateInput && lecture.attendanceStatus !== 'none') {
      recordAttendance(
        courseId,
        lectureId,
        lecture.attendanceStatus,
        lectureDateInput,
        lecture.cancellationReason
      );
    }
    setIsDateModalOpen(false);
  };

  return (
    <div className="min-h-screen pb-16 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar
        title={`${lecture.title} - ${course.name}`}
        onNavigate={onNavigate}
        showBack={true}
        onBack={() => onNavigate(`/university/courses/${courseId}`)}
        currentMode="university"
      />

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-5">
        {/* Lecture Header Card */}
        <div className="p-4 sm:p-5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs">
          <div className="flex items-center gap-2 mb-2">
            <span className="px-2.5 py-0.5 rounded-md text-xs font-bold bg-blue-100 dark:bg-blue-950/80 text-blue-700 dark:text-blue-300">
              {lecture.section === 'theoretical' ? 'نظري' : 'عملي'}
            </span>
            <h2 className="text-base font-bold text-slate-900 dark:text-white">
              {course.name}
            </h2>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400">
            المحاضر: {course.instructorName || 'غير محدد'}
          </p>
        </div>

        {/* Attendance Card */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs">
          <div className="flex items-center gap-2 mb-1.5">
            <UserCheck className="w-5 h-5 text-blue-600 dark:text-blue-400" />
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">
              تسجيل الحضور والغياب للمحاضرة
            </h3>
          </div>
          <p className="text-xs text-slate-500 dark:text-slate-400 leading-relaxed mb-4">
            حدد حالتك عند تلقي المحاضرة (حاضر / غائب / ملغية)، ويتم حفظ التاريخ وربط مهامها بالعرض اليومي. المحاضرات الملغاة تُستبعد تلقائياً من حساب نسبة الحضور.
          </p>

          {/* Action Buttons: حاضر / غائب / ملغية / إعادة ضبط */}
          <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
            <button
              onClick={() => recordAttendance(courseId, lectureId, 'present')}
              className={`py-2.5 px-3 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 transition-all ${
                isPresent
                  ? 'bg-emerald-600 text-white shadow-md'
                  : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-emerald-50 dark:hover:bg-emerald-950/40'
              }`}
            >
              <CheckCircle2 className="w-4 h-4 shrink-0" />
              <span>حاضر</span>
            </button>

            <button
              onClick={() => recordAttendance(courseId, lectureId, 'absent')}
              className={`py-2.5 px-3 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 transition-all ${
                isAbsent
                  ? 'bg-red-600 text-white shadow-md'
                  : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-red-50 dark:hover:bg-red-950/40'
              }`}
            >
              <XCircle className="w-4 h-4 shrink-0" />
              <span>غائب</span>
            </button>

            <button
              onClick={handleOpenCancelModal}
              className={`py-2.5 px-3 rounded-xl text-xs sm:text-sm font-bold flex items-center justify-center gap-1.5 transition-all ${
                isCancelled
                  ? 'bg-amber-600 text-white shadow-md'
                  : 'bg-slate-100 dark:bg-slate-800 text-slate-700 dark:text-slate-300 hover:bg-amber-50 dark:hover:bg-amber-950/40'
              }`}
            >
              <Ban className="w-4 h-4 shrink-0" />
              <span>ملغية</span>
            </button>

            {isRecorded && (
              <button
                onClick={() => recordAttendance(courseId, lectureId, 'none')}
                className="py-2.5 px-3 rounded-xl bg-slate-100 dark:bg-slate-800 text-slate-500 hover:text-slate-800 dark:hover:text-slate-200 text-xs font-bold flex items-center justify-center gap-1 transition-colors col-span-3 sm:col-span-1"
                title="إلغاء التسجيل"
              >
                <RotateCcw className="w-4 h-4" />
                <span>إعادة ضبط</span>
              </button>
            )}
          </div>

          {/* Status info bar with date editing */}
          {isRecorded && (
            <div
              className={`mt-3 p-3 rounded-xl text-xs font-bold flex items-center justify-between gap-2 flex-wrap ${
                isPresent
                  ? 'bg-emerald-50 dark:bg-emerald-950/50 text-emerald-700 dark:text-emerald-300 border border-emerald-200 dark:border-emerald-800/60'
                  : isAbsent
                  ? 'bg-red-50 dark:bg-red-950/50 text-red-700 dark:text-red-300 border border-red-200 dark:border-red-800/60'
                  : 'bg-amber-50 dark:bg-amber-950/50 text-amber-700 dark:text-amber-300 border border-amber-200 dark:border-amber-800/60'
              }`}
            >
              <div className="flex items-center gap-2">
                <Calendar className="w-4 h-4 shrink-0" />
                <span>
                  {isPresent && `تم التسجيل: حاضر بتاريخ ${lecture.lectureDate || 'اليوم'}`}
                  {isAbsent && `تم التسجيل: غائب بتاريخ ${lecture.lectureDate || 'اليوم'}`}
                  {isCancelled &&
                    `محاضرة ملغاة ${
                      lecture.cancellationReason ? `(${lecture.cancellationReason})` : ''
                    } بتاريخ ${lecture.lectureDate || 'اليوم'}`}
                </span>
              </div>
              <button
                onClick={() => {
                  setLectureDateInput(lecture.lectureDate || getTodayString());
                  setIsDateModalOpen(true);
                }}
                className="text-[11px] font-semibold underline hover:opacity-80 transition-opacity"
              >
                تعديل التاريخ
              </button>
            </div>
          )}
        </div>

        {/* Notes Card */}
        <div className="p-5 rounded-2xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-xs">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <FileText className="w-5 h-5 text-blue-600 dark:text-blue-400" />
              <h3 className="text-sm font-bold text-slate-900 dark:text-white">
                ملاحظات المحاضرة
              </h3>
            </div>
            {!isEditingNotes ? (
              <button
                onClick={() => {
                  setNotesText(lecture.notes);
                  setIsEditingNotes(true);
                }}
                className="px-3 py-1 rounded-lg text-xs font-bold text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/50 flex items-center gap-1"
              >
                <Edit2 className="w-3.5 h-3.5" />
                <span>تعديل</span>
              </button>
            ) : (
              <button
                onClick={handleSaveNotes}
                className="px-3 py-1 rounded-lg text-xs font-bold bg-blue-600 text-white hover:bg-blue-700 shadow-xs"
              >
                حفظ
              </button>
            )}
          </div>

          {isEditingNotes ? (
            <textarea
              rows={4}
              value={notesText}
              onChange={(e) => setNotesText(e.target.value)}
              placeholder="اكتب ملاحظاتك وتلخيصك السريع لهذه المحاضرة هنا..."
              className="w-full p-3 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs leading-relaxed focus:outline-none focus:ring-2 focus:ring-blue-500 resize-none"
            />
          ) : (
            <p className="text-xs text-slate-600 dark:text-slate-300 leading-relaxed whitespace-pre-wrap">
              {lecture.notes.trim() ||
                'لا توجد ملاحظات مسجلة لهذه المحاضرة بعد. اضغط تعديل للتدوين.'}
            </p>
          )}
        </div>

        {/* Academic Tasks Section */}
        <div>
          <div className="flex items-center justify-between mb-3 px-1">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white">
              المهام الأكاديمية ({lecture.tasks.length})
            </h3>
            <div className="flex items-center gap-2">
              {lecture.tasks.some((t) => t.status !== 'completed') && (
                <button
                  onClick={() => completeAllLectureTasks(courseId, lectureId)}
                  className="px-2.5 py-1.5 rounded-xl bg-emerald-50 dark:bg-emerald-950/60 text-emerald-600 dark:text-emerald-400 hover:bg-emerald-100 dark:hover:bg-emerald-900/40 text-xs font-bold flex items-center gap-1 border border-emerald-200 dark:border-emerald-800"
                  title="إكمال جميع مهام المحاضرة"
                >
                  <CheckCheck className="w-3.5 h-3.5" />
                  <span className="hidden sm:inline">إكمال الكل</span>
                </button>
              )}
              <button
                onClick={openAddTaskModal}
                className="px-3 py-1.5 rounded-xl bg-blue-50 dark:bg-blue-950/60 text-blue-600 dark:text-blue-400 hover:bg-blue-100 dark:hover:bg-blue-900/40 text-xs font-bold flex items-center gap-1 border border-blue-200 dark:border-blue-800"
              >
                <Plus className="w-4 h-4" />
                <span>إضافة مهمة</span>
              </button>
            </div>
          </div>

          {lecture.tasks.length === 0 ? (
            <div className="p-8 text-center bg-white dark:bg-[#1E293B] rounded-2xl border border-slate-200 dark:border-slate-800 text-xs text-slate-500">
              لا توجد مهام مضافة لهذه المحاضرة. يمكنك إضافة مهمة جديدة أعلاه.
            </div>
          ) : (
            <div className="space-y-2">
              {lecture.tasks.map((task) => {
                const categoryDef = UNIVERSITY_TASK_CATEGORIES.find(
                  (c) => c.key === task.category
                ) || { color: '#64748B', bgColor: 'rgba(100, 116, 139, 0.12)' };

                const isCompleted = task.status === 'completed';
                const isInProgress = task.status === 'inProgress';

                return (
                  <div
                    key={task.id}
                    className={`p-3 rounded-2xl border transition-all flex items-center justify-between gap-3 ${
                      isCompleted
                        ? 'bg-slate-50/70 dark:bg-slate-900/30 border-slate-200 dark:border-slate-800/60'
                        : 'bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800'
                    }`}
                  >
                    {/* Checkbox / Status cycler */}
                    <button
                      onClick={() => handleCycleStatus(task)}
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

                    {/* Title & Category */}
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
                      <div className="flex items-center gap-2 mt-1">
                        <span
                          className="px-2 py-0.5 rounded-md text-[10px] font-bold"
                          style={{
                            backgroundColor: categoryDef.bgColor,
                            color: categoryDef.color,
                          }}
                        >
                          {getCategoryDisplayName(task.category)}
                        </span>
                        <span className="text-[10px] text-slate-400">
                          {getStatusDisplayName(task.status)}
                        </span>
                      </div>
                    </div>

                    {/* Actions */}
                    <div className="flex items-center gap-1 shrink-0">
                      <button
                        onClick={() => openEditTaskModal(task)}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                        title="تعديل المهمة"
                      >
                        <Edit2 className="w-3.5 h-3.5" />
                      </button>
                      <button
                        onClick={() => deleteTask(courseId, lectureId, task.id)}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/30 transition-colors"
                        title="حذف المهمة"
                      >
                        <Trash2 className="w-3.5 h-3.5" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </main>

      {/* Add / Edit Task Modal */}
      {isTaskModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                {editingTask ? 'تعديل المهمة الجامعية' : 'إضافة مهمة جديدة للمحاضرة'}
              </h3>
              <button
                onClick={() => setIsTaskModalOpen(false)}
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
                  placeholder="مثال: حل مسائل الشابتر الثاني"
                  className={`w-full px-4 py-2.5 rounded-xl border text-xs bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                    titleError ? 'border-red-500' : 'border-slate-300 dark:border-slate-700'
                  }`}
                />
                {titleError && <p className="text-xs text-red-500 mt-1">{titleError}</p>}
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  تصنيف المهمة
                </label>
                <select
                  value={taskCategory}
                  onChange={(e) => setTaskCategory(e.target.value as UniversityTaskCategory)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
                >
                  {UNIVERSITY_TASK_CATEGORIES.map((cat) => (
                    <option key={cat.key} value={cat.key}>
                      {cat.name}
                    </option>
                  ))}
                </select>
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsTaskModalOpen(false)}
                  className="flex-1 py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-bold text-xs shadow-md transition-all"
                >
                  {editingTask ? 'حفظ التعديلات' : 'إضافة المهمة'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
      {/* Cancellation Reason Modal */}
      {isCancelModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2 text-amber-600 dark:text-amber-400">
                <Ban className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900 dark:text-white">
                  تسجيل المحاضرة كملغاة
                </h3>
              </div>
              <button
                onClick={() => setIsCancelModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <p className="text-xs text-slate-500 dark:text-slate-400 mb-4">
              المحاضرات الملغاة يتم استبعادها تلقائياً من إجمالي الحضور والغياب حتى لا تؤثر سلباً على نسبة الحضور الأكاديمي.
            </p>

            <form onSubmit={handleConfirmCancel} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  سبب الإلغاء
                </label>
                <select
                  value={cancelReason}
                  onChange={(e) => setCancelReason(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-amber-500"
                >
                  <option value="عطلة رسمية">عطلة رسمية</option>
                  <option value="اعتذار الدكتور">اعتذار الدكتور</option>
                  <option value="إلغاء من إدارة الكلية">إلغاء من إدارة الكلية</option>
                  <option value="ظروف طارئة">ظروف طارئة</option>
                  <option value="أخرى">سبب مخصص (أخرى)...</option>
                </select>
              </div>

              {cancelReason === 'أخرى' && (
                <div>
                  <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                    اكتب سبب الإلغاء المخصص
                  </label>
                  <input
                    type="text"
                    required
                    autoFocus
                    value={customCancelReason}
                    onChange={(e) => setCustomCancelReason(e.target.value)}
                    placeholder="مثال: تأجيل إلى الأسبوع القادم"
                    className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-amber-500"
                  />
                </div>
              )}

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsCancelModalOpen(false)}
                  className="flex-1 py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  تراجع
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 px-4 rounded-xl bg-amber-600 hover:bg-amber-700 text-white font-bold text-xs shadow-md transition-all"
                >
                  تأكيد الإلغاء
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Date Modal */}
      {isDateModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2 text-blue-600 dark:text-blue-400">
                <Calendar className="w-5 h-5" />
                <h3 className="text-base font-bold text-slate-900 dark:text-white">
                  تعديل تاريخ المحاضرة
                </h3>
              </div>
              <button
                onClick={() => setIsDateModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSaveCustomDate} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  التاريخ الفعلي للمحاضرة
                </label>
                <input
                  type="date"
                  required
                  value={lectureDateInput}
                  onChange={(e) => setLectureDateInput(e.target.value)}
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div className="pt-2 flex gap-3">
                <button
                  type="button"
                  onClick={() => setIsDateModalOpen(false)}
                  className="flex-1 py-2.5 px-4 rounded-xl text-xs font-semibold text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                >
                  إلغاء
                </button>
                <button
                  type="submit"
                  className="flex-1 py-2.5 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-md transition-all"
                >
                  حفظ التاريخ
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
};
