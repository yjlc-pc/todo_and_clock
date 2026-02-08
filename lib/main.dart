import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/models/task.dart';
import 'package:todo_list_and_clock/pages/todo_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 sqflite_common_ffi
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider()..loadTasks(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待办事项与计时器',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  // groupAlignment 控制 NavigationRail 的分组对齐方式，-1.0 表示顶部对齐
  double groupAlignment = -1.0;
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Row(
              children: <Widget>[
                NavigationRail(
                  destinations: const <NavigationRailDestination>[
                    // TODO: 支持添加分类
                    NavigationRailDestination(
                      icon: Icon(Icons.edit),
                      label: Text("语文"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.calculate),
                      label: Text("数学"),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.science),
                      label: Text("英语"),
                    ),
                  ],
                  selectedIndex: _selectedIndex,
                  groupAlignment: groupAlignment,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  labelType: labelType,
                  leading: Column(
                    children: [
                      showLeading
                          ? FloatingActionButton(
                              onPressed: () {
                                // TODO：添加FAB逻辑
                              },
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              child: const Icon(Icons.add),
                            )
                          : const SizedBox(),
                    ],
                  ),
                  trailing: IconButton(
                    tooltip: '切换深色模式',
                    icon: Icon(
                      _themeMode == ThemeMode.dark
                          ? Icons.light_mode
                          : Icons.dark_mode,
                    ),
                    onPressed: () {
                      setState(() {
                        _themeMode = _themeMode == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TodoPage(
                      subject: _selectedIndex == 0
                          ? "语文"
                          : _selectedIndex == 1
                          ? "数学"
                          : "英语",
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              // 使用 Provider 来添加任务
              todoProvider.loadTasks(); // 确保数据是最新的
              // 我们将在 TodoPage 内部处理添加任务的逻辑
              // 通过 Provider 触发添加任务对话框
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return TaskForm(context: context, todoProvider: todoProvider, initialTask: null);
                },
              );
            },
            label: const Text("添加任务"),
            icon: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
