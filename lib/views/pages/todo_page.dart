import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/category.dart';
import '../../widgets/task_card.dart';

/// 待办事项页面 - MVVM 架构的 View
class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _buildCategoryFilterBar(),
          const Expanded(child: TodoList()),
        ],
      ),
    );
  }

  /// 构建分类过滤栏
  Widget _buildCategoryFilterBar() {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: viewModel.categories.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildAllCategoryChip(viewModel);
              }
              final category = viewModel.categories[index - 1];
              return _buildCategoryChip(viewModel, category);
            },
          ),
        );
      },
    );
  }

  /// 构建"全部分类"芯片
  Widget _buildAllCategoryChip(TaskViewModel viewModel) {
    final isSelected = viewModel.selectedCategoryId == null;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: const Text('全部'),
        selected: isSelected,
        onSelected: (selected) {
          viewModel.selectCategory(null);
        },
      ),
    );
  }

  /// 构建分类芯片
  Widget _buildCategoryChip(TaskViewModel viewModel, Category category) {
    final isSelected = viewModel.selectedCategoryId == category.id;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        avatar: CircleAvatar(
          backgroundColor: category.colorValue,
          child: Icon(
            category.iconData,
            size: 16,
            color: Colors.white,
          ),
        ),
        label: Text(category.name),
        selected: isSelected,
        onSelected: (selected) {
          viewModel.selectCategory(selected ? category.id : null);
        },
      ),
    );
  }
}

/// 任务列表组件
class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        final tasks = viewModel.filteredTasks;

        if (tasks.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: viewModel.loadTasks,
          child: ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              return TaskCard(task: tasks[index]);
            },
          ),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无任务',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            '点击右下角按钮添加任务',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
