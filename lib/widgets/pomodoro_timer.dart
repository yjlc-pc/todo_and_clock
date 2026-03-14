import 'package:flutter/material.dart';
import '../../view_models/focus_view_model.dart';

/// 番茄钟计时器组件
class PomodoroTimer extends StatelessWidget {
  const PomodoroTimer({
    super.key,
    required this.viewModel,
  });

  final FocusViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 360.0,
            child: LinearProgressIndicator(
              value: viewModel.progressPercentage,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(
                viewModel.isRest ? Colors.green : Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            viewModel.isRest ? '休息时间' : '专注时间',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text(
            viewModel.formattedTime,
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: viewModel.togglePauseResume,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                ),
                child: Text(viewModel.isRunning ? '暂停' : '继续'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: viewModel.stopTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
                child: Text(
                  '结束',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
