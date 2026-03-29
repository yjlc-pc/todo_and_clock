import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/pomodoro.dart';

/// 连续专注卡片 - 放在应用右上角，点击可进入 StreakPage
class StreakCard extends StatefulWidget {
  final VoidCallback? onTap;

  const StreakCard({super.key, this.onTap});

  @override
  State<StreakCard> createState() => _StreakCardState();
}

class _StreakCardState extends State<StreakCard> {
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  Future<void> _loadStreak() async {
    final dbHelper = DatabaseHelper.instance;
    final pomodoros = await dbHelper.readAllPomodoros();
    
    final completedFocusPomodoros = pomodoros
        .where((p) => p.isCompleted && !p.isRest)
        .toList();

    final streaks = _calculateStreaks(completedFocusPomodoros);
    
    setState(() {
      _currentStreak = streaks['current'] ?? 0;
    });
  }

  Map<String, int> _calculateStreaks(List<Pomodoro> pomodoros) {
    if (pomodoros.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    Set<String> uniqueDates = {};
    for (var pomodoro in pomodoros) {
      final dateStr = '${pomodoro.startTime.year}-${pomodoro.startTime.month}-${pomodoro.startTime.day}';
      uniqueDates.add(dateStr);
    }

    List<DateTime> dates = uniqueDates
        .map((d) {
          final parts = d.split('-');
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        })
        .toList();
    
    dates.sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return {'current': 0, 'best': 0};
    }

    int currentStreak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    
    bool hasToday = dates.any((d) => 
      d.year == todayDate.year && d.month == todayDate.month && d.day == todayDate.day);
    bool hasYesterday = dates.any((d) => 
      d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day);

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

    return {'current': currentStreak, 'best': 0};
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: _currentStreak == 0
                ? [colorScheme.outline.withValues(alpha: 0.3), colorScheme.outline.withValues(alpha: 0.1)]
                : [Colors.orange, Colors.deepOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_currentStreak == 0 ? Colors.grey : Colors.orange).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _currentStreak == 0 ? Icons.local_fire_department_outlined : Icons.local_fire_department,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              '$_currentStreak',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Text(
              '天',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
