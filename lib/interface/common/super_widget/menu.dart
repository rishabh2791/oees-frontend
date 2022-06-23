import 'package:flutter/material.dart';

class MenuWidget extends StatefulWidget {
  final BuildContext context;
  final Animation<Offset> slideAnimation;
  final AnimationController animationController;
  final List<Widget> menuItems;
  const MenuWidget({
    Key? key,
    required this.animationController,
    required this.context,
    required this.slideAnimation,
    required this.menuItems,
  }) : super(key: key);

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  late ScrollController scrollController;
  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: widget.slideAnimation,
      child: Padding(
        padding: const EdgeInsets.only(right: 25.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.menuItems,
            ),
          ),
        ),
      ),
    );
  }
}
