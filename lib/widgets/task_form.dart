import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/task_view_model.dart';
import '../../models/task.dart';
import '../../enums/repeat_type.dart';

/// 任务表单组件
class TaskForm extends StatefulWidget {
  const TaskForm({
    super.key,
    required this.viewModel,
    this.initialTask,
  });

  final TaskViewModel viewModel;
  final Task? initialTask;

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  int? _selectedCategoryId;
  DateTime? _dueDate;
  int _priority = 1;
  RepeatType _repeatType = RepeatType.none;

  bool get isEditing => widget.initialTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTask?.title ?? '');
    _descriptionController = TextEditingController(text: widget.initialTask?.description ?? '');
    _selectedCategoryId = widget.initialTask?.categoryId;
    _dueDate = widget.initialTask?.dueDate;
    _priority = widget.initialTask?.priority ?? 1;
    _repeatType = RepeatTypeExtension.fromInt(widget.initialTask?.repeatType ?? 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? '编辑任务' : '添加任务',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildTitleField(),
            const SizedBox(height: 12),
            _buildDescriptionField(),
            const SizedBox(height: 12),
            _buildCategoryDropdown(),
            const SizedBox(height: 12),
            _buildPrioritySelector(),
            const SizedBox(height: 12),
            _buildDueDatePicker(),
            const SizedBox(height: 20),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// 构建标题输入框
  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: '标题',
        hintText: '请输入任务标题',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.title),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '请输入任务标题';
        }
        return null;
      },
    );
  }

  /// 构建描述输入框
  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: '描述',
        hintText: '请输入任务描述（可选）',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 3,
    );
  }

  /// 构建分类选择器
  Widget _buildCategoryDropdown() {
    return Consumer<TaskViewModel>(
      builder: (context, viewModel, child) {
        return InputDecorator(
          decoration: const InputDecoration(
            labelText: '分类',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int?> (
              value: _selectedCategoryId,
              isExpanded: true,
              hint: const Text('选择分类'),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('无分类'),
                ),
                ...viewModel.categories.map((category) {
                  return DropdownMenuItem<int?>(
                    value: category.id,
                    child: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: category.colorValue,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(category.name),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
        );
      },
    );
  }

  /// 构建优先级选择器
  Widget _buildPrioritySelector() {
    return Row(
      children: [
        const Text('优先级：'),
        Expanded(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('低')),
              ButtonSegment(value: 1, label: Text('中')),
              ButtonSegment(value: 2, label: Text('高')),
            ],
            selected: {_priority},
            onSelectionChanged: (Set<int> selected) {
              setState(() {
                _priority = selected.first;
              });
            },
          ),
        ),
      ],
    );
  }

  /// 构建截止日期选择器
  Widget _buildDueDatePicker() {
    return InkWell(
      onTap: _selectDueDate,
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: '截止日期',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.calendar_today),
        ),
        child: Row(
          children: [
            Text(_dueDate != null
                ? '${_dueDate!.month}/${_dueDate!.day} ${_dueDate!.hour.toString().padLeft(2, '0')}:${_dueDate!.minute.toString().padLeft(2, '0')}'
                : '未设置'),
            const Spacer(),
            if (_dueDate != null)
              IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  setState(() {
                    _dueDate = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// 选择截止日期
  Future<void> _selectDueDate() async {
    if (!mounted) return;

    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );

      if (time != null && mounted) {
        setState(() {
          _dueDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// 构建操作按钮
  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(isEditing ? '保存' : '添加'),
        ),
      ],
    );
  }

  /// 保存任务
  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: widget.initialTask?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      isCompleted: widget.initialTask?.isCompleted ?? false,
      categoryId: _selectedCategoryId,
      dueDate: _dueDate,
      priority: _priority,
      repeatType: _repeatType.toInt(),
      createdAt: widget.initialTask?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    bool success;
    if (isEditing) {
      success = await widget.viewModel.updateTask(task);
    } else {
      success = await widget.viewModel.addTask(task);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}
