import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/widgets/pomodoro_timer_picker.dart';
import 'package:todo_list_and_clock/pages/foucs_page.dart'; // 导入FocusPage
import 'package:todo_list_and_clock/enums/repeat_type.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({super.key, required this.task});
  final Task task;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Future<void> _startPomodoroSession(BuildContext context) async {
    // 弹出时间选择器
    final selectedMinutes = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return PomodoroTimerPicker();
      },
    );

    // 如果用户选择了时间，并且组件仍然挂载，则启动番茄钟
    if (selectedMinutes != null && mounted) {
      // 在下一个帧中执行导航，确保组件仍然挂载
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FocusPage(
                task: widget.task,
                durationInMinutes: selectedMinutes,
              ),
            ),
          );
        }
      });
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
          initialTask: widget.task, // 传递当前任务用于编辑
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
                todoProvider.deleteTask(widget.task.id!); // 删除任务
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
                  value: widget.task.isCompleted,
                  onChanged: (bool? complete) {
                    if (complete == null) return;
                    // 更新任务状态
                    final updatedTask = Task(
                      id: widget.task.id,
                      isImportant: widget.task.isImportant,
                      title: widget.task.title,
                      isCompleted: complete,
                      date: widget.task.date,
                      repeat: widget.task.repeat,
                    );
                    todoProvider.updateTask(updatedTask);
                  },
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: ScreenDisplay.getTextTheme(
                          GeneralTextStyle.body,
                          context,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${widget.task.date.toString()} - 重复周期: ${widget.task.repeat.displayName}',
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
class TaskForm extends StatefulWidget {
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
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController _titleController;
  late DateTime? _selectedDueDate;
  late RepeatType _selectedRepeatType;
  int? _selectedCategoryId; // 新增：选中的分类ID

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.initialTask?.title ?? '',
    );
    _selectedDueDate = widget.initialTask?.date;
    _selectedRepeatType = widget.initialTask?.repeat ?? RepeatType.none;
    _selectedCategoryId = widget.initialTask?.categoryId; // 初始化分类ID

    // 如果是编辑模式且设置了重复周期但没有设置截止日期，根据重复周期计算截止日期
    if (widget.initialTask != null &&
        _selectedRepeatType != RepeatType.none &&
        _selectedDueDate == null) {
      _selectedDueDate = _selectedRepeatType.getNextDate(DateTime.now());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _updateDueDateBasedOnRepeat() {
    if (_selectedRepeatType != RepeatType.none) {
      // 当选择了重复周期时，自动设置截止日期为当前日期加上相应的周期
      setState(() {
        _selectedDueDate = _selectedRepeatType.getNextDate(DateTime.now());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _titleController,
            decoration: const InputDecoration(labelText: '任务标题'),
            autofocus: true,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: DropdownButtonFormField<RepeatType>(
              initialValue: _selectedRepeatType,
              decoration: const InputDecoration(labelText: '重复周期'),
              items: RepeatType.values.map((RepeatType repeatType) {
                return DropdownMenuItem<RepeatType>(
                  value: repeatType,
                  child: Text(repeatType.displayName),
                );
              }).toList(),
              onChanged: (RepeatType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRepeatType = newValue;
                    _updateDueDateBasedOnRepeat();
                  });
                }
              },
            ),
          ),
          Consumer<TodoProvider>(
            builder: (context, todoProvider, child) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: DropdownButtonFormField<int?>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: '分类'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('无分类')),
                    ...todoProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }),
                  ],
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue;
                    });
                  },
                ),
              );
            },
          ),
          ListTile(
            title: Text(
              _selectedDueDate != null
                  ? '已选择: ${_selectedDueDate!.year}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}'
                  : '选择截止日期',
            ),
            onTap: () async {
              final DateTime? date = await showDatePicker(
                context: context,
                initialDate: _selectedDueDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (date != null) {
                setState(() {
                  _selectedDueDate = DateTime(date.year, date.month, date.day);
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_titleController.text.isNotEmpty &&
                  _selectedDueDate != null) {
                if (widget.initialTask != null) {
                  // 编辑现有任务
                  final updatedTask = Task(
                    id: widget.initialTask!.id,
                    categoryId: _selectedCategoryId, // 添加分类ID
                    isImportant: widget.initialTask!.isImportant,
                    title: _titleController.text,
                    isCompleted: widget.initialTask!.isCompleted,
                    date: _selectedDueDate!,
                    repeat: _selectedRepeatType,
                  );

                  await widget.todoProvider.updateTask(updatedTask);
                } else {
                  // 添加新任务
                  final newTask = Task(
                    categoryId: _selectedCategoryId, // 添加分类ID
                    isImportant: false,
                    title: _titleController.text,
                    isCompleted: false,
                    date: _selectedDueDate!,
                    repeat: _selectedRepeatType,
                  );

                  await widget.todoProvider.addTask(newTask);
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    Navigator.pop(context); // 关闭模态窗口
                  }
                });
              }
            },
            child: Text(widget.initialTask != null ? '更新任务' : '添加任务'),
          ),
        ],
      ),
    );
  }
}
