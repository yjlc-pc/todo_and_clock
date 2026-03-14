import 'package:flutter/foundation.dart';

/// ViewModel 基类
/// 所有 ViewModel 都应继承此类，提供通用的生命周期管理
abstract class BaseViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool _isDisposed = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isDisposed => _isDisposed;
  String? get error => _error;

  /// 设置加载状态
  void setLoading(bool loading) {
    if (_isDisposed) return;
    _isLoading = loading;
    notifyListeners();
  }

  /// 设置错误信息
  void setError(String? error) {
    if (_isDisposed) return;
    _error = error;
    notifyListeners();
  }

  /// 清除错误
  void clearError() {
    if (_isDisposed) return;
    _error = null;
    notifyListeners();
  }

  /// 安全地通知监听器
  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  /// 清理资源
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// 初始化方法，由子类实现
  Future<void> initialize() async {}
}
