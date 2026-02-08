import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/widgets/pomodoro_timer_picker.dart';
import 'package:todo_list_and_clock/widgets/pomodoro_timer.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({super.key, required this.task});
  final Task task;

  Future<void> _startPomodoroSession(BuildContext context) async {
    // 弹出时间选择器
    final selectedMinutes = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return PomodoroTimerPicker();
      },
    );

    // 如果用户选择了时间，则启动番茄钟
    if (selectedMinutes != null) {
      // 导航到番茄钟计时器页面
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              PomodoroTimer(task: task, durationInMinutes: selectedMinutes),
        ),
      );
    }
  }

  void _showEditDialog(BuildContext context, TodoProvider todoProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TaskForm(
          context: context,
          todoProvider: todoProvider,
          initialTask: task, // 传递当前任务用于编辑
        );
      },
    );
  }

  void _confirmDeleteTask(BuildContext context, TodoProvider todoProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('确认删除'),
          content: const Text('确定要删除这个任务吗？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                todoProvider.deleteTask(task.id!); // 删除任务
                Navigator.of(context).pop(); // 关闭对话框
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
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (bool? complete) {
                    if (complete == null) return;
                    // 更新任务状态
                    final updatedTask = Task(
                      id: task.id,
                      isImportant: task.isImportant,
                      title: task.title,
                      isCompleted: complete,
                      date: task.date,
                      repeat: task.repeat,
                    );
                    todoProvider.updateTask(updatedTask);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: ScreenDisplay.getTextTheme(
                          GeneralTextStyle.body,
                          context,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: ScreenDisplay.getPaddingSize(
                          context,
                          PaddingType.textMargin,
                        ),
                      ),
                      Text(
                        '${task.date.toString().padLeft(2, '0')}:${task.date.minute.toString().padLeft(2, '0')} - Repeat: ${task.repeat}',
                        style:
                            ScreenDisplay.getTextTheme(
                              GeneralTextStyle.label,
                              context,
                            ).copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        _showEditDialog(context, todoProvider);
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {
                        _confirmDeleteTask(context, todoProvider);
                      },
                      icon: Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: () {
                        _startPomodoroSession(context);
                      },
                      icon: Icon(Icons.alarm),
                    ),
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

// 任务表单组件，用于添加和编辑任务
class TaskForm extends StatelessWidget {
  const TaskForm({
    super.key,
    required this.context,
    required this.todoProvider,
    this.initialTask, // 初始任务，用于编辑
  });

  final BuildContext context;
  final TodoProvider todoProvider;
  final Task? initialTask; // 可选的任务对象，如果为空则是添加新任务

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController(
      text: initialTask?.title ?? '',
    );
    final repeatController = TextEditingController(
      text: initialTask?.repeat ?? '',
    );
    DateTime? selectedDueDate = initialTask?.date;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: '任务标题'),
            autofocus: true,
          ),
          TextField(
            controller: repeatController,
            decoration: const InputDecoration(labelText: '重复周期'),
          ),
          ListTile(
            title: Text(
              selectedDueDate != null
                  ? '已选择: ${selectedDueDate.year}-${selectedDueDate.month.toString().padLeft(2, '0')}-${selectedDueDate.day.toString().padLeft(2, '0')}'
                  : '选择截止日期',
            ),
            onTap: () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: selectedDueDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                selectedDueDate = DateTime(date.year, date.month, date.day);
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  repeatController.text.isNotEmpty &&
                  selectedDueDate != null) {
                if (initialTask != null) {
                  // 编辑现有任务
                  final updatedTask = Task(
                    id: initialTask!.id,
                    isImportant: initialTask!.isImportant,
                    title: titleController.text,
                    isCompleted: initialTask!.isCompleted,
                    date: selectedDueDate!,
                    repeat: repeatController.text,
                  );

                  await todoProvider.updateTask(updatedTask);
                } else {
                  // 添加新任务
                  final newTask = Task(
                    isImportant: false,
                    title: titleController.text,
                    isCompleted: false,
                    date: selectedDueDate!,
                    repeat: repeatController.text,
                  );

                  await todoProvider.addTask(newTask);
                }

                Navigator.pop(context); // 关闭模态窗口
              }
            },
            child: Text(initialTask != null ? '更新任务' : '添加任务'),
          ),
        ],
      ),
    );
  }
}
