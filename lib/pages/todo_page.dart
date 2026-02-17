import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/models/category.dart';
import 'package:todo_list_and_clock/models/task.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key}); // 如果为null，则显示所有任务

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

class _TodoListState extends State<TodoList> with TickerProviderStateMixin {
  late TabController _tabController;
  int? _selectedCategoryId; // 当前选中的分类 ID，null 表示显示所有任务

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
    _selectedCategoryId = null; // 默认显示所有任务
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context, TodoProvider todoProvider) {
    final TextEditingController nameController = TextEditingController();

    // 预定义的图标列表
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

    String? selectedIcon;

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

  void _showDeleteCategoryDialog(
    BuildContext context,
    TodoProvider todoProvider,
    int categoryIndex,
  ) {
    final category = todoProvider.categories[categoryIndex];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: Text(
            '确定要删除分类"${category.name}"吗？\n\n注意：该分类下的任务将不会被删除，但会变为无分类状态。',
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
                todoProvider.deleteCategory(category.id!);
                Navigator.of(context).pop();
                // 如果当前选中的是被删除的分类，切换回"全部"
                if (_selectedCategoryId == category.id) {
                  setState(() {
                    _selectedCategoryId = null;
                  });
                }
              },
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 创建分类 Tab 列表
        List<Widget> tabs = [
          const Tab(icon: Icon(Icons.all_inclusive), text: '全部'),
        ];

        // 添加所有分类
        for (var category in todoProvider.categories) {
          tabs.add(
            Tab(icon: Icon(_getIconData(category.icon)), text: category.name),
          );
        }

        // 如果分类数量小于 6，添加添加按钮
        final canAddCategory = todoProvider.categories.length < 6;
        final addTabIndex = canAddCategory ? tabs.length : -1;
        if (canAddCategory) {
          tabs.add(Tab(icon: const Icon(Icons.add), text: '添加'));
        }

        // 更新 TabController 长度
        if (_tabController.length != tabs.length) {
          _tabController.dispose();
          _tabController = TabController(length: tabs.length, vsync: this);
        }

        // 根据选中的分类过滤任务
        List<Task> filteredTasks;
        if (_selectedCategoryId == null) {
          // 显示所有任务
          filteredTasks = todoProvider.tasks;
        } else {
          // 显示选中分类的任务
          filteredTasks = todoProvider.tasks
              .where((task) => task.categoryId == _selectedCategoryId)
              .toList();
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TabBar(
                    controller: _tabController,
                    tabs: tabs,
                    onTap: (index) {
                      setState(() {
                        if (index == addTabIndex) {
                          // 点击了添加按钮，重置到上一个有效 tab
                          _tabController.animateTo(
                            _selectedCategoryId == null
                                ? 0
                                : todoProvider.categories.indexWhere(
                                        (c) => c.id == _selectedCategoryId,
                                      ) +
                                      1,
                          );
                          _showAddCategoryDialog(context, todoProvider);
                        } else if (index == 0) {
                          _selectedCategoryId = null; // 全部
                        } else {
                          // 获取对应分类的 ID
                          _selectedCategoryId =
                              todoProvider.categories[index - 1].id;
                        }
                      });
                    },
                  ),
                ),
                if (todoProvider.categories.isNotEmpty)
                  PopupMenuButton<int>(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: '删除分类',
                    onSelected: (int index) {
                      _showDeleteCategoryDialog(context, todoProvider, index);
                    },
                    itemBuilder: (BuildContext context) {
                      return todoProvider.categories.asMap().entries.map((
                        entry,
                      ) {
                        return PopupMenuItem<int>(
                          value: entry.key,
                          child: Text(entry.value.name),
                        );
                      }).toList();
                    },
                  ),
              ],
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
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '这里空空如也',
                            style: TextStyle(
                              fontSize: 18,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
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
