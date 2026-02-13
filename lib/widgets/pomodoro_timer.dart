import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import '../models/pomodoro.dart';
import '../utils/database_helper.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({
    super.key,
    required this.task,
    required this.durationInMinutes,
  });

  final Task task;
  final int durationInMinutes;

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  late Timer _timer;
  late int _remainingSeconds; // 剩余秒数
  late bool _isRunning; // 是否计时中
  late bool _isRest; // false:正在专注，true:正在休息
  late bool _earlyExit; // 是否提前退出
  late DateTime _sessionStartTime; // 整个专注-休息会话的开始时间
  late String _title; //
  late int _focusDuration; // 专注时长
  final int _restDuration = 5; // 休息时长默认为5分钟

  @override
  void initState() {
    super.initState();
    _focusDuration = widget.durationInMinutes;
    _isRest = false; // 默认从专注时间开始
    _earlyExit = false; // 默认不是提前退出
    _title = '专注: ${widget.task.title}';
    _remainingSeconds = _focusDuration * 60; // 专注时间
    _isRunning = true;
    _sessionStartTime = DateTime.now(); // 记录整个会话的开始时间

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isRunning) {
        setState(() {
          _remainingSeconds--;
        });
      } else if (_remainingSeconds <= 0) {
        if (!_isRest) {
          // 专注时间结束，进入休息时间
          _switchToRest();
        } else {
          // 休息时间结束，整个番茄钟完成
          _endTimer();
        }
      }
    });
  }

  void _switchToRest() {
    // 不再保存专注阶段的记录，直接切换到休息模式
    setState(() {
      _isRest = true;
      _title = '休息: ${widget.task.title}';
      _remainingSeconds = _restDuration * 60; // 重置为休息时间
    });
  }

  void _endTimer() async {
    _timer.cancel();
    _isRunning = false;

    // 保存完整的专注-休息周期记录到数据库
    try {
      await _saveCompleteSession();
    } catch (e) {
      debugPrint('Error saving complete session: $e');
    }

    // 显示完成提示
    _showCompletionDialog();
  }

  /// 保存完整的专注-休息周期记录
  Future<void> _saveCompleteSession() async {
    final totalDuration = _focusDuration + _restDuration; // 总时长 = 专注时间 + 休息时间
    final pomodoro = Pomodoro(
      taskId: widget.task.id ?? 0,
      title: _earlyExit
          ? '中断周期: ${widget.task.title}'
          : '完整周期: ${widget.task.title}', // 根据是否提前退出设置标题
      startTime: _sessionStartTime, // 使用会话开始时间
      endTime: DateTime.now(), // 使用当前时间作为整个周期的结束时间
      duration: totalDuration, // 总时长
      isCompleted: !_earlyExit, // 只有非提前退出才算完成
      isRest: false, // 将完整周期标记为非休息时间
      earlyExit: _earlyExit, // 设置提前退出标志
      createdAt: DateTime.now(),
    );

    final dbHelper = DatabaseHelper.instance;
    await dbHelper.createPomodoro(pomodoro);
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 防止意外关闭
      builder: (context) {
        return AlertDialog(
          title: const Text('番茄钟已完成！'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('任务: ${widget.task.title}'),
              Text('时长: ${widget.durationInMinutes}分钟'),
              Text('类型: ${_isRest ? '休息' : '专注'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框并返回
                Navigator.of(context).pop(true); // 返回到上一个页面并传递完成信号
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _togglePauseResume() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _isRest
        ? Theme.of(context)
              .colorScheme
              .primaryContainer // 绿色 - 休息时间
        : Theme.of(context).colorScheme.secondaryContainer; // 蓝色 - 专注时间

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _isRest
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _formatTime(_remainingSeconds),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: _isRest
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _togglePauseResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Text(
                    _isRunning ? '暂停' : '继续',
                    style: TextStyle(
                      color: _isRest
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () async {
                    // 结束当前番茄钟
                    _timer.cancel();
                    _earlyExit = true; // 标记为提前退出

                    // 如果已经开始了专注阶段，则保存部分完成的周期
                    if (_sessionStartTime.isBefore(DateTime.now())) {
                      try {
                        final actualDuration = DateTime.now()
                            .difference(_sessionStartTime)
                            .inMinutes;
                        final pomodoro = Pomodoro(
                          taskId: widget.task.id ?? 0,
                          title: '中断周期: ${widget.task.title}',
                          startTime: _sessionStartTime,
                          endTime: DateTime.now(),
                          duration: actualDuration > 0 ? actualDuration : 0,
                          isCompleted: false, // 未完成完整周期
                          isRest: false, // 部分周期记录
                          earlyExit: true, // 标记为提前退出
                          createdAt: DateTime.now(),
                        );

                        final dbHelper = DatabaseHelper.instance;
                        await dbHelper.createPomodoro(pomodoro);
                      } catch (e) {
                        debugPrint('Error saving interrupted session: $e');
                      }
                    }

                    Navigator.of(context).pop(false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.3),
                  ),
                  child: Text(
                    '结束',
                    style: TextStyle(
                      color: _isRest
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
