import React, { useState } from 'react';
import { useUniversity } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { UniversityBottomNavBar } from '../components/UniversityBottomNavBar';
import { StudyPlanModel } from '../types';
import {
  Layers,
  Plus,
  CheckCircle2,
  Calendar,
  BookOpen,
  Edit2,
  Trash2,
  Archive,
  RotateCcw,
  X,
  ChevronLeft,
  GraduationCap,
} from 'lucide-react';

interface PlansScreenProps {
  onNavigate: (route: string) => void;
}

export const PlansScreen: React.FC<PlansScreenProps> = ({ onNavigate }) => {
  const {
    plans,
    activePlanId,
    setActivePlan,
    addPlan,
    updatePlan,
    deletePlan,
    archivePlan,
    restorePlan,
  } = useUniversity();

  const [activeTab, setActiveTab] = useState<'active' | 'archived'>('active');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingPlan, setEditingPlan] = useState<StudyPlanModel | null>(null);
  const [planName, setPlanName] = useState('');
  const [academicYear, setAcademicYear] = useState('');
  const [semester, setSemester] = useState('');
  const [nameError, setNameError] = useState<string | null>(null);

  // Delete Confirm Dialog
  const [planToDelete, setPlanToDelete] = useState<StudyPlanModel | null>(null);

  const activePlans = plans.filter((p) => p.status === 'active');
  const archivedPlans = plans.filter((p) => p.status === 'archived');
  const currentList = activeTab === 'active' ? activePlans : archivedPlans;

  const openAddModal = () => {
    setEditingPlan(null);
    setPlanName('');
    setAcademicYear('');
    setSemester('');
    setNameError(null);
    setIsModalOpen(true);
  };

  const openEditModal = (plan: StudyPlanModel) => {
    setEditingPlan(plan);
    setPlanName(plan.name);
    setAcademicYear(plan.academicYear || '');
    setSemester(plan.semester || '');
    setNameError(null);
    setIsModalOpen(true);
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const cleanName = planName.trim();
    if (!cleanName) {
      setNameError('يرجى إدخال اسم الخطة الدراسية');
      return;
    }

    if (editingPlan) {
      updatePlan(editingPlan.id, cleanName, academicYear, semester);
    } else {
      addPlan(cleanName, academicYear, semester);
    }

    setIsModalOpen(false);
  };

  const handleOpenPlan = (plan: StudyPlanModel) => {
    setActivePlan(plan.id);
    onNavigate('/university/courses');
  };

  return (
    <div className="min-h-screen pb-24 bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors relative">
      <Navbar title="الخطط الدراسية" onNavigate={onNavigate} currentMode="university" />

      <main className="max-w-2xl mx-auto px-4 py-5 space-y-4">
        {/* Banner with info */}
        <div className="p-4 sm:p-5 rounded-2xl bg-gradient-to-br from-blue-50 to-indigo-50/60 dark:from-blue-950/40 dark:to-slate-800/80 border border-blue-100 dark:border-blue-900/40 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <div className="w-12 h-12 rounded-2xl bg-blue-600 text-white flex items-center justify-center shadow-xs">
              <Layers className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-sm sm:text-base font-bold text-slate-900 dark:text-white">
                إدارة الخطط الأكاديمية
              </h2>
              <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                لكل خطة مقرراتها ومهامها وإحصائياتها المستقلة تماماً.
              </p>
            </div>
          </div>
          <button
            onClick={openAddModal}
            className="px-3.5 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-xs flex items-center gap-1.5 transition-all"
          >
            <Plus className="w-4 h-4" />
            <span className="hidden sm:inline">خطة جديدة</span>
          </button>
        </div>

        {/* Tabs: النشطة vs المؤرشفة */}
        <div className="flex p-1 bg-slate-200/80 dark:bg-slate-800 rounded-2xl">
          <button
            onClick={() => setActiveTab('active')}
            className={`flex-1 py-2 px-4 rounded-xl text-xs font-bold transition-all ${
              activeTab === 'active'
                ? 'bg-white dark:bg-[#1E293B] text-blue-600 dark:text-blue-400 shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
            }`}
          >
            الخطط النشطة ({activePlans.length})
          </button>
          <button
            onClick={() => setActiveTab('archived')}
            className={`flex-1 py-2 px-4 rounded-xl text-xs font-bold transition-all ${
              activeTab === 'archived'
                ? 'bg-white dark:bg-[#1E293B] text-purple-600 dark:text-purple-400 shadow-xs'
                : 'text-slate-600 dark:text-slate-400 hover:text-slate-900 dark:hover:text-white'
            }`}
          >
            الأرشيف ({archivedPlans.length})
          </button>
        </div>

        {/* List of Plans */}
        {currentList.length === 0 ? (
          <div className="py-16 px-4 text-center flex flex-col items-center justify-center">
            <div className="w-16 h-16 rounded-full bg-blue-100 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 flex items-center justify-center mb-3">
              <Layers className="w-8 h-8" />
            </div>
            <h3 className="text-sm font-bold text-slate-900 dark:text-white mb-1">
              {activeTab === 'active' ? 'لا توجد خطط دراسية حالياً' : 'أرشيف الخطط فارغ'}
            </h3>
            <p className="text-xs text-slate-500 dark:text-slate-400 max-w-xs mb-4">
              {activeTab === 'active'
                ? 'أنشئ خطتك الدراسية للفصل الحالي وابدأ بإضافة المقررات والمهام.'
                : 'الخطط التي تؤرشفها ستظهر هنا مع الاحتفاظ بكامل بياناتها السابقة.'}
            </p>
            {activeTab === 'active' && (
              <button
                onClick={openAddModal}
                className="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs shadow-xs flex items-center gap-1.5"
              >
                <Plus className="w-4 h-4" />
                <span>إنشاء خطة دراسية جديدة</span>
              </button>
            )}
          </div>
        ) : (
          <div className="space-y-3">
            {currentList.map((plan) => {
              const isActive = plan.id === activePlanId && plan.status === 'active';
              const coursesCount = plan.courses.length;
              const creditHoursSum = plan.courses.reduce((s, c) => s + (c.creditHours || 0), 0);

              return (
                <div
                  key={plan.id}
                  className={`p-4 sm:p-5 rounded-2xl border transition-all ${
                    isActive
                      ? 'bg-blue-50/40 dark:bg-blue-950/20 border-blue-400 dark:border-blue-600 shadow-xs'
                      : 'bg-white dark:bg-[#1E293B] border-slate-200 dark:border-slate-800'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex-1">
                      <div className="flex flex-wrap items-center gap-2 mb-1.5">
                        <h3 className="text-base font-bold text-slate-900 dark:text-white">
                          {plan.name}
                        </h3>
                        {isActive && (
                          <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-blue-600 text-white flex items-center gap-1">
                            <CheckCircle2 className="w-3 h-3" />
                            <span>الخطة النشطة</span>
                          </span>
                        )}
                        {plan.status === 'archived' && (
                          <span className="px-2.5 py-0.5 rounded-full text-[11px] font-bold bg-purple-100 dark:bg-purple-950/80 text-purple-700 dark:text-purple-300">
                            مؤرشفة
                          </span>
                        )}
                      </div>

                      {(plan.academicYear || plan.semester) && (
                        <div className="flex items-center gap-3 text-xs text-slate-500 dark:text-slate-400 mb-2">
                          {plan.academicYear && (
                            <span className="flex items-center gap-1">
                              <Calendar className="w-3.5 h-3.5" />
                              <span>{plan.academicYear}</span>
                            </span>
                          )}
                          {plan.semester && (
                            <span className="flex items-center gap-1">
                              <GraduationCap className="w-3.5 h-3.5" />
                              <span>{plan.semester}</span>
                            </span>
                          )}
                        </div>
                      )}

                      <div className="flex items-center gap-3 text-xs text-slate-600 dark:text-slate-300 font-semibold mt-2">
                        <span className="flex items-center gap-1.5">
                          <BookOpen className="w-4 h-4 text-blue-500" />
                          <span>{coursesCount} مقرر</span>
                        </span>
                        <span>•</span>
                        <span>{creditHoursSum} ساعة معتمدة</span>
                      </div>
                    </div>

                    {/* Actions Menu */}
                    <div className="flex items-center gap-1">
                      <button
                        onClick={() => openEditModal(plan)}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-blue-600 dark:hover:text-blue-400 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
                        title="تعديل بيانات الخطة"
                      >
                        <Edit2 className="w-4 h-4" />
                      </button>

                      {plan.status === 'active' ? (
                        <button
                          onClick={() => archivePlan(plan.id)}
                          className="p-1.5 rounded-lg text-slate-400 hover:text-purple-600 dark:hover:text-purple-400 hover:bg-purple-50 dark:hover:bg-purple-950/30 transition-colors"
                          title="أرشفة الخطة"
                        >
                          <Archive className="w-4 h-4" />
                        </button>
                      ) : (
                        <button
                          onClick={() => restorePlan(plan.id)}
                          className="p-1.5 rounded-lg text-slate-400 hover:text-emerald-600 dark:hover:text-emerald-400 hover:bg-emerald-50 dark:hover:bg-emerald-950/30 transition-colors"
                          title="استعادة الخطة"
                        >
                          <RotateCcw className="w-4 h-4" />
                        </button>
                      )}

                      <button
                        onClick={() => setPlanToDelete(plan)}
                        className="p-1.5 rounded-lg text-slate-400 hover:text-red-600 dark:hover:text-red-400 hover:bg-red-50 dark:hover:bg-red-950/30 transition-colors"
                        title="حذف الخطة"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </div>

                  {/* Bottom Action Buttons */}
                  <div className="mt-4 pt-3 border-t border-slate-100 dark:border-slate-800 flex items-center justify-between gap-3">
                    <button
                      onClick={() => handleOpenPlan(plan)}
                      className="flex-1 py-2 px-3 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold text-xs flex items-center justify-center gap-1.5 transition-all shadow-xs"
                    >
                      <span>عرض مقررات الخطة</span>
                      <ChevronLeft className="w-4 h-4" />
                    </button>

                    {plan.status === 'active' && !isActive && (
                      <button
                        onClick={() => setActivePlan(plan.id)}
                        className="py-2 px-3 rounded-xl border border-blue-300 dark:border-blue-700 text-blue-600 dark:text-blue-400 hover:bg-blue-50 dark:hover:bg-blue-950/40 text-xs font-bold transition-all"
                      >
                        تعيين كخطة نشطة
                      </button>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </main>

      {/* Floating Add Plan Button */}
      <button
        onClick={openAddModal}
        className="fixed bottom-20 left-6 z-40 px-5 py-3.5 rounded-2xl bg-blue-600 hover:bg-blue-700 active:scale-95 text-white font-bold text-sm shadow-xl flex items-center gap-2 transition-all"
        title="إنشاء خطة دراسية"
      >
        <Plus className="w-5 h-5 stroke-[2.5]" />
        <span>خطة جديدة</span>
      </button>

      {/* Add / Edit Plan Modal */}
      {isModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-3xl max-w-md w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-800 animate-in fade-in zoom-in-95 duration-150">
            <div className="flex items-center justify-between mb-4">
              <h3 className="text-base font-bold text-slate-900 dark:text-white">
                {editingPlan ? 'تعديل بيانات الخطة الدراسية' : 'إنشاء خطة دراسية جديدة'}
              </h3>
              <button
                onClick={() => setIsModalOpen(false)}
                className="p-1 rounded-xl text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <form onSubmit={handleSubmit} className="space-y-4">
              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  اسم الخطة الدراسية *
                </label>
                <input
                  type="text"
                  autoFocus
                  required
                  value={planName}
                  onChange={(e) => {
                    setPlanName(e.target.value);
                    if (nameError) setNameError(null);
                  }}
                  placeholder="مثال: الفصل الدراسي الأول 2026-2027"
                  className={`w-full px-4 py-2.5 rounded-xl border text-xs bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white placeholder:text-slate-400 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all ${
                    nameError ? 'border-red-500' : 'border-slate-300 dark:border-slate-700'
                  }`}
                />
                {nameError && <p className="text-xs text-red-500 mt-1">{nameError}</p>}
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  العام الأكاديمي (اختياري)
                </label>
                <input
                  type="text"
                  value={academicYear}
                  onChange={(e) => setAcademicYear(e.target.value)}
                  placeholder="مثال: 2026-2027"
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

              <div>
                <label className="block text-xs font-bold text-slate-700 dark:text-slate-300 mb-1.5">
                  الفصل الدراسي (اختياري)
                </label>
                <input
                  type="text"
                  value={semester}
                  onChange={(e) => setSemester(e.target.value)}
                  placeholder="مثال: الفصل الأول / الفصل الثاني / صيفي"
                  className="w-full px-4 py-2.5 rounded-xl border border-slate-300 dark:border-slate-700 bg-slate-50/50 dark:bg-slate-900/50 text-slate-900 dark:text-white text-xs focus:outline-none focus:ring-2 focus:ring-blue-500"
                />
              </div>

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
                  {editingPlan ? 'حفظ التعديلات' : 'إنشاء الخطة'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Dialog */}
      {planToDelete && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs">
          <div className="bg-white dark:bg-[#1E293B] rounded-2xl max-w-sm w-full p-6 shadow-2xl border border-slate-200 dark:border-slate-700 animate-in fade-in zoom-in-95 duration-150">
            <h3 className="text-base font-bold text-slate-900 dark:text-white mb-2">
              حذف الخطة الدراسية
            </h3>
            <p className="text-xs text-slate-600 dark:text-slate-300 mb-6 leading-relaxed">
              هل أنت متأكد من رغبتك في حذف &quot;{planToDelete.name}&quot;؟ سيتم حذف جميع المقررات والمحاضرات والمهام وسجلات الحضور التابعة لهذه الخطة نهائياً.
            </p>
            <div className="flex gap-3 justify-end">
              <button
                onClick={() => setPlanToDelete(null)}
                className="px-4 py-2 rounded-xl text-xs font-medium text-slate-700 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-800 transition-colors"
              >
                إلغاء
              </button>
              <button
                onClick={() => {
                  deletePlan(planToDelete.id);
                  setPlanToDelete(null);
                }}
                className="px-4 py-2 rounded-xl text-xs font-bold bg-red-600 text-white hover:bg-red-700 transition-colors shadow-xs"
              >
                حذف الخطة
              </button>
            </div>
          </div>
        </div>
      )}

      <UniversityBottomNavBar currentRoute="/university" onNavigate={onNavigate} />
    </div>
  );
};
