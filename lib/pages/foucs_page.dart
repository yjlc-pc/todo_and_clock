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
    // 初始化 FocusProvider
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
        // TODO: 从 JSON 文件预置一些歌曲
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

        // 使用 ScreenDisplay 判断是否为移动端布局
        final isCompactLayout = ScreenDisplay.isMobileLayout(context);

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
              Text('任务：${widget.task.title}'),
              Text('时长：${widget.durationInMinutes}分钟'),
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
        Expanded(flex: 1, child: musicInfoCard(focusProvider)),
        // 右栏 - 专注时段控制区
        Expanded(flex: 1, child: focusControlSection(focusProvider)),
      ],
    );
  }

  // 安卓紧凑版布局 - 垂直堆叠
  Widget columnLayout(FocusProvider focusProvider) {
    return Column(
      children: [
        // 上栏 - 专注时段控制区
        focusControlSection(focusProvider),
        // 下栏 - 歌曲信息区
        musicInfoCard(focusProvider),
      ],
    );
  }

  // 构建歌曲信息卡片
  Widget musicInfoCard(FocusProvider focusProvider) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 96, height: 96, child: Placeholder()),
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
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 上一曲按钮
                  IconButton.filledTonal(
                    onPressed: musicProvider.previousSong,
                    icon: const Icon(Icons.skip_previous_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      fixedSize: const Size(48, 48),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 播放/暂停按钮（更大更突出）
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colorScheme.primary,
                    ),
                    child: IconButton(
                      onPressed: musicProvider.togglePlaying,
                      icon: Icon(
                        musicProvider.isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 32,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: colorScheme.onPrimary,
                        fixedSize: const Size(64, 64),
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // 下一曲按钮
                  IconButton.filledTonal(
                    onPressed: musicProvider.nextSong,
                    icon: const Icon(Icons.skip_next_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                      fixedSize: const Size(48, 48),
                    ),
                  ),
                ],
              ),
              // 播放进度条
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 14.0,
                        ),
                        activeTrackColor: colorScheme.primary,
                        inactiveTrackColor: colorScheme.surfaceContainerLow,
                        thumbColor: colorScheme.primary,
                        overlayColor: colorScheme.primary.withValues(
                          alpha: 0.2,
                        ),
                      ),
                      child: Slider(
                        value: musicProvider.position.inSeconds.toDouble(),
                        min: 0.0,
                        max: musicProvider.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          musicProvider.seekTo(
                            Duration(seconds: value.toInt()),
                          );
                        },
                      ),
                    ),
                    // 时间显示
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(musicProvider.position),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                        Text(
                          _formatDuration(musicProvider.duration),
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // 构建专注时段控制区域
  Widget focusControlSection(FocusProvider focusProvider) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: PomodoroTimer(durationInMinutes: widget.durationInMinutes),
    );
  }
}
