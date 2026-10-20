import React, { createContext, useContext, useEffect, useState, useMemo } from 'react';
import {
  StudyPlanModel,
  CourseModel,
  LectureModel,
  UniversityTaskModel,
  UniversityTaskCategory,
  UniversityTaskStatus,
  AttendanceStatus,
  TaskTypeConfig,
  AssessmentModel,
} from '../types';

interface AddCourseParams {
  name: string;
  creditHours: number;
  instructorName: string;
  practicalInstructorName?: string;
  hasPractical: boolean;
  theoryLecturesCount: number;
  practicalLecturesCount: number;
  theoryTaskConfigs?: TaskTypeConfig[];
  practicalTaskConfigs?: TaskTypeConfig[];
  autoTasks?: boolean;
}

interface UniversityContextType {
  // Plans (التطوير الأول: إنشاء الخطط الدراسية)
  plans: StudyPlanModel[];
  activePlanId: string | null;
  activePlan: StudyPlanModel | undefined;
  addPlan: (name: string, academicYear?: string, semester?: string) => string;
  updatePlan: (id: string, name: string, academicYear?: string, semester?: string) => void;
  deletePlan: (id: string) => void;
  setActivePlan: (id: string) => void;
  archivePlan: (id: string) => void;
  restorePlan: (id: string) => void;

  // Active Plan's Courses & Mode
  courses: CourseModel[];
  activeMode: 'normal' | 'university';
  setActiveMode: (mode: 'normal' | 'university') => void;

  // Course CRUD
  addCourse: (params: AddCourseParams) => void;
  updateCourse: (
    courseId: string,
    name: string,
    creditHours: number,
    instructorName: string,
    practicalInstructorName?: string,
    theoryTaskConfigs?: TaskTypeConfig[],
    practicalTaskConfigs?: TaskTypeConfig[]
  ) => void;
  deleteCourse: (courseId: string) => void;

  // Lecture Operations
  recordAttendance: (
    courseId: string,
    lectureId: string,
    status: AttendanceStatus,
    customDate?: string,
    cancellationReason?: string
  ) => void;
  completeAllLectureTasks: (courseId: string, lectureId: string) => void;
  updateLectureNotes: (courseId: string, lectureId: string, notes: string) => void;

  // Lecture Tasks CRUD
  addLectureTask: (
    courseId: string,
    lectureId: string,
    title: string,
    category: UniversityTaskCategory | string
  ) => void;
  updateTaskStatus: (
    courseId: string,
    lectureId: string,
    taskId: string,
    status: UniversityTaskStatus
  ) => void;
  updateTask: (
    courseId: string,
    lectureId: string,
    taskId: string,
    title: string,
    category: UniversityTaskCategory | string
  ) => void;
  deleteTask: (courseId: string, lectureId: string, taskId: string) => void;

  // Assessments & Grading (التطوير السابع: الأحداث الأكاديمية والتقييمات والدرجات)
  addAssessment: (
    courseId: string,
    assessment: Omit<AssessmentModel, 'id'>
  ) => { success: boolean; error?: string };
  updateAssessment: (
    courseId: string,
    assessmentId: string,
    data: Partial<AssessmentModel>
  ) => { success: boolean; error?: string };
  deleteAssessment: (courseId: string, assessmentId: string) => void;

  // Lookup helpers
  getCourse: (courseId: string) => CourseModel | undefined;
  getLecture: (courseId: string, lectureId: string) => LectureModel | undefined;
  getLecturesRecordedOn: (dateString: string) => LectureModel[];
  getLecturesRecordedInDates: (datesSet: Set<string>) => LectureModel[];
  resetAllUniversityData: () => void;

  // Active Plan Real-time Stats (التطوير الثاني)
  totalCourses: number;
  totalCreditHours: number;
  totalLectures: number;
  recordedLectures: number;
  totalPresent: number;
  totalAbsent: number;
  totalCancelled: number;
  attendanceRate: number; // 0 to 100% excluding cancelled
  completedLecturesCount: number; // محاضرات أُنجزت كل مهامها المطلوبة
  lectureCompletionRate: number; // 0 to 100%
  totalTasks: number;
  completedTasks: number;
  pendingTasks: number;
  overallProgress: number; // 0.0 to 1.0
}

const UniversityContext = createContext<UniversityContextType | undefined>(undefined);

const KEY_PLANS = 'v2_university_study_plans';
const KEY_ACTIVE_PLAN_ID = 'v2_active_study_plan_id';
const KEY_ACTIVE_MODE = 'v2_active_task_mode';
const KEY_LEGACY_COURSES = 'v2_university_courses';

export function getTodayString(): string {
  const now = new Date();
  return formatDate(now);
}

export function formatDate(dt: Date): string {
  const y = dt.getFullYear();
  const m = String(dt.getMonth() + 1).padStart(2, '0');
  const d = String(dt.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

export const DEFAULT_TASK_CONFIGS: TaskTypeConfig[] = [
  { key: 'attendance', name: 'الحضور والغياب', enabled: true },
  { key: 'study', name: 'المذاكرة', enabled: true },
  { key: 'homework', name: 'التكاليف والواجبات', enabled: true },
  { key: 'notes', name: 'الملاحظات', enabled: true },
];

function generateDefaultTasksFromConfigs(
  lectureId: string,
  courseId: string,
  configs: TaskTypeConfig[]
): UniversityTaskModel[] {
  const now = new Date().toISOString();
  const tasks: UniversityTaskModel[] = [];

  const studyConfig = configs.find((c) => c.key === 'study' && c.enabled);
  if (studyConfig) {
    tasks.push({
      id: `${lectureId}_task_study`,
      lectureId,
      courseId,
      title: 'مذاكرة محتوى المحاضرة',
      category: 'study',
      status: 'notStarted',
      createdAt: now,
      isRequired: true,
    });
  }

  const homeworkConfig = configs.find((c) => c.key === 'homework' && c.enabled);
  if (homeworkConfig) {
    tasks.push({
      id: `${lectureId}_task_hw`,
      lectureId,
      courseId,
      title: 'حل واجبات المحاضرة',
      category: 'homework',
      status: 'notStarted',
      createdAt: now,
      isRequired: true,
    });
  }

  // Any custom enabled configs
  configs
    .filter((c) => c.isCustom && c.enabled)
    .forEach((custom) => {
      tasks.push({
        id: `${lectureId}_task_${custom.key}`,
        lectureId,
        courseId,
        title: custom.name,
        category: 'custom',
        status: 'notStarted',
        createdAt: now,
        isRequired: true,
      });
    });

  return tasks;
}

export function generateLecturesForCourse(params: {
  courseId: string;
  courseName: string;
  hasPractical: boolean;
  theoryCount: number;
  practicalCount: number;
  theoryConfigs?: TaskTypeConfig[];
  practicalConfigs?: TaskTypeConfig[];
  autoTasks?: boolean;
}): LectureModel[] {
  const {
    courseId,
    courseName,
    hasPractical,
    theoryCount,
    practicalCount,
    theoryConfigs = DEFAULT_TASK_CONFIGS,
    practicalConfigs = DEFAULT_TASK_CONFIGS,
    autoTasks = true,
  } = params;

  const lectures: LectureModel[] = [];

  // Theoretical lectures
  for (let i = 1; i <= theoryCount; i++) {
    const lectureId = `${courseId}_theory_${i}`;
    const tasks = autoTasks
      ? generateDefaultTasksFromConfigs(lectureId, courseId, theoryConfigs)
      : [];

    lectures.push({
      id: lectureId,
      courseId,
      courseName,
      section: 'theoretical',
      lectureNumber: i,
      title: `المحاضرة ${i}`,
      attendanceStatus: 'none',
      lectureDate: null,
      notes: '',
      tasks,
    });
  }

  // Practical lectures
  if (hasPractical) {
    for (let i = 1; i <= practicalCount; i++) {
      const lectureId = `${courseId}_practical_${i}`;
      const tasks = autoTasks
        ? generateDefaultTasksFromConfigs(lectureId, courseId, practicalConfigs)
        : [];

      lectures.push({
        id: lectureId,
        courseId,
        courseName,
        section: 'practical',
        lectureNumber: i,
        title: `المحاضرة العملية ${i}`,
        attendanceStatus: 'none',
        lectureDate: null,
        notes: '',
        tasks,
      });
    }
  }

  return lectures;
}

// Initial Sample Plan Generator
function generateSamplePlans(): StudyPlanModel[] {
  const today = getTodayString();
  const planId = 'plan_term_1';

  // Course 1: Data Structures
  const cs101Id = 'course_cs101';
  const cs101Lectures = generateLecturesForCourse({
    courseId: cs101Id,
    courseName: 'تراكيب البيانات والخوارزميات',
    hasPractical: true,
    theoryCount: 12,
    practicalCount: 10,
    autoTasks: true,
  });

  const cs101Updated = cs101Lectures.map((l) => {
    if (l.lectureNumber === 1 && l.section === 'theoretical') {
      return {
        ...l,
        attendanceStatus: 'present' as AttendanceStatus,
        lectureDate: today,
        notes: 'شرح مقدمة في تعقيد الخوارزميات (Big O Notation) ومصفوفات الذاكرة.',
      };
    }
    return l;
  });

  const course1Assessments: AssessmentModel[] = [
    {
      id: 'as_1',
      name: 'اختبار نصفي نظري',
      section: 'theoretical',
      maxScore: 20,
      isCompleted: false,
      actualScore: null,
    },
    {
      id: 'as_2',
      name: 'تكاليف ومشاريع العملي',
      section: 'practical',
      maxScore: 20,
      isCompleted: false,
      actualScore: null,
    },
    {
      id: 'as_3',
      name: 'اختبار عملي نهائي',
      section: 'practical',
      maxScore: 20,
      isCompleted: false,
      actualScore: null,
    },
    {
      id: 'as_4',
      name: 'الاختبار النهائي العام للمقرر',
      section: 'final',
      maxScore: 40,
      isCompleted: false,
      actualScore: null,
    },
  ];

  const course1: CourseModel = {
    id: cs101Id,
    planId,
    name: 'تراكيب البيانات والخوارزميات',
    creditHours: 3,
    instructorName: 'د. أحمد المهدي',
    practicalInstructorName: 'م. خالد المنصور',
    hasPractical: true,
    theoryLecturesCount: 12,
    practicalLecturesCount: 10,
    theoryTaskConfigs: [...DEFAULT_TASK_CONFIGS],
    practicalTaskConfigs: [...DEFAULT_TASK_CONFIGS],
    assessments: course1Assessments,
    lectures: cs101Updated,
  };

  // Course 2: Database Systems
  const db201Id = 'course_db201';
  const db201Lectures = generateLecturesForCourse({
    courseId: db201Id,
    courseName: 'نظم قواعد البيانات',
    hasPractical: false,
    theoryCount: 12,
    practicalCount: 0,
    autoTasks: true,
  });

  const course2Assessments: AssessmentModel[] = [
    {
      id: 'as_db_1',
      name: 'اختبار نصفي',
      section: 'theoretical',
      maxScore: 30,
      isCompleted: false,
      actualScore: null,
    },
    {
      id: 'as_db_2',
      name: 'أعمال فصلية وتكاليف',
      section: 'theoretical',
      maxScore: 20,
      isCompleted: false,
      actualScore: null,
    },
    {
      id: 'as_db_3',
      name: 'الاختبار النهائي للمقرر',
      section: 'final',
      maxScore: 50,
      isCompleted: false,
      actualScore: null,
    },
  ];

  const course2: CourseModel = {
    id: db201Id,
    planId,
    name: 'نظم قواعد البيانات',
    creditHours: 3,
    instructorName: 'د. منى الشريف',
    hasPractical: false,
    theoryLecturesCount: 12,
    practicalLecturesCount: 0,
    theoryTaskConfigs: [...DEFAULT_TASK_CONFIGS],
    practicalTaskConfigs: [...DEFAULT_TASK_CONFIGS],
    assessments: course2Assessments,
    lectures: db201Lectures,
  };

  const plan1: StudyPlanModel = {
    id: planId,
    name: 'خطة الفصل الدراسي الأول 2026-2027',
    academicYear: '2026-2027',
    semester: 'الفصل الأول',
    status: 'active',
    createdAt: new Date().toISOString(),
    courses: [course1, course2],
  };

  return [plan1];
}

export const UniversityProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  // Load plans with backward-compatibility migration
  const [plans, setPlans] = useState<StudyPlanModel[]>(() => {
    const saved = localStorage.getItem(KEY_PLANS);
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        if (Array.isArray(parsed) && parsed.length > 0) return parsed;
      } catch (e) {
        console.error('Error parsing plans', e);
      }
    }

    // Check if legacy courses exist and migrate them into a plan
    const legacy = localStorage.getItem(KEY_LEGACY_COURSES);
    if (legacy) {
      try {
        const parsedCourses = JSON.parse(legacy);
        if (Array.isArray(parsedCourses) && parsedCourses.length > 0) {
          const migratedPlanId = 'plan_migrated_1';
          const migratedCourses = parsedCourses.map((c: any) => ({
            ...c,
            planId: migratedPlanId,
            theoryTaskConfigs: c.theoryTaskConfigs || [...DEFAULT_TASK_CONFIGS],
            practicalTaskConfigs: c.practicalTaskConfigs || [...DEFAULT_TASK_CONFIGS],
            assessments: c.assessments || [],
          }));
          return [
            {
              id: migratedPlanId,
              name: 'الخطة الدراسية الأساسية',
              status: 'active' as const,
              createdAt: new Date().toISOString(),
              courses: migratedCourses,
            },
          ];
        }
      } catch (e) {
        console.error('Error migrating legacy courses', e);
      }
    }

    return generateSamplePlans();
  });

  const [activePlanId, setActivePlanIdState] = useState<string | null>(() => {
    const saved = localStorage.getItem(KEY_ACTIVE_PLAN_ID);
    if (saved) return saved;
    return null;
  });

  const [activeMode, setActiveModeState] = useState<'normal' | 'university'>(() => {
    return (localStorage.getItem(KEY_ACTIVE_MODE) as 'normal' | 'university') || 'university';
  });

  // Ensure an active plan is selected if available
  useEffect(() => {
    if (!activePlanId || !plans.some((p) => p.id === activePlanId && p.status === 'active')) {
      const activeOne = plans.find((p) => p.status === 'active') || plans[0];
      if (activeOne) {
        setActivePlanIdState(activeOne.id);
        localStorage.setItem(KEY_ACTIVE_PLAN_ID, activeOne.id);
      }
    }
  }, [plans, activePlanId]);

  useEffect(() => {
    localStorage.setItem(KEY_PLANS, JSON.stringify(plans));
  }, [plans]);

  const setActiveMode = (mode: 'normal' | 'university') => {
    localStorage.setItem(KEY_ACTIVE_MODE, mode);
    setActiveModeState(mode);
  };

  const setActivePlan = (id: string) => {
    localStorage.setItem(KEY_ACTIVE_PLAN_ID, id);
    setActivePlanIdState(id);
  };

  // Plan Management
  const addPlan = (name: string, academicYear?: string, semester?: string): string => {
    const id = `plan_${Date.now()}`;
    const newPlan: StudyPlanModel = {
      id,
      name: name.trim(),
      academicYear: academicYear?.trim() || undefined,
      semester: semester?.trim() || undefined,
      status: 'active',
      createdAt: new Date().toISOString(),
      courses: [],
    };
    setPlans((prev) => [...prev, newPlan]);
    setActivePlan(id);
    return id;
  };

  const updatePlan = (id: string, name: string, academicYear?: string, semester?: string) => {
    setPlans((prev) =>
      prev.map((p) =>
        p.id === id
          ? {
              ...p,
              name: name.trim(),
              academicYear: academicYear?.trim() || undefined,
              semester: semester?.trim() || undefined,
            }
          : p
      )
    );
  };

  const deletePlan = (id: string) => {
    setPlans((prev) => prev.filter((p) => p.id !== id));
    if (activePlanId === id) {
      const remaining = plans.filter((p) => p.id !== id);
      if (remaining.length > 0) {
        setActivePlan(remaining[0].id);
      } else {
        setActivePlanIdState(null);
        localStorage.removeItem(KEY_ACTIVE_PLAN_ID);
      }
    }
  };

  const archivePlan = (id: string) => {
    setPlans((prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: 'archived' } : p))
    );
    if (activePlanId === id) {
      const otherActive = plans.find((p) => p.id !== id && p.status === 'active');
      if (otherActive) {
        setActivePlan(otherActive.id);
      }
    }
  };

  const restorePlan = (id: string) => {
    setPlans((prev) =>
      prev.map((p) => (p.id === id ? { ...p, status: 'active' } : p))
    );
  };

  const activePlan = useMemo(() => {
    return plans.find((p) => p.id === activePlanId);
  }, [plans, activePlanId]);

  // Courses in active plan only
  const courses = useMemo(() => {
    return activePlan ? activePlan.courses : [];
  }, [activePlan]);

  // Helper to update courses inside the active plan
  const updateActivePlanCourses = (updater: (prevCourses: CourseModel[]) => CourseModel[]) => {
    if (!activePlanId) return;
    setPlans((prevPlans) =>
      prevPlans.map((plan) => {
        if (plan.id === activePlanId) {
          return { ...plan, courses: updater(plan.courses) };
        }
        return plan;
      })
    );
  };

  // Add Course to Active Plan
  const addCourse = (params: AddCourseParams) => {
    if (!activePlanId) return;

    const courseId = `course_${Date.now()}`;
    const theoryConfigs = params.theoryTaskConfigs || [...DEFAULT_TASK_CONFIGS];
    const practicalConfigs = params.practicalTaskConfigs || [...DEFAULT_TASK_CONFIGS];

    const lectures = generateLecturesForCourse({
      courseId,
      courseName: params.name,
      hasPractical: params.hasPractical,
      theoryCount: params.theoryLecturesCount,
      practicalCount: params.practicalLecturesCount,
      theoryConfigs,
      practicalConfigs,
      autoTasks: params.autoTasks !== false,
    });

    const newCourse: CourseModel = {
      id: courseId,
      planId: activePlanId,
      name: params.name,
      creditHours: params.creditHours,
      instructorName: params.instructorName,
      practicalInstructorName: params.hasPractical ? params.practicalInstructorName : undefined,
      hasPractical: params.hasPractical,
      theoryLecturesCount: params.theoryLecturesCount,
      practicalLecturesCount: params.practicalLecturesCount,
      theoryTaskConfigs: theoryConfigs,
      practicalTaskConfigs: practicalConfigs,
      assessments: [],
      lectures,
    };

    updateActivePlanCourses((prev) => [...prev, newCourse]);
  };

  // Update Course Metadata
  const updateCourse = (
    courseId: string,
    name: string,
    creditHours: number,
    instructorName: string,
    practicalInstructorName?: string,
    theoryTaskConfigs?: TaskTypeConfig[],
    practicalTaskConfigs?: TaskTypeConfig[]
  ) => {
    updateActivePlanCourses((prev) =>
      prev.map((c) => {
        if (c.id === courseId) {
          const updatedLectures = c.lectures.map((l) => ({ ...l, courseName: name }));
          return {
            ...c,
            name,
            creditHours,
            instructorName,
            practicalInstructorName: c.hasPractical ? practicalInstructorName : undefined,
            theoryTaskConfigs: theoryTaskConfigs || c.theoryTaskConfigs,
            practicalTaskConfigs: practicalTaskConfigs || c.practicalTaskConfigs,
            lectures: updatedLectures,
          };
        }
        return c;
      })
    );
  };

  // Delete Course
  const deleteCourse = (courseId: string) => {
    updateActivePlanCourses((prev) => prev.filter((c) => c.id !== courseId));
  };

  // Record Attendance (supports 'present', 'absent', 'cancelled', and cancellation reason)
  const recordAttendance = (
    courseId: string,
    lectureId: string,
    status: AttendanceStatus,
    customDate?: string,
    cancellationReason?: string
  ) => {
    const targetDate = status === 'none' ? null : (customDate || getTodayString());

    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              return {
                ...lecture,
                attendanceStatus: status,
                lectureDate: targetDate,
                cancellationReason:
                  status === 'cancelled'
                    ? cancellationReason || lecture.cancellationReason || ''
                    : undefined,
              };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  // التطوير الرابع: زر «تم إنجاز جميع المهام»
  // Marks all enabled/required tasks for that lecture as completed (only if not cancelled)
  const completeAllLectureTasks = (courseId: string, lectureId: string) => {
    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              if (lecture.attendanceStatus === 'cancelled') return lecture; // Do not complete cancelled
              const updatedTasks = lecture.tasks.map((task) => ({
                ...task,
                status: 'completed' as UniversityTaskStatus,
              }));
              return { ...lecture, tasks: updatedTasks };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  const updateLectureNotes = (courseId: string, lectureId: string, notes: string) => {
    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              return { ...lecture, notes };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  const addLectureTask = (
    courseId: string,
    lectureId: string,
    title: string,
    category: UniversityTaskCategory | string
  ) => {
    const newTask: UniversityTaskModel = {
      id: `task_${Date.now()}`,
      lectureId,
      courseId,
      title,
      category,
      status: 'notStarted',
      createdAt: new Date().toISOString(),
      isRequired: true,
    };

    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              return { ...lecture, tasks: [...lecture.tasks, newTask] };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  const updateTaskStatus = (
    courseId: string,
    lectureId: string,
    taskId: string,
    status: UniversityTaskStatus
  ) => {
    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              const updatedTasks = lecture.tasks.map((task) =>
                task.id === taskId ? { ...task, status } : task
              );
              return { ...lecture, tasks: updatedTasks };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  const updateTask = (
    courseId: string,
    lectureId: string,
    taskId: string,
    title: string,
    category: UniversityTaskCategory | string
  ) => {
    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              const updatedTasks = lecture.tasks.map((task) =>
                task.id === taskId ? { ...task, title, category } : task
              );
              return { ...lecture, tasks: updatedTasks };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  const deleteTask = (courseId: string, lectureId: string, taskId: string) => {
    updateActivePlanCourses((prev) =>
      prev.map((course) => {
        if (course.id === courseId) {
          const updatedLectures = course.lectures.map((lecture) => {
            if (lecture.id === lectureId) {
              const updatedTasks = lecture.tasks.filter((task) => task.id !== taskId);
              return { ...lecture, tasks: updatedTasks };
            }
            return lecture;
          });
          return { ...course, lectures: updatedLectures };
        }
        return course;
      })
    );
  };

  // Assessments & Grading (التطوير السابع: الأحداث الأكاديمية والتقييمات والدرجات)
  const addAssessment = (
    courseId: string,
    assessmentData: Omit<AssessmentModel, 'id'>
  ): { success: boolean; error?: string } => {
    const course = courses.find((c) => c.id === courseId);
    if (!course) return { success: false, error: 'المقرر غير موجود' };

    const currentTotal = course.assessments.reduce((sum, a) => sum + (a.maxScore || 0), 0);
    const newMaxScore = Number(assessmentData.maxScore) || 0;

    if (newMaxScore <= 0) {
      return { success: false, error: 'يجب أن تكون الدرجة القصوى رقماً موجباً' };
    }

    if (currentTotal + newMaxScore > 100) {
      const remaining = 100 - currentTotal;
      return {
        success: false,
        error: `لا يمكن أن يتجاوز مجموع الدرجات 100. الدرجة المتبقية المتاحة هي ${remaining}`,
      };
    }

    const newAssessment: AssessmentModel = {
      ...assessmentData,
      id: `as_${Date.now()}`,
      maxScore: newMaxScore,
      isCompleted: assessmentData.isCompleted || false,
      actualScore: assessmentData.actualScore != null ? Number(assessmentData.actualScore) : null,
    };

    updateActivePlanCourses((prev) =>
      prev.map((c) =>
        c.id === courseId ? { ...c, assessments: [...c.assessments, newAssessment] } : c
      )
    );

    return { success: true };
  };

  const updateAssessment = (
    courseId: string,
    assessmentId: string,
    data: Partial<AssessmentModel>
  ): { success: boolean; error?: string } => {
    const course = courses.find((c) => c.id === courseId);
    if (!course) return { success: false, error: 'المقرر غير موجود' };

    if (data.maxScore !== undefined) {
      const newMaxScore = Number(data.maxScore) || 0;
      if (newMaxScore <= 0) {
        return { success: false, error: 'يجب أن تكون الدرجة القصوى رقماً موجباً' };
      }
      const otherTotal = course.assessments
        .filter((a) => a.id !== assessmentId)
        .reduce((sum, a) => sum + (a.maxScore || 0), 0);

      if (otherTotal + newMaxScore > 100) {
        return {
          success: false,
          error: `تعديل الدرجة سيتجاوز مجموع 100 درجة. الحد الأقصى المتاح: ${100 - otherTotal}`,
        };
      }
    }

    updateActivePlanCourses((prev) =>
      prev.map((c) => {
        if (c.id === courseId) {
          const updated = c.assessments.map((a) => {
            if (a.id === assessmentId) {
              const updatedItem = { ...a, ...data };
              if (
                updatedItem.actualScore != null &&
                updatedItem.actualScore > updatedItem.maxScore
              ) {
                updatedItem.actualScore = updatedItem.maxScore;
              }
              return updatedItem;
            }
            return a;
          });
          return { ...c, assessments: updated };
        }
        return c;
      })
    );

    return { success: true };
  };

  const deleteAssessment = (courseId: string, assessmentId: string) => {
    updateActivePlanCourses((prev) =>
      prev.map((c) =>
        c.id === courseId
          ? { ...c, assessments: c.assessments.filter((a) => a.id !== assessmentId) }
          : c
      )
    );
  };

  const resetAllUniversityData = () => {
    const sample = generateSamplePlans();
    setPlans(sample);
    if (sample.length > 0) {
      setActivePlan(sample[0].id);
    }
  };

  const getCourse = (courseId: string) => courses.find((c) => c.id === courseId);

  const getLecture = (courseId: string, lectureId: string) => {
    const course = getCourse(courseId);
    return course?.lectures.find((l) => l.id === lectureId);
  };

  const getLecturesRecordedOn = (dateString: string) => {
    const result: LectureModel[] = [];
    for (const course of courses) {
      for (const lecture of course.lectures) {
        if (lecture.lectureDate === dateString && lecture.attendanceStatus !== 'none') {
          result.push(lecture);
        }
      }
    }
    return result;
  };

  const getLecturesRecordedInDates = (datesSet: Set<string>) => {
    const result: LectureModel[] = [];
    for (const course of courses) {
      for (const lecture of course.lectures) {
        if (
          lecture.lectureDate &&
          datesSet.has(lecture.lectureDate) &&
          lecture.attendanceStatus !== 'none'
        ) {
          result.push(lecture);
        }
      }
    }
    return result;
  };

  // Real-time Statistics strictly for the ACTIVE PLAN (التطوير الثاني)
  const {
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
  } = useMemo(() => {
    let creditHoursSum = 0;
    let lecturesCount = 0;
    let recorded = 0;
    let present = 0;
    let absent = 0;
    let cancelled = 0;
    let tasks = 0;
    let completed = 0;
    let completedLectures = 0;
    let eligibleLectures = 0;

    for (const c of courses) {
      creditHoursSum += Number(c.creditHours) || 0;
      for (const l of c.lectures) {
        lecturesCount++;

        if (l.attendanceStatus === 'present') {
          recorded++;
          present++;
        } else if (l.attendanceStatus === 'absent') {
          recorded++;
          absent++;
        } else if (l.attendanceStatus === 'cancelled') {
          cancelled++;
        }

        // Cancelled lectures are excluded from tasks & lecture completion
        if (l.attendanceStatus !== 'cancelled') {
          eligibleLectures++;
          const lectureTasks = l.tasks;
          let allTasksDone = lectureTasks.length > 0;

          for (const t of lectureTasks) {
            tasks++;
            if (t.status === 'completed') {
              completed++;
            } else {
              allTasksDone = false;
            }
          }

          if (allTasksDone && lectureTasks.length > 0) {
            completedLectures++;
          }
        }
      }
    }

    // Attendance Rate = present / (present + absent) * 100 (excluding cancelled from denominator)
    const totalEligibleAttendance = present + absent;
    const rate = totalEligibleAttendance === 0 ? 0 : Math.round((present / totalEligibleAttendance) * 100);

    // Lecture completion rate = completedLectures / eligibleLectures
    const compRate =
      eligibleLectures === 0 ? 0 : Math.round((completedLectures / eligibleLectures) * 100);

    // Progress = recordedLectures / totalLectures
    const progress = lecturesCount === 0 ? 0 : (present + absent) / (lecturesCount - cancelled || 1);

    return {
      totalCourses: courses.length,
      totalCreditHours: creditHoursSum,
      totalLectures: lecturesCount,
      recordedLectures: recorded,
      totalPresent: present,
      totalAbsent: absent,
      totalCancelled: cancelled,
      attendanceRate: rate,
      completedLecturesCount: completedLectures,
      lectureCompletionRate: compRate,
      totalTasks: tasks,
      completedTasks: completed,
      pendingTasks: tasks - completed,
      overallProgress: Math.min(1.0, Math.max(0.0, progress)),
    };
  }, [courses]);

  return (
    <UniversityContext.Provider
      value={{
        plans,
        activePlanId,
        activePlan,
        addPlan,
        updatePlan,
        deletePlan,
        setActivePlan,
        archivePlan,
        restorePlan,
        courses,
        activeMode,
        setActiveMode,
        addCourse,
        updateCourse,
        deleteCourse,
        recordAttendance,
        completeAllLectureTasks,
        updateLectureNotes,
        addLectureTask,
        updateTaskStatus,
        updateTask,
        deleteTask,
        addAssessment,
        updateAssessment,
        deleteAssessment,
        resetAllUniversityData,
        getCourse,
        getLecture,
        getLecturesRecordedOn,
        getLecturesRecordedInDates,
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
      }}
    >
      {children}
    </UniversityContext.Provider>
  );
};

export const useUniversity = () => {
  const context = useContext(UniversityContext);
  if (!context) {
    throw new Error('useUniversity must be used within a UniversityProvider');
  }
  return context;
};
