import 'package:flutter/cupertino.dart';
import 'package:oees/interface/enums/screen_type.dart';

class ScreenSizeInformation {
  final Orientation orientation;
  final ScreenType screenType;
  final Size screenSize;
  final Size localWidgetSize;

  ScreenSizeInformation({
    required this.localWidgetSize,
    required this.orientation,
    required this.screenSize,
    required this.screenType,
  });
}
