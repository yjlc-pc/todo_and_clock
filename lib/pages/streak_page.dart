import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/pomodoro.dart';
import '../utils/screen_display.dart';

/// 专注连续记录页面 - 参考多邻国 UI 风格
class StreakPage extends StatefulWidget {
  const StreakPage({super.key});

  @override
  State<StreakPage> createState() => _StreakPageState();
}

class _StreakPageState extends State<StreakPage> {
  late Future<StreakData> _streakFuture;

  @override
  void initState() {
    super.initState();
    _loadStreakData();
  }

  void _loadStreakData() {
    setState(() {
      _streakFuture = _calculateStreakData();
    });
  }

  Future<StreakData> _calculateStreakData() async {
    final dbHelper = DatabaseHelper.instance;
    final pomodoros = await dbHelper.readAllPomodoros();

    // 过滤出已完成的专注记录
    final completedFocusPomodoros = pomodoros
        .where((p) => p.isCompleted && !p.isRest)
        .toList();

    // 计算连续天数
    final streaks = _calculateStreaks(completedFocusPomodoros);

    // 计算历史最佳记录
    final history = _calculateStreakHistory(completedFocusPomodoros);

    return StreakData(
      currentStreak: streaks['current'] ?? 0,
      bestStreak: streaks['best'] ?? 0,
      history: history,
    );
  }

  Map<String, int> _calculateStreaks(List<Pomodoro> pomodoros) {
    if (pomodoros.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // 获取有专注记录的日期（去重）
    Set<String> uniqueDates = {};
    for (var pomodoro in pomodoros) {
      final dateStr =
          '${pomodoro.startTime.year}-${pomodoro.startTime.month}-${pomodoro.startTime.day}';
      uniqueDates.add(dateStr);
    }

    List<DateTime> dates = uniqueDates.map((d) {
      final parts = d.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    }).toList();

    dates.sort((a, b) => b.compareTo(a)); // 降序排列

    if (dates.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    // 计算当前连续天数
    int currentStreak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));

    bool hasToday = dates.any(
      (d) =>
          d.year == todayDate.year &&
          d.month == todayDate.month &&
          d.day == todayDate.day,
    );
    bool hasYesterday = dates.any(
      (d) =>
          d.year == yesterday.year &&
          d.month == yesterday.month &&
          d.day == yesterday.day,
    );

    if (!hasToday && !hasYesterday) {
      currentStreak = 0;
    } else {
      currentStreak = 1;
      for (int i = 0; i < dates.length - 1; i++) {
        final diff = dates[i].difference(dates[i + 1]).inDays;
        if (diff == 1) {
          currentStreak++;
        } else if (diff > 1) {
          break;
        }
      }
    }

    // 计算最佳连续天数
    int bestStreak = 1;
    int tempStreak = 1;

    for (int i = 0; i < dates.length - 1; i++) {
      final diff = dates[i].difference(dates[i + 1]).inDays;
      if (diff == 1) {
        tempStreak++;
        if (tempStreak > bestStreak) {
          bestStreak = tempStreak;
        }
      } else if (diff > 1) {
        tempStreak = 1;
      }
    }

    return {'current': currentStreak, 'best': bestStreak};
  }

  List<int> _calculateStreakHistory(List<Pomodoro> pomodoros) {
    // 计算近 30 天每天的专注状态（0=未专注，1=已专注）
    final today = DateTime.now();
    List<int> history = List.filled(30, 0);

    Set<String> uniqueDates = {};
    for (var pomodoro in pomodoros) {
      if (pomodoro.isCompleted && !pomodoro.isRest) {
        final dateStr =
            '${pomodoro.startTime.year}-${pomodoro.startTime.month}-${pomodoro.startTime.day}';
        uniqueDates.add(dateStr);
      }
    }

    for (var dateStr in uniqueDates) {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      final daysDiff = today.difference(date).inDays;
      if (daysDiff >= 0 && daysDiff < 30) {
        history[29 - daysDiff] = 1;
      }
    }

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = ScreenDisplay.isDesktopLayout(context);

    return Scaffold(
      appBar: AppBar(title: const Text('专注连续记录'), centerTitle: true),
      body: FutureBuilder<StreakData>(
        future: _streakFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    '加载数据时出错',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _loadStreakData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('重新加载'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              _loadStreakData();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 24.0 : 16.0,
                vertical: 16.0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      // 桌面端：上方两个卡片并排；移动端：垂直堆叠
                      if (isDesktop)
                        _buildTopCardsRow(context, data.currentStreak, data.bestStreak)
                      else
                        Column(
                          children: [
                            _buildCurrentStreakCard(context, data.currentStreak),
                            const SizedBox(height: 16),
                            _buildBestStreakCard(context, data.bestStreak),
                          ],
                        ),
                      const SizedBox(height: 16),

                      // 近 30 天专注日历
                      _buildCalendarCard(context, data.history),
                      const SizedBox(height: 16),

                      // 激励信息
                      _buildMotivationCard(context, data.currentStreak),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 桌面端顶部卡片并排布局
  Widget _buildTopCardsRow(BuildContext context, int currentStreak, int bestStreak) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildCurrentStreakCard(context, currentStreak),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildBestStreakCard(context, bestStreak),
        ),
      ],
    );
  }

  Widget _buildCurrentStreakCard(BuildContext context, int streak) {
    final colorScheme = Theme.of(context).colorScheme;
    final isBroken = streak == 0;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isBroken ? colorScheme.surfaceContainerHighest : Colors.orange,
      ),

      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Icon(
              isBroken
                  ? Icons.local_fire_department_outlined
                  : Icons.local_fire_department,
              size: 60,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Text(
              isBroken ? '已中断' : '当前连续',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$streak',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 64,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '天',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.tertiary,
                      ),
                    ),
                    Text(
                      isBroken ? '今天继续加油！' : '太棒了！',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestStreakCard(BuildContext context, int bestStreak) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.emoji_events,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '历史最佳记录',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '$bestStreak',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: colorScheme.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '天',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: colorScheme.onPrimaryContainer),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard(BuildContext context, List<int> history) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = ScreenDisplay.isDesktopLayout(context);
    final today = DateTime.now();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  color: colorScheme.outline,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '近 30 天专注记录',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 日历网格：移动端 7 列，桌面端单行显示
            isDesktop
                ? _buildSingleRowCalendar(context, history, today)
                : _buildGridCalendar(context, history, today),
            const SizedBox(height: 12),
            // 图例
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  context,
                  '未专注',
                  colorScheme.outline.withValues(alpha: 0.2),
                ),
                const SizedBox(width: 16),
                _buildLegendItem(context, '已专注', colorScheme.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 桌面端：单行显示 30 天日历
  Widget _buildSingleRowCalendar(BuildContext context, List<int> history, DateTime today) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (int i = 29; i >= 0; i--)
          _buildDayCell(
            context,
            history[29 - i],
            today.subtract(Duration(days: i)),
          ),
      ],
    );
  }

  /// 移动端：7 列网格显示日历
  Widget _buildGridCalendar(BuildContext context, List<int> history, DateTime today) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        final dayIndex = 29 - index;
        final date = today.subtract(Duration(days: dayIndex));
        return _buildDayCell(
          context,
          history[index],
          date,
        );
      },
    );
  }

  Widget _buildDayCell(BuildContext context, int status, DateTime date) {
    final colorScheme = Theme.of(context).colorScheme;
    final isToday =
        date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: status == 1
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: isToday
            ? Border.all(color: colorScheme.onSurface, width: 2)
            : null,
      ),
      child: Tooltip(
        message: '${date.month}月${date.day}日${status == 1 ? ' ✓' : ''}',
        child: status == 1
            ? Icon(Icons.check, size: 16, color: colorScheme.onSurface)
            : null,
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }

  Widget _buildMotivationCard(BuildContext context, int streak) {
    final colorScheme = Theme.of(context).colorScheme;

    String title;
    String message;
    IconData icon;

    if (streak == 0) {
      title = '新的开始';
      message = '今天开始你的第一次专注，开启连续记录吧！';
      icon = Icons.lightbulb_outline;
    } else if (streak < 3) {
      title = '初出茅庐';
      message = '你已经连续专注 $streak 天了，继续保持！';
      icon = Icons.trending_up;
    } else if (streak < 7) {
      title = '渐入佳境';
      message = '连续 $streak 天的专注，你正在变得更强！';
      icon = Icons.local_fire_department;
    } else if (streak < 14) {
      title = '持之以恒';
      message = '太厉害了！连续 $streak 天的专注记录！';
      icon = Icons.star;
    } else if (streak < 30) {
      title = '专注达人';
      message = '惊人的毅力！连续 $streak 天从未间断！';
      icon = Icons.emoji_events;
    } else {
      title = '传奇大师';
      message = '你是专注的传奇！连续 $streak 天的成就无人能及！';
      icon = Icons.workspace_premium;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StreakData {
  final int currentStreak;
  final int bestStreak;
  final List<int> history;

  StreakData({
    required this.currentStreak,
    required this.bestStreak,
    required this.history,
  });
}
