import 'package:flutter/material.dart';

/// 番茄钟时长选择器
class PomodoroTimerPicker extends StatefulWidget {
  const PomodoroTimerPicker({super.key});

  @override
  State<PomodoroTimerPicker> createState() => _PomodoroTimerPickerState();
}

class _PomodoroTimerPickerState extends State<PomodoroTimerPicker> {
  int _selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '选择专注时长',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          Text(
            '$_selectedMinutes 分钟',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11,
            label: '$_selectedMinutes 分钟',
            onChanged: (value) {
              setState(() {
                _selectedMinutes = (value / 5).round() * 5;
                _selectedMinutes = _selectedMinutes.clamp(5, 60);
              });
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [15, 25, 30, 45, 60].map((minutes) {
              return ChoiceChip(
                label: Text('$minutes 分钟'),
                selected: _selectedMinutes == minutes,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('取消'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(_selectedMinutes),
                child: const Text('开始'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
