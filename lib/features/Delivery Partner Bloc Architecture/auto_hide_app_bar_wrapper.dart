import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AutoHideAppBarWrapper extends StatefulWidget {
  final Widget appBar;
  final Widget body;
  final double appBarHeight;
  final bool isMobile;

  const AutoHideAppBarWrapper({
    super.key,
    required this.appBar,
    required this.body,
    required this.appBarHeight,
    this.isMobile = true,
  });

  @override
  State<AutoHideAppBarWrapper> createState() => _AutoHideAppBarWrapperState();
}

class _AutoHideAppBarWrapperState extends State<AutoHideAppBarWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightFactor;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1.0, // Initial state: visible
    );

    _heightFactor = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _show() {
    if (!_controller.isAnimating && _controller.value < 1.0) {
      _controller.forward();
    }
  }

  void _hide() {
    if (!_controller.isAnimating && _controller.value > 0.0) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isMobile) {
      return Column(
        children: [
          widget.appBar,
          Expanded(child: widget.body),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is UserScrollNotification) {
          if (notification.direction == ScrollDirection.reverse) {
            _hide();
          } else if (notification.direction == ScrollDirection.forward) {
            _show();
          }
        }
        return false;
      },
      child: Column(
        children: [
          SizeTransition(
            sizeFactor: _heightFactor,
            axisAlignment: -1.0,
            child: SlideTransition(
              position: _slideAnim,
              child: SizedBox(
                height: widget.appBarHeight,
                child: widget.appBar,
              ),
            ),
          ),
          Expanded(
            child: widget.body,
          ),
        ],
      ),
    );
  }
}
