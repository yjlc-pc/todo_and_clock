import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key, required this.subject});
  final String subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<TodoProvider>(
          builder: (context, todoProvider, child) {
            // 获取所有任务（可以根据需要过滤特定科目的任务）
            final tasks = todoProvider.tasks;

            return ListView(
              children: [
                Text(
                  subject,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.headline,
                    context,
                  ),
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
        ),
      ),
    );
  }
}
