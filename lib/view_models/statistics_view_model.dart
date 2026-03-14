import '../services/data_services.dart';
import 'base_view_model.dart';

/// 统计 ViewModel
/// 负责统计数据的业务逻辑和状态管理
class StatisticsViewModel extends BaseViewModel {
  final PomodoroDataService _pomodoroDataService = PomodoroDataService();

  int _totalDuration = 0;
  int _completedCount = 0;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();

  int get totalDuration => _totalDuration;
  int get completedCount => _completedCount;
  DateTime get startDate => _startDate;
  DateTime get endDate => _endDate;

  /// 总专注时长（小时）
  double get totalHours => _totalDuration / 60.0;

  /// 平均每天专注时长（分钟）
  double get averageDailyDuration {
    final days = _endDate.difference(_startDate).inDays + 1;
    return days > 0 ? _totalDuration / days : 0;
  }

  @override
  Future<void> initialize() async {
    await loadStatistics();
  }

  /// 加载统计数据
  Future<void> loadStatistics() async {
    try {
      setLoading(true);
      final stats = await _pomodoroDataService.getStatistics(_startDate, _endDate);
      _totalDuration = stats['totalDuration'] ?? 0;
      _completedCount = stats['completedCount'] ?? 0;
      setLoading(false);
    } catch (e) {
      setError('加载统计数据失败：$e');
      setLoading(false);
    }
  }

  /// 设置日期范围
  void setDateRange(DateTime start, DateTime end) {
    _startDate = start;
    _endDate = end;
    loadStatistics();
  }

  /// 获取最近 7 天统计
  void loadLast7Days() {
    _startDate = DateTime.now().subtract(const Duration(days: 6));
    _endDate = DateTime.now();
    loadStatistics();
  }

  /// 获取最近 30 天统计
  void loadLast30Days() {
    _startDate = DateTime.now().subtract(const Duration(days: 29));
    _endDate = DateTime.now();
    loadStatistics();
  }

  /// 获取本周统计
  void loadThisWeek() {
    final now = DateTime.now();
    _startDate = now.subtract(Duration(days: now.weekday - 1));
    _endDate = now;
    loadStatistics();
  }

  /// 获取本月统计
  void loadThisMonth() {
    final now = DateTime.now();
    _startDate = DateTime(now.year, now.month, 1);
    _endDate = now;
    loadStatistics();
  }
}
