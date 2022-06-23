import 'package:flutter/material.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';
import 'package:oees/interface/enums/screen_type.dart';

class BaseWidget extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenSizeInformation sizeInfo) builder;
  const BaseWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  ScreenType getScreenType(MediaQueryData mediaQueryData) {
    double deviceWidth = 0;

    var orientation = mediaQueryData.orientation;
    if (orientation == Orientation.landscape) {
      deviceWidth = mediaQueryData.size.width;
    } else {
      deviceWidth = mediaQueryData.size.height;
    }
    if (deviceWidth > 1100) {
      return ScreenType.desktop;
    } else if (deviceWidth > 850) {
      return ScreenType.tablet;
    } else {
      return ScreenType.mobile;
    }
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        var screenSizeInformation = ScreenSizeInformation(
          orientation: mediaQuery.orientation,
          screenType: getScreenType(mediaQuery),
          screenSize: mediaQuery.size,
          localWidgetSize: Size(constraints.maxWidth, constraints.maxHeight),
        );
        return builder(context, screenSizeInformation);
      },
    );
  }
}
