import 'package:flutter/material.dart';
import 'dart:async';
import '../models/task.dart';
import '../models/pomodoro.dart';
import '../utils/database_helper.dart';

class FocusPage extends StatefulWidget {
  const FocusPage({
    super.key,
    required this.task,
    required this.durationInMinutes,
  });

  final Task task;
  final int durationInMinutes;

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  late Timer _timer;
  late int _remainingSeconds; // 剩余秒数
  late bool _isRunning; // 是否计时中
  late bool _isRest; // false:正在专注，true:正在休息
  late bool _earlyExit; // 是否提前退出
  late DateTime _sessionStartTime; // 整个专注-休息会话的开始时间
  //
  late int _focusDuration; // 专注时长
  final int _restDuration = 5; // 休息时长默认为5分钟

  // 音乐播放相关状态
  bool _isPlaying = false;
  String _currentSong = "示例歌曲长名称";
  String _songArtist = "示例歌曲作者";

  @override
  void initState() {
    super.initState();
    _focusDuration = widget.durationInMinutes;
    _isRest = false; // 默认从专注时间开始
    _earlyExit = false; // 默认不是提前退出
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
                Navigator.of(context).pop(); // 关闭对话框并传递完成信号
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

  double get _progressPercentage {
    int totalTime;
    if (_isRest) {
      totalTime = _restDuration * 60;
    } else {
      totalTime = _focusDuration * 60;
    }

    int elapsedSeconds = totalTime - _remainingSeconds;
    return totalTime > 0 ? elapsedSeconds / totalTime : 0.0;
  }

  // 音乐播放控制方法
  void _playPrevious() {
    setState(() {
      _currentSong = "上一首歌曲";
      _songArtist = "示例歌手";
    });
  }

  void _playNext() {
    setState(() {
      _currentSong = "下一首歌曲";
      _songArtist = "示例歌手";
    });
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度以判断布局模式
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompactLayout = screenWidth < 768; // 小于768px使用紧凑布局

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('专注'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: isCompactLayout
          ? _buildCompactLayout() // 安卓紧凑版布局
          : _buildDesktopLayout(), // 桌面版布局
    );
  }

  // 桌面版布局 - 左右分栏
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // 左栏 - 歌曲信息区
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildMusicInfoCard(),
          ),
        ),
        // 右栏 - 专注时段控制区
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildFocusControlArea(),
          ),
        ),
      ],
    );
  }

  // 安卓紧凑版布局 - 垂直堆叠
  Widget _buildCompactLayout() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 上栏 - 专注时段控制区
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildFocusControlArea(),
          ),
          // 下栏 - 歌曲信息区
          Container(
            padding: const EdgeInsets.all(16.0),
            child: _buildMusicInfoCard(),
          ),
        ],
      ),
    );
  }

  // 构建歌曲信息卡片
  Widget _buildMusicInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey, Colors.black87],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 占位图片区域 - 模拟夜空月亮 + 白色花枝 + 传统瓦片屋顶
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Center(
                  child: Icon(Icons.music_note, size: 60, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              // 歌曲名
              Text(
                _currentSong,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 歌手
              Text(
                _songArtist,
                style: TextStyle(fontSize: 14, color: Colors.grey[300]),
              ),
              const Spacer(),
              // 播放控制按钮
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    color: Colors.white,
                    onPressed: _playPrevious,
                  ),
                  FloatingActionButton(
                    onPressed: _togglePlayPause,
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    child: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    color: Colors.white,
                    onPressed: _playNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 构建专注时段控制区域
  Widget _buildFocusControlArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 专注时段标题
        Text(
          '专注时段：${widget.task.title}',
          style: TextStyle(fontSize: 16, color: Colors.grey[300]),
        ),
        const SizedBox(height: 20),
        // 剩余时间标签和时间显示
        Text('剩余', style: TextStyle(fontSize: 16, color: Colors.grey[300])),
        const SizedBox(height: 8),
        Text(
          _formatTime(_remainingSeconds),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 30),
        // 进度条
        SizedBox(
          width: 360.0,
          child: LinearProgressIndicator(
            value: _progressPercentage,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(
              _isRest ? Colors.green : Colors.purple,
            ),
          ),
        ),
        const SizedBox(height: 40),
        // 操作按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 暂停按钮
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 48,
                child: ElevatedButton(
                  onPressed: _togglePauseResume,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                      const SizedBox(width: 8),
                      Text(_isRunning ? '暂停' : '继续'),
                    ],
                  ),
                ),
              ),
            ),
            // 停止按钮
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 48,
                child: ElevatedButton(
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
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.close),
                      SizedBox(width: 8),
                      Text('停止'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
