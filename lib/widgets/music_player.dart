import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/music_view_model.dart';
import '../../utils/screen_display.dart';

/// 音乐播放器组件
class MusicPlayer extends StatelessWidget {
  const MusicPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicViewModel>(
      builder: (context, viewModel, child) {
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                viewModel.currentSong.getImage(),
                const SizedBox(height: 12),
                Text(
                  viewModel.currentSong.title,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.title,
                    context,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  viewModel.currentSong.artist,
                  style: ScreenDisplay.getTextTheme(
                    GeneralTextStyle.label,
                    context,
                  ).copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 16),
                _buildPlaybackControls(viewModel, context),
                _buildProgressSlider(viewModel, context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建播放控制按钮
  Widget _buildPlaybackControls(MusicViewModel viewModel, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          onPressed: viewModel.previousSong,
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
            onPressed: viewModel.togglePlaying,
            icon: Icon(
              viewModel.isPlaying
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
          onPressed: viewModel.nextSong,
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
  Widget _buildProgressSlider(MusicViewModel viewModel, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              value: viewModel.position.inSeconds.toDouble(),
              min: 0.0,
              max: viewModel.duration.inSeconds.toDouble(),
              onChanged: (value) {
                viewModel.seekTo(Duration(seconds: value.toInt()));
              },
            ),
          ),
          _buildTimeLabels(viewModel, context),
        ],
      ),
    );
  }

  /// 构建时间标签
  Widget _buildTimeLabels(MusicViewModel viewModel, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _formatDuration(viewModel.position),
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: colorScheme.outline),
        ),
        Text(
          _formatDuration(viewModel.duration),
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
}
