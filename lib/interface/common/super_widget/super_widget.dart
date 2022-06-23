import 'package:flutter/material.dart';
import 'package:oees/infrastructure/constants.dart';
import 'package:oees/infrastructure/variables.dart';
import 'package:oees/interface/common/super_widget/base_widget.dart';
import 'package:oees/interface/common/super_widget/body.dart';
import 'package:oees/interface/common/super_widget/build_menu.dart';
import 'package:oees/interface/common/super_widget/error_widget.dart';
import 'package:oees/interface/common/super_widget/menu.dart';
import 'package:oees/interface/common/super_widget/screen_size_information.dart';

class SuperWidget extends StatefulWidget {
  final Widget childWidget;
  final Duration animationDuration;
  final double screenScaleRatio;
  final Function errorCallback;
  const SuperWidget({
    Key? key,
    required this.childWidget,
    this.animationDuration = const Duration(milliseconds: 100),
    this.screenScaleRatio = 0.4,
    required this.errorCallback,
  }) : super(key: key);

  @override
  State<SuperWidget> createState() => _SuperWidgetState();
}

class _SuperWidgetState extends State<SuperWidget> with SingleTickerProviderStateMixin {
  late Animation<double> scaleAnimation;
  late Animation<Offset> slideAnimation;
  late Animation<BorderRadius> borderRadiusAnimation;
  late ScrollController scrollController;
  late AnimationController animationController;

  @override
  void initState() {
    scrollController = ScrollController();
    animationController = AnimationController(vsync: this, duration: widget.animationDuration);
    borderRadiusAnimation =
        Tween<BorderRadius>(begin: const BorderRadius.all(Radius.circular(0.0)), end: const BorderRadius.all(Radius.circular(40.0)))
            .animate(animationController);
    slideAnimation = Tween<Offset>(begin: const Offset(-1, 0), end: const Offset(0, 0)).animate(animationController);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: isDarkTheme.value ? foregroundColor : backgroundColor,
        body: BaseWidget(
          builder: (BuildContext context, ScreenSizeInformation screenInfo) {
            return Stack(
              fit: StackFit.expand,
              children: [
                MenuWidget(
                  animationController: animationController,
                  context: context,
                  slideAnimation: slideAnimation,
                  menuItems: buildMenu(menuMapping, animationController),
                ),
                BodyWidget(
                  childWidget: widget.childWidget,
                  screenInfo: screenInfo,
                  animationDuration: widget.animationDuration,
                  borderRadiusAnimation: borderRadiusAnimation,
                  screenScaleRatio: widget.screenScaleRatio,
                  foregroundColor: foregroundColor,
                  backgroundColor: backgroundColor,
                ),
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isDarkTheme.value = !isDarkTheme.value;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20.0, 9.0, 20.0, 9.0),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                        color: isDarkTheme.value ? foregroundColor : backgroundColor,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 0),
                            blurRadius: 2,
                            spreadRadius: 1,
                            color: isDarkTheme.value
                                ? isMenuCollapsed
                                    ? foregroundColor
                                    : backgroundColor
                                : isMenuCollapsed
                                    ? backgroundColor
                                    : foregroundColor,
                          ),
                        ],
                      ),
                      child: Icon(
                        isDarkTheme.value ? Icons.nightlight : Icons.nightlight_outlined,
                        color: isDarkTheme.value ? backgroundColor : foregroundColor,
                      ),
                    ),
                  ),
                ),
                isLoggedIn
                    ? Positioned(
                        left: 100,
                        bottom: 20,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (isMenuCollapsed) {
                                animationController.forward();
                              } else {
                                animationController.reverse();
                              }
                              isMenuCollapsed = !isMenuCollapsed;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 10.0),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                              color: isDarkTheme.value ? foregroundColor : backgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 0),
                                  blurRadius: 2,
                                  spreadRadius: 1,
                                  color: isDarkTheme.value
                                      ? isMenuCollapsed
                                          ? foregroundColor
                                          : backgroundColor
                                      : isMenuCollapsed
                                          ? backgroundColor
                                          : foregroundColor,
                                ),
                              ],
                            ),
                            child: Text(
                              "Menu",
                              style: TextStyle(
                                color: isDarkTheme.value ? backgroundColor : foregroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(),
                isError
                    ? ErrorDisplayWidget(
                        callback: widget.errorCallback,
                      )
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}
