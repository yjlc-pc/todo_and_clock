import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/focus_view_model.dart';
import '../../view_models/music_view_model.dart';
import '../../models/task.dart';
import '../../widgets/pomodoro_timer.dart';
import '../../widgets/music_player.dart';
import '../../utils/screen_display.dart';

/// 专注页面 - MVVM 架构的 View
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
    _initializeViewModels();
  }

  /// 初始化 ViewModel
  Future<void> _initializeViewModels() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final focusViewModel = Provider.of<FocusViewModel>(context, listen: false);
      focusViewModel.initializeFocus(widget.task, widget.durationInMinutes);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicViewModel = Provider.of<MusicViewModel>(context, listen: false);
      await musicViewModel.loadSongs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FocusViewModel>(
      builder: (context, focusViewModel, child) {
        if (focusViewModel.isCompleted && !_hasShownCompletionDialog) {
          _hasShownCompletionDialog = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showCompletionDialog(context);
          });
        }

        final isCompactLayout = ScreenDisplay.isMobileLayout(context);

        return Scaffold(
          appBar: _buildAppBar(),
          body: isCompactLayout
              ? _buildColumnLayout(focusViewModel)
              : _buildRowLayout(focusViewModel),
        );
      },
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text('专注'),
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
    );
  }

  /// 构建完成对话框
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

  /// 构建行布局（桌面版）
  Widget _buildRowLayout(FocusViewModel focusViewModel) {
    return Row(
      children: [
        Expanded(flex: 1, child: _buildMusicSection()),
        Expanded(flex: 1, child: _buildFocusSection(focusViewModel)),
      ],
    );
  }

  /// 构建列布局（移动版）
  Widget _buildColumnLayout(FocusViewModel focusViewModel) {
    return Column(
      children: [
        _buildFocusSection(focusViewModel),
        _buildMusicSection(),
      ],
    );
  }

  /// 构建音乐区域
  Widget _buildMusicSection() {
    return const MusicPlayer();
  }

  /// 构建专注区域
  Widget _buildFocusSection(FocusViewModel focusViewModel) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: PomodoroTimer(viewModel: focusViewModel),
    );
  }
}
