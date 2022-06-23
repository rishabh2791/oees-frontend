import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';

class BodyWidget extends StatefulWidget {
  final Widget childWidget;
  final ScreenSizeInformation screenInfo;
  final Duration animationDuration;
  final Animation<BorderRadius> borderRadiusAnimation;
  final double screenScaleRatio;
  final Color foregroundColor;
  final Color backgroundColor;
  const BodyWidget({
    Key? key,
    required this.childWidget,
    required this.screenInfo,
    required this.animationDuration,
    required this.borderRadiusAnimation,
    required this.screenScaleRatio,
    required this.foregroundColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  State<BodyWidget> createState() => _BodyWidgetState();
}

class _BodyWidgetState extends State<BodyWidget> {
  late ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: widget.animationDuration,
      left: isMenuCollapsed ? 0.0 : widget.screenInfo.screenSize.width * widget.screenScaleRatio,
      top: isMenuCollapsed ? 0.0 : -widget.screenInfo.screenSize.height * widget.screenScaleRatio / 2,
      right: isMenuCollapsed ? 0.0 : -widget.screenInfo.screenSize.width * widget.screenScaleRatio,
      bottom: isMenuCollapsed ? 0.0 : widget.screenInfo.screenSize.height * widget.screenScaleRatio / 2,
      child: Material(
        borderRadius: isMenuCollapsed ? const BorderRadius.all(Radius.circular(0.0)) : const BorderRadius.all(Radius.circular(40.0)),
        elevation: 5.0,
        child: AnimatedContainer(
          duration: widget.animationDuration,
          height: widget.screenInfo.screenSize.height,
          decoration: BoxDecoration(
              borderRadius: isMenuCollapsed ? const BorderRadius.all(Radius.circular(0.0)) : const BorderRadius.all(Radius.circular(40.0)),
              color: isDarkTheme.value ? backgroundColor : widget.foregroundColor,
              boxShadow: [
                BoxShadow(
                  color: isDarkTheme.value ? backgroundColor : widget.foregroundColor,
                  spreadRadius: 1,
                  blurRadius: 20,
                  offset: const Offset(0, 0), // changes position of shadow
                ),
              ]),
          child: SizedBox(
            height: widget.screenInfo.screenSize.height,
            width: widget.screenInfo.screenSize.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: widget.childWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
