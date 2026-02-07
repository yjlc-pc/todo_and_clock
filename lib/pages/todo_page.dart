import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/utils/database_helper.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/models/task.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key, required this.subject, required this.globalKey});
  final String subject;
  final GlobalKey<TodoPageState> globalKey;

  @override
  State<TodoPage> createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final dbHelper = DatabaseHelper.instance;
    final loadedTasks = await dbHelper.readAllTasks();
    setState(() {
      tasks = loadedTasks;
    });
  }

  void addTask(Task task) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createTask(task);
    _loadTasks();
  }

  void showAddTaskDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController repeatController = TextEditingController();
    DateTime? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('添加任务'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: '任务标题'),
              ),
              TextField(
                controller: repeatController,
                decoration: const InputDecoration(labelText: '重复周期'),
              ),
              TextButton(
                onPressed: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = DateTime(
                        DateTime.now().year,
                        DateTime.now().month,
                        DateTime.now().day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                },
                child: const Text('选择时间'),
              ),
            ],
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
                if (titleController.text.isNotEmpty &&
                    repeatController.text.isNotEmpty &&
                    selectedTime != null) {
                  final newTask = Task(
                    isImportant: false,
                    title: titleController.text,
                    isCompleted: false,
                    time: selectedTime!,
                    repeat: repeatController.text,
                  );
                  addTask(newTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              widget.subject,
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
        ),
      ),
    );
  }
}
