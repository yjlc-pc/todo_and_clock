import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/models/song.dart';
import 'package:todo_list_and_clock/widgets/pomodoro_timer.dart';
import '../models/task.dart';
import '../providers/focus_provider.dart';
import '../providers/music_provider.dart';
import '../utils/screen_display.dart';

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
  @override
  void initState() {
    super.initState();
    // 初始化FocusProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusProvider = Provider.of<FocusProvider>(context, listen: false);
      focusProvider.initialize(widget.task, widget.durationInMinutes);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      musicProvider.initialize([
        Song(
          title: "大鱼",
          artist: "周深",
          url: "https://",
          image: Image.network("localhost:8080"),
        ),
        // TODO: 从JSON文件
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        // 监听完成状态并显示对话框
        if (focusProvider.isCompleted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog(context);
          });
        }

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
              ? columnLayout(focusProvider) // 安卓紧凑版布局
              : rowLayout(focusProvider), // 桌面版布局
        );
      },
    );
  }

  void _showCompletionDialog(BuildContext context) {
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

  // 桌面版布局 - 左右分栏
  Widget rowLayout(FocusProvider focusProvider) {
    return Row(
      children: [
        // 左栏 - 歌曲信息区
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: musicInfoCard(focusProvider),
          ),
        ),
        // 右栏 - 专注时段控制区
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: focusControlSection(focusProvider),
          ),
        ),
      ],
    );
  }

  // 安卓紧凑版布局 - 垂直堆叠
  Widget columnLayout(FocusProvider focusProvider) {
    return Column(
      children: [
        // 上栏 - 专注时段控制区
        Container(
          padding: const EdgeInsets.all(16.0),
          child: focusControlSection(focusProvider),
        ),
        // 下栏 - 歌曲信息区
        Container(
          padding: const EdgeInsets.all(16.0),
          child: musicInfoCard(focusProvider),
        ),
      ],
    );
  }

  // 构建歌曲信息卡片
  Widget musicInfoCard(FocusProvider focusProvider) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Center(
            child: Column(
              children: [
                SizedBox(width: 48, height: 48, child: Placeholder()),
                Text(
                  musicProvider.currentSong.title,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.title,
                    context,
                  ),
                ),
                Text(
                  musicProvider.currentSong.artist,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.label,
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                musicPlayController(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget musicPlayController() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Row(
          children: [
            IconButton.outlined(
              onPressed: musicProvider.previousSong,
              icon: Icon(Icons.arrow_left),
            ),
            SizedBox(width: 16),
            IconButton.filled(
              onPressed: musicProvider.togglePlaying,
              icon: musicProvider.isPlaying
                  ? Icon(Icons.pause)
                  : Icon(Icons.play_arrow),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            SizedBox(width: 16),
            IconButton.outlined(
              onPressed: musicProvider.nextSong,
              icon: Icon(Icons.arrow_right),
            ),
          ],
        );
      },
    );
  }

  // 构建专注时段控制区域
  Widget focusControlSection(FocusProvider focusProvider) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: PomodoroTimer(
        durationInMinutes: widget.durationInMinutes,
      ),
    );
  }
}
