/// 应用服务基类
/// 所有业务逻辑服务都应继承此类
abstract class BaseService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// 初始化服务
  Future<void> initialize() async {
    _isInitialized = true;
  }

  /// 清理资源
  void dispose() {
    _isInitialized = false;
  }
}
