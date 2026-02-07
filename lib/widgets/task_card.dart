import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/models/task.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({super.key, required this.task, this.onChanged});
  final Task task;
  // 可选回调，通知父组件任务已改变
  final ValueChanged<Task>? onChanged;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  late Task task;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  @override
  void didUpdateWidget(covariant TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果父组件传入了新的 task 对象，更新本地引用
    if (oldWidget.task != widget.task) {
      task = widget.task;
    }
  }

  @override
  Widget build(BuildContext context) {
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
                // 仅在状态实际变化时调用 toggle，并触发重建与回调
                if (task.isCompleted != complete) {
                  setState(() {
                    task.toggleCompleted();
                  });
                  widget.onChanged?.call(task);
                }
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
                    '${task.time.hour.toString().padLeft(2, '0')}:${task.time.minute.toString().padLeft(2, '0')} - Repeat: ${task.repeat}',
                    style: ScreenDisplay.getTextTheme(
                      GeneralTextStyle.label,
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // TODO：实现删改
                  },
                  icon: Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () {
                    // TODO：实现删改
                  },
                  icon: Icon(Icons.delete),
                ),
                IconButton(
                  onPressed: () {
                    // TODO：实现番茄钟功能
                  },
                  icon: Icon(Icons.alarm),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
