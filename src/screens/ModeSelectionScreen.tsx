import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useUniversity } from '../context/UniversityContext';
import { Navbar } from '../components/Navbar';
import { CheckSquare, School, CheckCircle2, ArrowLeft } from 'lucide-react';

interface ModeSelectionScreenProps {
  onNavigate: (route: string) => void;
}

export const ModeSelectionScreen: React.FC<ModeSelectionScreenProps> = ({ onNavigate }) => {
  const { userEmail } = useAuth();
  const { setActiveMode } = useUniversity();

  const handleSelectNormal = () => {
    setActiveMode('normal');
    onNavigate('/home');
  };

  const handleSelectUniversity = () => {
    setActiveMode('university');
    onNavigate('/university');
  };

  return (
    <div className="min-h-screen bg-slate-50 dark:bg-[#0B1120] text-slate-900 dark:text-white transition-colors">
      <Navbar title="اختيار نوع المهام" onNavigate={onNavigate} />

      <main className="max-w-3xl mx-auto px-4 py-8">
        {/* Welcome Greeting Banner */}
        <div className="p-5 sm:p-6 rounded-3xl bg-gradient-to-br from-blue-50 to-indigo-50/50 dark:from-blue-950/40 dark:to-slate-800/60 border border-blue-100 dark:border-blue-900/40 mb-8 shadow-xs">
          <div className="flex items-center gap-3.5 mb-3">
            <div className="w-12 h-12 rounded-2xl bg-blue-600 text-white flex items-center justify-center shadow-md">
              <School className="w-6 h-6" />
            </div>
            <div>
              <h2 className="text-lg font-bold text-slate-900 dark:text-white">
                مرحبًا بك في تطبيق الطالب
              </h2>
              <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300">
                {userEmail}
              </p>
            </div>
          </div>
          <p className="text-xs sm:text-sm text-slate-700 dark:text-slate-300 font-medium">
            يرجى تحديد نظام إدارة المهام الذي ترغب في استخدامه الآن:
          </p>
        </div>

        {/* Options Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {/* Option 1: Normal Tasks */}
          <div className="p-6 rounded-3xl bg-white dark:bg-[#1E293B] border border-slate-200 dark:border-slate-800 shadow-sm hover:border-blue-400 dark:hover:border-blue-500 transition-all flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-3 mb-4">
                <div className="p-3 rounded-2xl bg-blue-50 dark:bg-blue-950/80 text-blue-600 dark:text-blue-400 border border-blue-200 dark:border-blue-800">
                  <CheckSquare className="w-7 h-7" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-slate-900 dark:text-white">
                    المهام العادية
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    المهام اليومية والشخصية
                  </p>
                </div>
              </div>

              <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 mb-4 leading-relaxed">
                إدارة المهام اليومية والشخصية بمرونة للمهام العادية (الغير مرتبطة بوقت محدد).
              </p>

              <hr className="border-slate-100 dark:border-slate-800 my-4" />

              <ul className="space-y-2 mb-6">
                {[
                  'قائمة المهام اليومية والشخصية',
                  'عمليات الإضافة والتعديل والحذف',
                  'نظام الأرشفة للمهام المكتملة',
                  'إحصائيات الإنجاز الشخصي',
                ].map((feat, idx) => (
                  <li key={idx} className="flex items-center gap-2 text-xs text-slate-600 dark:text-slate-300">
                    <CheckCircle2 className="w-4 h-4 text-blue-600 dark:text-blue-400 shrink-0" />
                    <span>{feat}</span>
                  </li>
                ))}
              </ul>
            </div>

            <button
              onClick={handleSelectNormal}
              className="w-full py-3 px-4 rounded-xl bg-blue-600 hover:bg-blue-700 active:scale-[0.99] text-white font-bold text-sm shadow-xs transition-all flex items-center justify-center gap-2"
            >
              <span>الدخول إلى المهام العادية</span>
              <ArrowLeft className="w-4 h-4" />
            </button>
          </div>

          {/* Option 2: University Tasks (Highlighted) */}
          <div className="p-6 rounded-3xl bg-white dark:bg-[#1E293B] border-2 border-emerald-500/80 dark:border-emerald-500 shadow-md transition-all flex flex-col justify-between relative overflow-hidden">
            <div className="absolute top-3 left-3 bg-emerald-100 dark:bg-emerald-950/80 text-emerald-700 dark:text-emerald-300 text-[10px] font-extrabold px-2 py-0.5 rounded-full border border-emerald-300 dark:border-emerald-700">
              موصى به للجامعة
            </div>

            <div>
              <div className="flex items-center gap-3 mb-4">
                <div className="p-3 rounded-2xl bg-emerald-50 dark:bg-emerald-950/80 text-emerald-600 dark:text-emerald-400 border border-emerald-200 dark:border-emerald-800">
                  <School className="w-7 h-7" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-slate-900 dark:text-white">
                    المهام الجامعية
                  </h3>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">
                    المقررات والمحاضرات والحضور
                  </p>
                </div>
              </div>

              <p className="text-xs sm:text-sm text-slate-600 dark:text-slate-300 mb-4 leading-relaxed">
                إدارة المقررات، ومهام المحاضرات النظرية والعملية من حضور ومذاكرة وتكاليف.
              </p>

              <hr className="border-slate-100 dark:border-slate-800 my-4" />

              <ul className="space-y-2 mb-6">
                {[
                  'المقررات الأكاديمية (نظري / عملي)',
                  'سجل المحاضرات وتسجيل الحضور الفعلي',
                  'تصنيف المهام (مذاكرة، تطبيق، واجبات)',
                  'احصائيات شاملة لحالة جميع المهام',
                ].map((feat, idx) => (
                  <li key={idx} className="flex items-center gap-2 text-xs text-slate-600 dark:text-slate-300">
                    <CheckCircle2 className="w-4 h-4 text-emerald-600 dark:text-emerald-400 shrink-0" />
                    <span>{feat}</span>
                  </li>
                ))}
              </ul>
            </div>

            <button
              onClick={handleSelectUniversity}
              className="w-full py-3 px-4 rounded-xl bg-emerald-600 hover:bg-emerald-700 active:scale-[0.99] text-white font-bold text-sm shadow-md transition-all flex items-center justify-center gap-2"
            >
              <span>الدخول إلى المهام الجامعية</span>
              <ArrowLeft className="w-4 h-4" />
            </button>
          </div>
        </div>

        <p className="text-center text-xs text-slate-500 dark:text-slate-400 mt-8">
          يمكنك التبديل بين النظامين في أي وقت عبر قائمة الإعدادات أو الشاشة الرئيسية.
        </p>
      </main>
    </div>
  );
};
