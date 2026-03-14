import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/pomodoro.dart';
import '../services/data_services.dart';
import 'base_view_model.dart';

/// 专注 ViewModel
/// 负责番茄钟计时器的业务逻辑和状态管理
class FocusViewModel extends BaseViewModel {
  final PomodoroDataService _pomodoroDataService = PomodoroDataService();

  Task? _task;
  int _durationInMinutes = 25;
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isRest = false;
  bool _earlyExit = false;
  bool _isCompleted = false;
  DateTime _sessionStartTime = DateTime.now();
  int _focusDuration = 0;
  final int _restDuration = 5;

  Task? get task => _task;
  int get durationInMinutes => _durationInMinutes;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get isRest => _isRest;
  bool get earlyExit => _earlyExit;
  bool get isCompleted => _isCompleted;
  DateTime get sessionStartTime => _sessionStartTime;
  int get focusDuration => _focusDuration;
  int get restDuration => _restDuration;

  /// 格式化时间显示
  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 进度百分比
  double get progressPercentage {
    int totalTime = _isRest ? _restDuration * 60 : _focusDuration * 60;
    int elapsedSeconds = totalTime - _remainingSeconds;
    return totalTime > 0 ? elapsedSeconds / totalTime : 0.0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 初始化专注会话
  void initializeFocus(Task task, int durationInMinutes) {
    _task = task;
    _durationInMinutes = durationInMinutes;
    _focusDuration = durationInMinutes;
    _isRest = false;
    _earlyExit = false;
    _remainingSeconds = _focusDuration * 60;
    _isRunning = true;
    _sessionStartTime = DateTime.now();
    _isCompleted = false;
    _startTimer();
    notifyListeners();
  }

  /// 启动计时器
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0 && _isRunning) {
        _remainingSeconds--;
        notifyListeners();
      } else if (_remainingSeconds <= 0) {
        if (!_isRest) {
          _switchToRest();
        } else {
          _endTimer();
        }
      }
    });
  }

  /// 切换到休息模式
  void _switchToRest() {
    _isRest = true;
    _remainingSeconds = _restDuration * 60;
    notifyListeners();
  }

  /// 结束计时器
  void _endTimer() {
    _timer?.cancel();
    _isRunning = false;
    _isCompleted = true;
    _saveCompleteSession();
    notifyListeners();
  }

  /// 切换暂停/继续
  void togglePauseResume() {
    _isRunning = !_isRunning;
    notifyListeners();
  }

  /// 停止计时器（提前退出）
  void stopTimer() {
    _timer?.cancel();
    _earlyExit = true;
    _isRunning = false;
    _saveInterruptedSession();
    notifyListeners();
  }

  /// 保存完整的专注会话
  Future<void> _saveCompleteSession() async {
    try {
      final pomodoro = Pomodoro(
        taskId: _task?.id ?? 0,
        title: _earlyExit ? '中断周期：${_task?.title}' : '完整周期：${_task?.title}',
        startTime: _sessionStartTime,
        endTime: DateTime.now(),
        duration: _focusDuration,
        isCompleted: !_earlyExit,
        isRest: false,
        earlyExit: _earlyExit,
        createdAt: DateTime.now(),
      );
      await _pomodoroDataService.insertPomodoro(pomodoro);
    } catch (e) {
      debugPrint('保存完整会话失败：$e');
    }
  }

  /// 保存中断的会话
  Future<void> _saveInterruptedSession() async {
    try {
      int actualFocusDuration;
      if (_isRest) {
        actualFocusDuration = _focusDuration;
      } else {
        final elapsedSeconds = DateTime.now().difference(_sessionStartTime).inSeconds;
        final maxExpectedSeconds = _focusDuration * 60;
        int validElapsedSeconds = elapsedSeconds > maxExpectedSeconds
            ? maxExpectedSeconds
            : elapsedSeconds;
        actualFocusDuration = (validElapsedSeconds / 60).round();
        if (actualFocusDuration > _focusDuration) {
          actualFocusDuration = _focusDuration;
        }
      }

      final pomodoro = Pomodoro(
        taskId: _task?.id ?? 0,
        title: '中断周期：${_task?.title}',
        startTime: _sessionStartTime,
        endTime: DateTime.now(),
        duration: actualFocusDuration > 0 ? actualFocusDuration : 0,
        isCompleted: false,
        isRest: false,
        earlyExit: true,
        createdAt: DateTime.now(),
      );
      await _pomodoroDataService.insertPomodoro(pomodoro);
    } catch (e) {
      debugPrint('保存中断会话失败：$e');
    }
  }

  /// 重置状态
  void reset() {
    _timer?.cancel();
    _task = null;
    _isRunning = false;
    _isRest = false;
    _earlyExit = false;
    _isCompleted = false;
    _remainingSeconds = 0;
    notifyListeners();
  }
}
