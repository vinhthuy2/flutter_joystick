import 'dart:math' as Math;

import 'package:flutter/material.dart';

class JoyStick extends StatefulWidget {
  const JoyStick({super.key, required this.radius, required this.stickRadius, required this.callback});

  final double radius;
  final double stickRadius;
  final Function callback;

  @override
  State<JoyStick> createState() => _JoyStickState();
}

class _JoyStickState extends State<JoyStick> {
  final GlobalKey _joyStickContainer = GlobalKey();
  double yOff = 0, xOff = 0;
  double _x = 0, _y = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      final RenderBox renderBoxWidget = _joyStickContainer.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBoxWidget.localToGlobal(Offset.zero);

      xOff = offset.dx;
      yOff = offset.dy;
    });

    _centerStick();
  }

  void _centerStick() {
    setState(() {
      _x = widget.radius;
      _y = widget.radius;
    });

    _sendCoordinates(_x, _y);
  }

  void _sendCoordinates(double x, double y) {
    double speed = y - widget.radius;
    double direction = x - widget.radius;

    var vSpeed = -1 * map(speed, 0, (widget.radius - widget.stickRadius).floor(), 0, 100);
    var vDirection = map(direction, 0, (widget.radius - widget.stickRadius).floor(), 0, 100);

    widget.callback(vDirection, vSpeed);
  }

  int map(x, in_min, in_max, out_min, out_max) {
    return ((x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min).floor();
  }

  void _onPointerMove(PointerEvent event) {
    var x = event.position.dx - xOff;
    var y = event.position.dy - yOff;

    var distance = getDistance(x, y, widget.radius, widget.radius);

    if (distance > widget.radius - widget.stickRadius) {
      var deltaX = (x - widget.radius) / distance * (widget.radius - widget.stickRadius);
      var deltaY = (y - widget.radius) / distance * (widget.radius - widget.stickRadius);

      x = widget.radius + deltaX;
      y = widget.radius + deltaY;
    }

    setState(() {
      _x = x;
      _y = y;
    });

    _sendCoordinates(x, y);
  }

  void _onPointerUp(PointerEvent event) {
    _centerStick();
  }

  double getDistance(double x1, double y1, double x2, double y2) {
    return Math.sqrt(Math.pow((x2 - x1), 2) + Math.pow((y2 - y1), 2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Listener(
          behavior: HitTestBehavior.opaque,
          onPointerMove: _onPointerMove,
          onPointerUp: _onPointerUp,
          child: Container(
            key: _joyStickContainer,
            width: widget.radius * 2,
            height: widget.radius * 2,
            decoration: BoxDecoration(color: const Color.fromARGB(255, 160, 186, 208), borderRadius: BorderRadius.circular(widget.radius)),
            child: Stack(
              children: [
                Positioned(
                  left: _x - widget.stickRadius,
                  top: _y - widget.stickRadius,
                  child: Container(
                    width: widget.stickRadius * 2,
                    height: widget.stickRadius * 2,
                    decoration: BoxDecoration(color: const Color.fromARGB(255, 62, 117, 145), borderRadius: BorderRadius.circular(widget.stickRadius)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
