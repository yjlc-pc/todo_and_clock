import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import 'pomodoro_timer_picker.dart';
import '../../views/pages/focus_page.dart';
import 'task_form.dart';

/// 任务卡片组件
class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            final viewModel = context.read<TaskViewModel>();
            viewModel.toggleTaskCompletion(task);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).colorScheme.outline
                : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (task.categoryId != null)
                  _buildCategoryChip(context, task.categoryId!),
                if (task.dueDate != null)
                  _buildDueDateChip(context, task.dueDate!),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'start_focus',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('开始专注'),
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('删除', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分类芯片
  Widget _buildCategoryChip(BuildContext context, int categoryId) {
    final viewModel = context.read<TaskViewModel>();
    final category = viewModel.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category(name: '', color: Colors.grey.shade400.toARGB32()),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: category.colorValue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.iconData, size: 14, color: category.colorValue),
          const SizedBox(width: 4),
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12,
              color: category.colorValue,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建截止日期芯片
  Widget _buildDueDateChip(BuildContext context, DateTime dueDate) {
    final isOverdue = dueDate.isBefore(DateTime.now());
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isOverdue
            ? Colors.red.withValues(alpha: 0.2)
            : Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: isOverdue ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 4),
          Text(
            '${dueDate.month}/${dueDate.day}',
            style: TextStyle(
              fontSize: 12,
              color: isOverdue ? Colors.red : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  /// 处理菜单操作
  void _handleMenuAction(BuildContext context, String value) {
    final viewModel = context.read<TaskViewModel>();

    switch (value) {
      case 'start_focus':
        _startFocus(context);
        break;
      case 'edit':
        _showEditDialog(context, viewModel);
        break;
      case 'delete':
        _confirmDelete(context, viewModel);
        break;
    }
  }

  /// 开始专注
  Future<void> _startFocus(BuildContext context) async {
    final duration = await showModalBottomSheet<int>(
      context: context,
      builder: (context) => const PomodoroTimerPicker(),
    );

    if (duration != null) {
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FocusPage(
              task: task,
              durationInMinutes: duration,
            ),
          ),
        );
      }
    }
  }

  /// 显示编辑对话框
  void _showEditDialog(BuildContext context, TaskViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskForm(
        viewModel: viewModel,
        initialTask: task,
      ),
    );
  }

  /// 确认删除
  void _confirmDelete(BuildContext context, TaskViewModel viewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除任务"${task.title}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTask(task.id!);
              Navigator.of(context).pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
