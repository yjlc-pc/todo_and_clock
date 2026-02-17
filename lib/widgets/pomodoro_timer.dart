import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/focus_provider.dart';

class PomodoroTimer extends StatefulWidget {
  const PomodoroTimer({
    super.key,
    required this.durationInMinutes,
  });

  final int durationInMinutes;

  @override
  State<PomodoroTimer> createState() => _PomodoroTimerState();
}

class _PomodoroTimerState extends State<PomodoroTimer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<FocusProvider>(
      builder: (context, focusProvider, child) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 360.0,
                child: LinearProgressIndicator(
                  value: focusProvider.progressPercentage,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerLow,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    focusProvider.isRest ? Colors.green : Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                focusProvider.isRest ? '休息时间' : '专注时间',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Text(
                focusProvider.formattedTime,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // 切换暂停/继续状态
                      focusProvider.togglePauseResume();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainer,
                    ),
                    child: Text(focusProvider.isRunning ? '暂停' : '继续'),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      // 结束当前番茄钟
                      focusProvider.stopTimer();
                      Navigator.of(context).pop(false);
                    },
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
      },
    );
  }
}