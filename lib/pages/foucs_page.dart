import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';
import 'package:todo_list_and_clock/models/song.dart';
import 'package:todo_list_and_clock/widgets/pomodoro_timer.dart';
import '../models/task.dart';
import '../providers/focus_provider.dart';
import '../providers/music_provider.dart';
import '../utils/screen_display.dart';

/// 专注页面 - 包含番茄钟计时器和音乐播放器
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
  bool _hasShownCompletionDialog = false;

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  /// 初始化 FocusProvider 和 MusicProvider
  Future<void> _initializeProviders() async {
    // 初始化专注计时器
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusProvider = Provider.of<FocusProvider>(context, listen: false);
      focusProvider.initialize(widget.task, widget.durationInMinutes);
    });

    // 初始化音乐播放器
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      final jsonString = await rootBundle.loadString('assets/music/songs.json');
      final songs = await Song.loadSongsFromJson(jsonString);
      musicProvider.initialize(songs);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        // 检查是否需要显示完成对话框（只显示一次）
        if (focusProvider.isCompleted && !_hasShownCompletionDialog) {
          _hasShownCompletionDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog(context);
          });
        }

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
              ? _buildColumnLayout(focusProvider)
              : _buildRowLayout(focusProvider),
        );
      },
    );
  }

  /// 显示完成对话框
  void _showCompletionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  /// 构建桌面版布局（左右分栏）
  Widget _buildRowLayout(FocusProvider focusProvider) {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildMusicInfoCard(focusProvider)),
        Expanded(flex: 1, child: _buildFocusControlSection(focusProvider)),
      ],
    );
  }

  /// 构建移动版布局（垂直堆叠）
  Widget _buildColumnLayout(FocusProvider focusProvider) {
    return Column(
      children: [
        _buildFocusControlSection(focusProvider),
        _buildMusicInfoCard(focusProvider),
      ],
    );
  }

  /// 构建歌曲信息卡片
  Widget _buildMusicInfoCard(FocusProvider focusProvider) {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                musicProvider.currentSong.getImage(),
                const SizedBox(height: 12),
                Text(
                  musicProvider.currentSong.title,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.title,
                    context,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  musicProvider.currentSong.artist,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.label,
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                _buildMusicPlayController(),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建音乐播放控制器
  Widget _buildMusicPlayController() {
    return Consumer<MusicProvider>(
      builder: (context, musicProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPlaybackControls(colorScheme, musicProvider),
              _buildProgressSlider(colorScheme, musicProvider),
            ],
          ),
        );
      },
    );
  }

  /// 构建播放控制按钮
  Widget _buildPlaybackControls(
    ColorScheme colorScheme,
    MusicProvider musicProvider,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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
    );
  }

  /// 构建进度滑块
  Widget _buildProgressSlider(
    ColorScheme colorScheme,
    MusicProvider musicProvider,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
              activeTrackColor: colorScheme.primary,
              inactiveTrackColor: colorScheme.surfaceContainerLow,
              thumbColor: colorScheme.primary,
              overlayColor: colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: musicProvider.position.inSeconds.toDouble(),
              min: 0.0,
              max: musicProvider.duration.inSeconds.toDouble(),
              onChanged: (value) {
                musicProvider.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
          _buildTimeLabels(colorScheme, musicProvider),
        ],
      ),
    );
  }

  /// 构建时间标签
  Widget _buildTimeLabels(ColorScheme colorScheme, MusicProvider musicProvider) {
    return Row(
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
    );
  }

  /// 格式化时长显示
  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 构建专注控制区域
  Widget _buildFocusControlSection(FocusProvider focusProvider) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: PomodoroTimer(durationInMinutes: widget.durationInMinutes),
    );
  }
}
