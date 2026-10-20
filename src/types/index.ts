// Core data models for Task Manager V2

export interface TaskModel {
  id: string;
  title: string;
  description: string;
  isCompleted: boolean;
  createdAt: string; // ISO date string
}

export type UniversityTaskCategory =
  | 'study'      // مذاكرة
  | 'practice'   // تطبيق
  | 'homework'   // واجبات / تكاليف
  | 'summary'    // ملخص
  | 'review'     // مراجعة
  | 'custom';    // مهمة مخصصة

export const UNIVERSITY_TASK_CATEGORIES: {
  key: UniversityTaskCategory;
  name: string;
  color: string;
  bgColor: string;
}[] = [
  { key: 'study', name: 'مذاكرة', color: '#2563EB', bgColor: 'rgba(37, 99, 235, 0.12)' },
  { key: 'practice', name: 'تطبيق عملي', color: '#059669', bgColor: 'rgba(5, 150, 105, 0.12)' },
  { key: 'homework', name: 'واجبات / تكاليف', color: '#D97706', bgColor: 'rgba(217, 119, 6, 0.12)' },
  { key: 'summary', name: 'ملخص', color: '#7C3AED', bgColor: 'rgba(124, 58, 237, 0.12)' },
  { key: 'review', name: 'مراجعة', color: '#0891B2', bgColor: 'rgba(8, 145, 178, 0.12)' },
  { key: 'custom', name: 'مهمة مخصصة', color: '#64748B', bgColor: 'rgba(100, 116, 139, 0.12)' },
];

export function getCategoryDisplayName(category: UniversityTaskCategory | string): string {
  switch (category) {
    case 'study': return 'مذاكرة';
    case 'practice': return 'تطبيق';
    case 'homework': return 'تكاليف';
    case 'summary': return 'ملخص';
    case 'review': return 'مراجعة';
    case 'custom': return 'مهمة مخصصة';
    default: return category || 'مهمة مخصصة';
  }
}

export type UniversityTaskStatus =
  | 'notStarted' // لم تبدأ
  | 'inProgress' // قيد التنفيذ
  | 'completed'; // مكتملة

export function getStatusDisplayName(status: UniversityTaskStatus): string {
  switch (status) {
    case 'completed': return 'مكتملة';
    case 'inProgress': return 'قيد التنفيذ';
    case 'notStarted': return 'لم تبدأ';
    default: return 'لم تبدأ';
  }
}

export interface UniversityTaskModel {
  id: string;
  lectureId: string;
  courseId: string;
  title: string;
  category: UniversityTaskCategory | string;
  status: UniversityTaskStatus;
  createdAt: string;
  isRequired?: boolean;
}

export type LectureSection =
  | 'theoretical' // نظري
  | 'practical';  // عملي

export type AttendanceStatus =
  | 'none'       // لم يسجل
  | 'present'    // حاضر
  | 'absent'     // غائب
  | 'cancelled'; // ملغي (أُلغيت من قبل الجامعة أو الدكتور)

export function getAttendanceStatusDisplayName(status: AttendanceStatus): string {
  switch (status) {
    case 'present': return 'حاضر';
    case 'absent': return 'غائب';
    case 'cancelled': return 'ملغي';
    case 'none':
    default:
      return 'لم يسجل';
  }
}

export interface LectureModel {
  id: string;
  courseId: string;
  courseName: string;
  section: LectureSection;
  lectureNumber: number;
  title: string;
  attendanceStatus: AttendanceStatus;
  lectureDate: string | null; // e.g. "2026-10-20"
  cancellationReason?: string; // سبب الإلغاء إذا كانت ملغاة
  notes: string;
  tasks: UniversityTaskModel[];
}

// Task Type Configuration per course (التطوير الثالث: المهام الأكاديمية الاختيارية والمخصصة)
export interface TaskTypeConfig {
  key: string; // 'attendance' | 'study' | 'homework' | 'notes' | custom id
  name: string;
  enabled: boolean;
  isCustom?: boolean;
}

// Academic Assessment / Grading Model (التطوير السابع: الأحداث الأكاديمية والتقييمات والدرجات)
export type AssessmentSection = 'theoretical' | 'practical' | 'final';

export interface AssessmentModel {
  id: string;
  name: string;
  section: AssessmentSection;
  maxScore: number;
  isCompleted: boolean;
  actualScore?: number | null; // الدرجة الفعلية للطالب إن وجدت
  notes?: string;
}

export interface CourseModel {
  id: string;
  planId?: string; // الخطة الدراسية التابع لها المقرر
  name: string;
  creditHours: number;
  instructorName: string; // دكتور النظري
  practicalInstructorName?: string; // دكتور العملي (إن وجد)
  hasPractical: boolean;
  theoryLecturesCount: number;
  practicalLecturesCount: number;
  // Optional & Custom Task Configurations
  theoryTaskConfigs: TaskTypeConfig[];
  practicalTaskConfigs: TaskTypeConfig[];
  // Academic Assessments & Grading (sum of maxScore <= 100)
  assessments: AssessmentModel[];
  lectures: LectureModel[];
}

// Study Plan Model (التطوير الأول: إنشاء الخطط الدراسية)
export interface StudyPlanModel {
  id: string;
  name: string; // اسم الخطة، مثل "الفصل الأول 2026-2027"
  academicYear?: string; // العام الدراسي
  semester?: string; // الفصل الدراسي
  status: 'active' | 'archived'; // حالة الخطة
  createdAt: string;
  courses: CourseModel[];
}

export type AppRoute =
  | '/splash'
  | '/login'
  | '/mode-selection'
  | '/home'
  | '/tasks'
  | '/archive'
  | '/settings'
  | '/foundation'
  | '/university'
  | '/university/plans'
  | '/university/courses'
  | `/university/courses/${string}`
  | `/university/lectures/${string}/${string}`
  | '/university/today'
  | '/university/week';
