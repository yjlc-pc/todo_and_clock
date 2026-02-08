import 'package:flutter/material.dart';

class PomodoroTimerPicker extends StatefulWidget {
  const PomodoroTimerPicker({super.key});

  @override
  State<PomodoroTimerPicker> createState() => _PomodoroTimerPickerState();
}

class _PomodoroTimerPickerState extends State<PomodoroTimerPicker> {
  int _selectedMinutes = 25; // 默认25分钟

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('选择番茄钟时长'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$_selectedMinutes 分钟',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Slider(
            value: _selectedMinutes.toDouble(),
            min: 5,
            max: 60,
            divisions: 11, // (60-5)/5=11 divisions
            label: '${_selectedMinutes.toInt()}分钟',
            onChanged: (double value) {
              int roundedValue = (value / 5).round() * 5; // 四舍五入到最近的5的倍数
              roundedValue = roundedValue.clamp(5, 60); // 限制在5-60范围内
              setState(() {
                _selectedMinutes = roundedValue;
              });
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            children: [
              _buildQuickSelectButton(15),
              _buildQuickSelectButton(30),
              _buildQuickSelectButton(45),
              _buildQuickSelectButton(60),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 取消
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedMinutes); // 返回选择的时间
          },
          child: const Text('开始'),
        ),
      ],
    );
  }

  Widget _buildQuickSelectButton(int minutes) {
    return ChoiceChip(
      label: Text('$minutes分钟'),
      selected: _selectedMinutes == minutes,
      onSelected: (selected) {
        setState(() {
          _selectedMinutes = selected ? minutes : 25;
        });
      },
    );
  }
}
