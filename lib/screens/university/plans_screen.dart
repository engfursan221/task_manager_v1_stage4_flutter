// ============================================================
// PLANS SCREEN (V2)
// Study Plans Management Screen:
// - Entry point to university tasks
// - Create, edit, switch, archive, restore, and delete study plans
// - Independent courses per plan
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/university/university_cubit.dart';
import '../../cubit/university/university_state.dart';
import '../../models/study_plan_model.dart';
import 'courses_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddPlanDialog(BuildContext context, {StudyPlanModel? planToEdit}) {
    final isEditing = planToEdit != null;
    final nameController = TextEditingController(text: planToEdit?.name ?? '');
    final yearController = TextEditingController(text: planToEdit?.academicYear ?? '');
    final semesterController = TextEditingController(text: planToEdit?.semester ?? '');

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            isEditing ? 'تعديل بيانات الخطة' : 'إنشاء خطة دراسية جديدة',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'اسم الخطة الدراسية *',
                    hintText: 'مثال: الفصل الأول 2026-2027',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: yearController,
                  decoration: const InputDecoration(
                    labelText: 'العام الأكاديمي (اختياري)',
                    hintText: 'مثال: 2026-2027',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(
                    labelText: 'الفصل الدراسي (اختياري)',
                    hintText: 'مثال: الفصل الأول / الثاني / صيفي',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final cubit = context.read<UniversityCubit>();
                if (isEditing) {
                  cubit.updatePlan(
                    planId: planToEdit.id,
                    name: name,
                    academicYear: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                    semester: semesterController.text.trim().isEmpty ? null : semesterController.text.trim(),
                  );
                } else {
                  cubit.addPlan(
                    name: name,
                    academicYear: yearController.text.trim().isEmpty ? null : yearController.text.trim(),
                    semester: semesterController.text.trim().isEmpty ? null : semesterController.text.trim(),
                  );
                }
                Navigator.pop(dialogCtx);
              },
              child: Text(isEditing ? 'حفظ' : 'إنشاء'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePlan(BuildContext context, StudyPlanModel plan) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الخطة الدراسية', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'هل أنت متأكد من رغبتك في حذف "${plan.name}"؟\nسيتم حذف جميع المقررات والمحاضرات والمهام وسجلات الحضور التابعة لهذه الخطة نهائياً.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<UniversityCubit>().deletePlan(plan.id);
              Navigator.pop(dialogCtx);
            },
            child: const Text('حذف نهائي', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الخطط الدراسية', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الخطط النشطة'),
            Tab(text: 'الأرشيف'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddPlanDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('خطة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: BlocConsumer<UniversityCubit, UniversityState>(
        listener: (context, state) {
          if (state is UniversityLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!)),
            );
          }
        },
        builder: (context, state) {
          if (state is UniversityLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UniversityError) {
            return Center(child: Text(state.errorMessage));
          }
          if (state is! UniversityLoaded) {
            return const SizedBox.shrink();
          }

          final activePlans = state.activePlans;
          final archivedPlans = state.archivedPlans;

          return TabBarView(
            controller: _tabController,
            children: [
              _buildPlansList(context, activePlans, state.activePlanId, isArchived: false),
              _buildPlansList(context, archivedPlans, state.activePlanId, isArchived: true),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlansList(
    BuildContext context,
    List<StudyPlanModel> plans,
    String? activePlanId, {
    required bool isArchived,
  }) {
    if (plans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isArchived ? Icons.archive_outlined : Icons.layers_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                isArchived ? 'أرشيف الخطط فارغ' : 'لا توجد خطط دراسية حالياً',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                isArchived
                  ? 'الخطط المؤرشفة ستظهر هنا مع الاحتفاظ بكامل بياناتها السابقة.'
                  : 'أنشئ خطتك الدراسية للفصل الحالي وابدأ بإضافة المقررات والمهام.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              if (!isArchived) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => _openAddPlanDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('إنشاء خطة دراسية جديدة'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];
        final isActive = plan.id == activePlanId && !isArchived;

        return Card(
          elevation: isActive ? 2 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isActive ? Theme.of(context).primaryColor : Colors.grey.shade200,
              width: isActive ? 1.5 : 1,
            ),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              plan.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: BorderSide(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 14, color: Colors.blue.shade700),
                                  const SizedBox(width: 4),
                                  Text(
                                    'الخطة النشطة',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        final cubit = context.read<UniversityCubit>();
                        if (value == 'edit') {
                          _openAddPlanDialog(context, planToEdit: plan);
                        } else if (value == 'archive') {
                          cubit.archivePlan(plan.id);
                        } else if (value == 'restore') {
                          cubit.restorePlan(plan.id);
                        } else if (value == 'delete') {
                          _confirmDeletePlan(context, plan);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('تعديل البيانات')),
                        if (!isArchived)
                          const PopupMenuItem(value: 'archive', child: Text('أرشفة الخطة'))
                        else
                          const PopupMenuItem(value: 'restore', child: Text('استعادة من الأرشيف')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('حذف نهائي', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ],
                ),
                if (plan.academicYear != null || plan.semester != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${plan.academicYear ?? ''} ${plan.semester != null ? '• ${plan.semester}' : ''}'.trim(),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.book_outlined, size: 16, color: Colors.blue.shade600),
                    const SizedBox(width: 4),
                    Text('${plan.totalCourses} مقرر', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 12),
                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 12),
                    Text('${plan.totalCreditHours} ساعة معتمدة', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<UniversityCubit>().setActivePlan(plan.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CoursesScreen()),
                          );
                        },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('عرض المقررات'),
                      ),
                    ),
                    if (!isActive && !isArchived) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          context.read<UniversityCubit>().setActivePlan(plan.id);
                        },
                        child: const Text('تعيين كنشطة'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
