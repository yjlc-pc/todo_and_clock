import 'dart:io';
import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/pages/todo_page.dart';
import 'package:todo_list_and_clock/pages/streak_page.dart';
import 'package:todo_list_and_clock/pages/statistics_page.dart';
import 'package:todo_list_and_clock/utils/task_database_factory.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/providers/todo_provider.dart';
import 'package:todo_list_and_clock/providers/focus_provider.dart';
import 'package:todo_list_and_clock/providers/music_provider.dart';
import 'package:todo_list_and_clock/widgets/task_card.dart';
import 'package:todo_list_and_clock/widgets/streak_card.dart';
import 'package:dynamic_color/dynamic_color.dart';

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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightColorScheme =
            lightDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            );
        final darkColorScheme =
            darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            );
        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
            fontFamily: "NotoSansSC",
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
            fontFamily: "NotoSansSC",
          ),
          themeMode: _themeMode,
          home: MyHomePage(toggleTheme: toggleTheme),
        );
      },
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

        // 判断是否为移动端布局
        final isMobile = ScreenDisplay.isMobileLayout(context);

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: isMobile
              ? AppBar(
                  title: Text(_selectedIndex == 0 ? '任务' : '统计'),
                  actions: [
                    // 连续专注卡片 - 点击右上角可进入连续记录页面
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const StreakPage(),
                              ),
                            );
                          },
                          child: StreakCard(),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: isMobile
              ? _buildMobileLayout(selectedPage)
              : _buildDesktopLayout(
                  selectedPage,
                  todoProvider,
                  currentThemeMode,
                ),
          bottomNavigationBar: isMobile
              ? BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.today),
                      label: "任务",
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart),
                      label: "统计",
                    ),
                  ],
                )
              : null,
          floatingActionButton:
              _selectedIndex == 0
              ? FloatingActionButton.extended(
                  onPressed: () {
                    todoProvider.loadTasks();
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

  /// 构建移动端布局
  Widget _buildMobileLayout(Widget selectedPage) {
    return Padding(padding: const EdgeInsets.all(8.0), child: selectedPage);
  }

  /// 构建桌面端布局
  Widget _buildDesktopLayout(
    Widget selectedPage,
    TodoProvider todoProvider,
    ThemeMode currentThemeMode,
  ) {
    return SafeArea(
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
                trailing: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 连续专注卡片 - 点击可进入连续记录页面
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const StreakPage(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const StreakCard(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 切换深色模式按钮
                    IconButton(
                      tooltip: '切换深色模式',
                      icon: Icon(
                        currentThemeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: widget.toggleTheme,
                    ),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
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
    );
  }
}
