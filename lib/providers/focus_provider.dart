import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/pomodoro.dart';
import '../utils/database_helper.dart';

class FocusProvider extends ChangeNotifier {
  late Task _task;
  late int _durationInMinutes;

  // 番茄钟相关状态
  late Timer _timer;
  late int _remainingSeconds; // 剩余秒数
  late bool _isRunning; // 是否计时中
  late bool _isRest; // false:正在专注，true:正在休息
  late bool _earlyExit; // 是否提前退出
  late DateTime _sessionStartTime; // 整个专注-休息会话的开始时间
  late int _focusDuration; // 专注时长
  final int _restDuration = 5; // 休息时长默认为5分钟

  // 音乐播放相关状态

  // 完成状态
  bool _isCompleted = false;

  // Getters
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isRest => _isRest;
  bool get earlyExit => _earlyExit;
  DateTime get sessionStartTime => _sessionStartTime;
  int get focusDuration => _focusDuration;
  int get restDuration => _restDuration;
  double get progressPercentage {
    int totalTime = _isRest ? _restDuration * 60 : _focusDuration * 60;
    int elapsedSeconds = totalTime - _remainingSeconds;
    return totalTime > 0 ? elapsedSeconds / totalTime : 0.0;
  }

  String get formattedTime => _formatTime(_remainingSeconds);
  bool get isCompleted => _isCompleted;

  // 初始化方法
  void initialize(Task task, int durationInMinutes) {
    _task = task;
    _durationInMinutes = durationInMinutes;

    _focusDuration = _durationInMinutes;
    _isRest = false; // 默认从专注时间开始
    _earlyExit = false; // 默认不是提前退出
    _remainingSeconds = _focusDuration * 60; // 专注时间
    _isRunning = true;
    _sessionStartTime = DateTime.now(); // 记录整个会话的开始时间
    _isCompleted = false; // 重置完成状态

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isRunning) {
        _remainingSeconds--;
        notifyListeners();
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
    _isRest = true;
    _remainingSeconds = _restDuration * 60; // 重置为休息时间
    notifyListeners();
  }

  void _endTimer() async {
    _timer.cancel();
    _isRunning = false;
    _isCompleted = true;

    // 保存完整的专注-休息周期记录到数据库
    try {
      await _saveCompleteSession();
    } catch (e) {
      debugPrint('Error saving complete session: $e');
    }

    notifyListeners();
  }

  /// 保存完整的专注-休息周期记录
  Future<void> _saveCompleteSession() async {
    final totalDuration = _focusDuration + _restDuration; // 总时长 = 专注时间 + 休息时间
    final pomodoro = Pomodoro(
      taskId: _task.id ?? 0,
      title: _earlyExit
          ? '中断周期: ${_task.title}'
          : '完整周期: ${_task.title}', // 根据是否提前退出设置标题
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

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // 音乐播放控制方法

  void stopTimer() {
    _timer.cancel();
    _earlyExit = true; // 标记为提前退出

    // 如果已经开始了专注阶段，则保存部分完成的周期
    if (_sessionStartTime.isBefore(DateTime.now())) {
      _saveInterruptedSession();
    }
  }

  Future<void> _saveInterruptedSession() async {
    try {
      final actualDuration = DateTime.now()
          .difference(_sessionStartTime)
          .inMinutes;
      final pomodoro = Pomodoro(
        taskId: _task.id ?? 0,
        title: '中断周期: ${_task.title}',
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
