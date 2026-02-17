import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/pages/todo_page.dart';
import 'package:todo_list_and_clock/pages/statistics_page.dart';
import 'package:todo_list_and_clock/utils/task_database_factory.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/providers/focus_provider.dart';
import 'package:todo_list_and_clock/providers/music_provider.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库工厂
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    TaskDatabaseFactory.initialize();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => TodoProvider()
            ..loadTasks()
            ..initializeDefaultCategories()
            ..loadCategories(),
        ),
        ChangeNotifierProvider(create: (context) => FocusProvider()),
        ChangeNotifierProvider(create: (context) => MusicProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // 默认跟随系统

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark
          ? ThemeMode.light
          : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '待办事项与计时器',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light, // 明确指定浅色主题
        colorSchemeSeed: Colors.lightBlue,
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // 明确指定深色主题
        colorSchemeSeed: Colors.blue,
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      home: MyHomePage(toggleTheme: toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MyHomePage({super.key, required this.toggleTheme});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  // groupAlignment 控制 NavigationRail 的分组对齐方式，-1.0 表示顶部对齐
  double groupAlignment = -1.0;

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        Widget selectedPage;
        if (_selectedIndex == 0) {
          selectedPage = TodoPage();
        } else {
          selectedPage = StatisticsPage();
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Row(
              children: <Widget>[
                Consumer<TodoProvider>(
                  builder: (context, todoProvider, child) {
                    return NavigationRail(
                      destinations: [
                        const NavigationRailDestination(
                          icon: Icon(Icons.today),
                          label: Text("任务"),
                        ),
                        const NavigationRailDestination(
                          icon: Icon(Icons.bar_chart),
                          label: Text("统计"),
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
                      trailing: IconButton(
                        tooltip: '切换深色模式',
                        icon: Icon(
                          currentThemeMode == ThemeMode.dark
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: widget.toggleTheme,
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHigh,
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: selectedPage,
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton:
              _selectedIndex ==
                  0 // 只在待办事项页面显示浮动按钮
              ? FloatingActionButton.extended(
                  onPressed: () {
                    // 使用 Provider 来添加任务
                    todoProvider.loadTasks(); // 确保数据是最新的
                    // 我们将在 TodoPage 内部处理添加任务的逻辑
                    // 通过 Provider 触发添加任务对话框
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (BuildContext context) {
                        return TaskForm(
                          context: context,
                          todoProvider: todoProvider,
                          initialTask: null,
                        );
                      },
                    );
                  },
                  label: const Text("添加任务"),
                  icon: const Icon(Icons.add),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
