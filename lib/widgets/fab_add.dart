import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/category.dart';
import 'task_form.dart';

/// 添加任务浮动按钮
class FabAdd extends StatelessWidget {
  const FabAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showAddTaskDialog(context),
      icon: const Icon(Icons.add),
      label: const Text('添加任务'),
    );
  }

  /// 显示添加任务对话框
  void _showAddTaskDialog(BuildContext context) {
    final viewModel = context.read<TaskViewModel>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskForm(
        viewModel: viewModel,
        initialTask: null,
      ),
    );
  }
}

/// 添加分类按钮
class AddCategoryButton extends StatelessWidget {
  const AddCategoryButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return IconButton(
          onPressed: () => _showAddCategoryDialog(context, viewModel),
          icon: const Icon(Icons.add),
          tooltip: '添加分类',
        );
      },
    );
  }

  /// 显示添加分类对话框
  void _showAddCategoryDialog(BuildContext context, TaskViewModel viewModel) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF2196F3;
    String selectedIcon = 'label';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 16),
              const Text('选择颜色'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  0xFF2196F3, 0xFF4CAF50, 0xFFFF9800,
                  0xFFF44336, 0xFF9C27B0, 0xFF00BCD4,
                ].map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(color),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.black, width: 3)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('选择图标'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  'work', 'school', 'home',
                  'shopping', 'fitness', 'music',
                ].map((icon) {
                  final iconData = _getIconData(icon);
                  return GestureDetector(
                    onTap: () => setState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: selectedIcon == icon
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconData),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  final category = Category(
                    name: nameController.text.trim(),
                    color: selectedColor,
                    icon: selectedIcon,
                    createdAt: DateTime.now(),
                  );
                  viewModel.addCategory(category);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work': return Icons.work;
      case 'school': return Icons.school;
      case 'home': return Icons.home;
      case 'shopping': return Icons.shopping_cart;
      case 'fitness': return Icons.fitness_center;
      case 'music': return Icons.music_note;
      default: return Icons.label;
    }
  }
}
