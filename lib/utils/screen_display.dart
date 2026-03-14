import 'package:flutter/material.dart';

/// 屏幕显示工具类
/// 负责判断布局类型和获取文本样式
class ScreenDisplay {
  /// 判断是否为移动端布局
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// 获取文本样式
  static TextStyle getTextTheme(GeneralTextStyle style, BuildContext context) {
    switch (style) {
      case GeneralTextStyle.title:
        return Theme.of(context).textTheme.titleMedium!;
      case GeneralTextStyle.body:
        return Theme.of(context).textTheme.bodyMedium!;
      case GeneralTextStyle.label:
        return Theme.of(context).textTheme.labelMedium!;
      case GeneralTextStyle.headline:
        return Theme.of(context).textTheme.headlineSmall!;
      case GeneralTextStyle.display:
        return Theme.of(context).textTheme.displaySmall!;
    }
  }
}

/// 通用文本样式类型
enum GeneralTextStyle {
  title,
  body,
  label,
  headline,
  display,
}
