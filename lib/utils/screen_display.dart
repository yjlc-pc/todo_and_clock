import 'package:flutter/material.dart';

enum ScreenType { xsmall, small, medium, large, xlarge }

enum GeneralTextStyle { display, headline, title, label, body }

enum PaddingType { widgetMargin, widgetPadding, textMargin }

/// 屏幕宽度断点常量
class Breakpoint {
  /// 移动端与平板/桌面端的断点 (800px)
  static const double mobile = 800.0;
  
  /// 平板与桌面端的断点 (1200px)
  static const double tablet = 1200.0;
}

class ScreenDisplay {
  static ScreenType getScreenType(BuildContext context) {
    switch (MediaQuery.of(context).size.width) {
      case <= 600:
        return ScreenType.xsmall;

      case <= 800:
        return ScreenType.small;

      case <= 1200:
        return ScreenType.medium;

      case <= 1920:
        return ScreenType.large;

      case >= 1920:
        return ScreenType.xlarge;

      default:
        return ScreenType.medium;
    }
  }

  /// 判断是否为移动端布局（宽度 < 800px）
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < Breakpoint.mobile;
  }

  /// 判断是否为平板/桌面端布局（宽度 >= 800px）
  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= Breakpoint.mobile;
  }

  /// 判断是否为窄屏布局（可自定义断点）
  static bool isNarrowScreen(BuildContext context, {double breakpoint = Breakpoint.mobile}) {
    return MediaQuery.of(context).size.width < breakpoint;
  }

  static TextStyle getTextTheme(GeneralTextStyle style, BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    var screenType = getScreenType(context);
    switch (style) {
      case GeneralTextStyle.display:
        switch (screenType) {
          case ScreenType.xsmall:
            return textTheme.displaySmall!;
          case ScreenType.small:
            return textTheme.displaySmall!;
          case ScreenType.medium:
            return textTheme.displayMedium!;
          case ScreenType.large:
            return textTheme.displayLarge!;
          case ScreenType.xlarge:
            return textTheme.displayLarge!;
        }
      case GeneralTextStyle.headline:
        switch (screenType) {
          case ScreenType.xsmall:
            return textTheme.headlineSmall!;
          case ScreenType.small:
            return textTheme.headlineSmall!;
          case ScreenType.medium:
            return textTheme.headlineMedium!;
          case ScreenType.large:
            return textTheme.headlineLarge!;
          case ScreenType.xlarge:
            return textTheme.headlineLarge!;
        }
      case GeneralTextStyle.title:
        switch (screenType) {
          case ScreenType.xsmall:
            return textTheme.titleSmall!;
          case ScreenType.small:
            return textTheme.titleSmall!;
          case ScreenType.medium:
            return textTheme.titleMedium!;
          case ScreenType.large:
            return textTheme.titleLarge!;
          case ScreenType.xlarge:
            return textTheme.titleLarge!;
        }
      case GeneralTextStyle.label:
        switch (screenType) {
          case ScreenType.xsmall:
            return textTheme.labelSmall!;
          case ScreenType.small:
            return textTheme.labelSmall!;
          case ScreenType.medium:
            return textTheme.labelMedium!;
          case ScreenType.large:
            return textTheme.labelLarge!;
          case ScreenType.xlarge:
            return textTheme.labelLarge!;
        }
      case GeneralTextStyle.body:
        switch (screenType) {
          case ScreenType.xsmall:
            return textTheme.bodySmall!;
          case ScreenType.small:
            return textTheme.bodySmall!;
          case ScreenType.medium:
            return textTheme.bodyMedium!;
          case ScreenType.large:
            return textTheme.bodyLarge!;
          case ScreenType.xlarge:
            return textTheme.bodyLarge!;
        }
    }
  }

  static double getPaddingSize(BuildContext context, PaddingType type) {
    var screenType = getScreenType(context);
    switch (type) {
      case PaddingType.widgetMargin:
        switch (screenType) {
          case ScreenType.xsmall:
            return 16.0;
          case ScreenType.small:
            return 16.0;
          case ScreenType.medium:
            return 32.0;
          case ScreenType.large:
            return 48.0;
          case ScreenType.xlarge:
            return 64.0;
        }
      case PaddingType.widgetPadding:
        switch (screenType) {
          case ScreenType.xsmall:
            return 8.0;
          case ScreenType.small:
            return 8.0;
          case ScreenType.medium:
            return 12.0;
          case ScreenType.large:
            return 12.0;
          case ScreenType.xlarge:
            return 12.0;
        }
      case PaddingType.textMargin:
        switch (screenType) {
          case ScreenType.xsmall:
            return 4.0;
          case ScreenType.small:
            return 6.0;
          case ScreenType.medium:
            return 8.0;
          case ScreenType.large:
            return 8.0;
          case ScreenType.xlarge:
            return 8.0;
        }
    }
  }
}
