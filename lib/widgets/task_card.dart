import 'package:flutter/material.dart';
import '../models/task_model.dart';

// ============================================================
// REQUIREMENT: WIDGETS (TASK CARD)
// Reusable task card widget displaying task status, title,
// description, completion checkbox, edit, and archive actions with Arabic labels.
// ============================================================

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final ValueChanged<bool?>? onToggleCompleted;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isArchived;
  final VoidCallback? onRestore;

  const TaskCard({
    super.key,
    required this.task,
    this.onToggleCompleted,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.isArchived = false,
    this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: task.isCompleted
              ? colorScheme.outline.withOpacity(0.2)
              : colorScheme.outline.withOpacity(0.4),
        ),
      ),
      color: task.isCompleted
          ? colorScheme.surfaceVariant.withOpacity(0.3)
          : colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap ?? onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion Checkbox (Active mode only)
              if (!isArchived)
                Padding(
                  padding: const EdgeInsets.only(top: 2, left: 12),
                  child: Checkbox(
                    value: task.isCompleted,
                    activeColor: colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    onChanged: onToggleCompleted,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 12),
                  child: Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.archive_outlined,
                    size: 22,
                    color: colorScheme.secondary,
                  ),
                ),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.isCompleted
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Action Buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isArchived && onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'تعديل المهمة',
                      onPressed: onEdit,
                    ),
                  if (!isArchived && onDelete != null)
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        size: 20,
                        color: colorScheme.error,
                      ),
                      tooltip: 'نقل إلى الأرشيف',
                      onPressed: onDelete,
                    ),
                  if (isArchived && onRestore != null)
                    IconButton(
                      icon: Icon(
                        Icons.unarchive_outlined,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      tooltip: 'استعادة إلى المهام النشطة',
                      onPressed: onRestore,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
