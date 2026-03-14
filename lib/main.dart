import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/views/pages/todo_page.dart';
import 'package:todo_list_and_clock/views/pages/statistics_page.dart';
import 'package:todo_list_and_clock/services/database_service.dart';
import 'package:todo_list_and_clock/utils/screen_display.dart';
import 'package:todo_list_and_clock/view_models/task_view_model.dart';
import 'package:todo_list_and_clock/view_models/focus_view_model.dart';
import 'package:todo_list_and_clock/view_models/music_view_model.dart';
import 'package:todo_list_and_clock/view_models/statistics_view_model.dart';
import 'package:todo_list_and_clock/widgets/task_form.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化数据库服务
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await DatabaseService().database;
  }

  runApp(
    MultiProvider(
      providers: [
        // ViewModel 注册
        ChangeNotifierProvider(create: (_) => TaskViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => FocusViewModel()),
        ChangeNotifierProvider(create: (_) => MusicViewModel()..initialize()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()..initialize()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

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
          title: 'Todo List & Clock',
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

  @override
  Widget build(BuildContext context) {
    final currentThemeMode = Theme.of(context).brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;

    final isMobile = ScreenDisplay.isMobileLayout(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: isMobile
          ? _buildMobileLayout()
          : _buildDesktopLayout(currentThemeMode),
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
      floatingActionButton: _selectedIndex == 0
          ? const FabAdd()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// 构建移动端布局
  Widget _buildMobileLayout() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _selectedIndex == 0 ? const TodoPage() : const StatisticsPage(),
    );
  }

  /// 构建桌面端布局
  Widget _buildDesktopLayout(ThemeMode currentThemeMode) {
    return SafeArea(
      child: Row(
        children: <Widget>[
          NavigationRail(
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.today),
                label: Text("任务"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                label: Text("统计"),
              ),
            ],
            selectedIndex: _selectedIndex,
            groupAlignment: -1.0,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            trailing: IconButton(
              tooltip: '切换深色模式',
              icon: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: widget.toggleTheme,
            ),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _selectedIndex == 0
                  ? const TodoPage()
                  : const StatisticsPage(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 添加任务按钮（用于主页面）
class FabAdd extends StatelessWidget {
  const FabAdd({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        final viewModel = context.read<TaskViewModel>();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => TaskForm(
            viewModel: viewModel,
            initialTask: null,
          ),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text("添加任务"),
    );
  }
}
