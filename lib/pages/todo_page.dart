import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/models/category.dart';

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

class _TodoListState extends State<TodoList> {
  final int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 创建分类目的地列表，加上统计页面
        List<Tab> destinations = [];

        // 添加所有分类
        for (var category in todoProvider.categories) {
          destinations.add(
            Tab(
              icon: Icon(Icons.book_outlined), // 简化图标处理
              text: category.name,
            ),
          );
        }
        // 根据分类过滤任务
        final tasks = category == null
            ? todoProvider.tasks
            : todoProvider.tasks
                  .where((task) => task.categoryId == category?.id)
                  .toList();

        return ListView(
          children: [
            Row(
              children: [
                ...todoProvider.categories.map(
                  (category) => Chip(label: Text(category.name)),
                ),
              ],
            ),
            SizedBox(
              height: ScreenDisplay.getPaddingSize(
                context,
                PaddingType.widgetMargin,
              ),
            ),
            ...tasks.map((task) => TaskCard(task: task)),
          ],
        );
      },
    );
  }
}
