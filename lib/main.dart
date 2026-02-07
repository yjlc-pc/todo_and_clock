import 'package:flutter/material.dart';
import 'package:todo_list_and_clock/pages/todo_page.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 sqflite_common_ffi
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _selectedIndex = 0;
  NavigationRailLabelType labelType = NavigationRailLabelType.all;
  bool showLeading = false;
  // groupAlignment 控制 NavigationRail 的分组对齐方式，-1.0 表示顶部对齐
  double groupAlignment = -1.0;
  ThemeMode _themeMode = ThemeMode.light;
  final GlobalKey<TodoPageState> todoPageKey = GlobalKey<TodoPageState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: _themeMode,
      theme: ThemeData(
        colorSchemeSeed: Colors
            .blue, // Use blue color seed instead of hardcoding color values
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        fontFamily: 'NotoSansSC', // Set Chinese font
      ),
      home: Scaffold(
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
                    globalKey: todoPageKey,
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            todoPageKey.currentState?.showAddTaskDialog();
          },
          label: const Text("添加任务"),
          icon: const Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}
