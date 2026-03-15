import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/models/category.dart';
import 'package:todo_list_and_clock/models/task.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(padding: const EdgeInsets.all(8.0), child: TodoList()),
    );
  }
}

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  int? _selectedCategoryId;

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'book':
        return Icons.book_outlined;
      case 'calculate':
        return Icons.calculate_outlined;
      case 'language':
        return Icons.language_outlined;
      case 'science':
        return Icons.science_outlined;
      case 'art_track':
        return Icons.art_track_outlined;
      case 'sports':
        return Icons.sports_outlined;
      case 'music_note':
        return Icons.music_note_outlined;
      case 'code':
        return Icons.code_outlined;
      default:
        return Icons.book_outlined;
    }
  }

  void _showAddCategoryDialog(BuildContext context, TodoProvider todoProvider) {
    final TextEditingController nameController = TextEditingController();
    String? selectedIcon;

    final List<Map<String, String>> iconOptions = [
      {'name': 'book', 'label': '书'},
      {'name': 'calculate', 'label': '计算器'},
      {'name': 'language', 'label': '语言'},
      {'name': 'science', 'label': '科学'},
      {'name': 'art_track', 'label': '艺术'},
      {'name': 'sports', 'label': '运动'},
      {'name': 'music_note', 'label': '音乐'},
      {'name': 'code', 'label': '代码'},
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('添加分类'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: '分类名称',
                        hintText: '例如：语文',
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 16),
                    const Text('选择图标:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: iconOptions.map((iconOption) {
                        final isSelected = selectedIcon == iconOption['name'];
                        return ChoiceChip(
                          label: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getIconData(iconOption['name'])),
                              Text(
                                iconOption['label']!,
                                style: const TextStyle(fontSize: 10),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setDialogState(() {
                                selectedIcon = iconOption['name'];
                              });
                            }
                          },
                          selectedColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        selectedIcon != null) {
                      todoProvider.addCategory(
                        Category(
                          name: nameController.text,
                          icon: selectedIcon!,
                        ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('添加'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 构建示例任务卡片（占位图）
  Widget _buildExampleTaskCard(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        List<Task> filteredTasks;
        if (_selectedCategoryId == null) {
          filteredTasks = todoProvider.tasks;
        } else {
          filteredTasks = todoProvider.tasks
              .where((task) => task.categoryId == _selectedCategoryId)
              .toList();
        }

        return Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  FilterChip(
                    label: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.all_inclusive, size: 18),
                        SizedBox(width: 6),
                        Text('全部'),
                      ],
                    ),
                    selected: _selectedCategoryId == null,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryId = null;
                      });
                    },
                    selectedColor: colorScheme.primaryContainer,
                    checkmarkColor: colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  ...todoProvider.categories.map((category) {
                    final isSelected = _selectedCategoryId == category.id;
                    return FilterChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getIconData(category.icon), size: 18),
                          const SizedBox(width: 6),
                          Text(category.name),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategoryId = selected ? category.id : null;
                        });
                      },
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                    );
                  }),
                  const SizedBox(width: 8),
                  if (todoProvider.categories.length < 6)
                    FilterChip(
                      avatar: const Icon(Icons.add, size: 18),
                      label: const Text('添加'),
                      onSelected: (selected) {
                        if (selected) {
                          _showAddCategoryDialog(context, todoProvider);
                        }
                      },
                      selected: false,
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                    ),
                ],
              ),
            ),
            if (todoProvider.categories.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除分类',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('选择要删除的分类'),
                          content: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 300),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: todoProvider.categories.map((
                                  category,
                                ) {
                                  return ListTile(
                                    leading: Icon(_getIconData(category.icon)),
                                    title: Text(category.name),
                                    onTap: () {
                                      todoProvider.deleteCategory(category.id!);
                                      Navigator.of(context).pop();
                                      if (_selectedCategoryId == category.id) {
                                        setState(() {
                                          _selectedCategoryId = null;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('取消'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            SizedBox(
              height: ScreenDisplay.getPaddingSize(
                context,
                PaddingType.widgetMargin,
              ),
            ),
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '这里空空如也',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.outline,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '点击 + 添加你的第一个任务',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.outline.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildExampleTaskCard(context),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: filteredTasks.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: colorScheme.outline.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        return TaskCard(task: filteredTasks[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
