import 'dart:math' as math;

import 'package:flutter/material.dart';

class WheelSelect extends StatefulWidget {
  @override
  _WheelSelectState createState() => _WheelSelectState();
}

class _WheelSelectState extends State<WheelSelect> {
  final List<WheelOption> options = [
    WheelOption(Icons.gamepad, 'Gaming', Colors.blue),
    WheelOption(Icons.book, 'Reading', Colors.green),
    WheelOption(Icons.music_note, 'Music', Colors.orange),
    WheelOption(Icons.sports, 'Sports', Colors.red),
    WheelOption(Icons.art_track, 'Art', Colors.purple),
    WheelOption(Icons.food_bank, 'Cooking', Colors.teal),
    WheelOption(Icons.travel_explore, 'Travel', Colors.indigo),
    WheelOption(Icons.device_hub, 'Tech', Colors.pink),
  ];

  int selectedIndex = 0;
  String selectedAction = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Wheel Selection')),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text(
            'Select your favorite activity',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Container(
                width: 320,
                height: 320,
                child: WheelSelector(
                  options: options,
                  selectedIndex: selectedIndex,
                  onOptionSelected: (index, action) {
                    setState(() {
                      selectedIndex = index;
                      selectedAction = action;
                    });
                  },
                  onDismiss: () => setState(() {
                    // Dismiss the wheel
                  }),
                ),
              ),
            ),
          ),
          _buildSelectionInfo(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSelectionInfo() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: options[selectedIndex].color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: options[selectedIndex].color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(options[selectedIndex].icon, size: 24),
              SizedBox(width: 12),
              Text(
                options[selectedIndex].label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: options[selectedIndex].color,
                ),
              ),
            ],
          ),
          if (selectedAction.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              'Selected by: $selectedAction',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class WheelOption {
  final IconData icon;
  final String label;
  final Color color;

  WheelOption(this.icon, this.label, this.color);
}

class WheelSelector extends StatefulWidget {
  final List<WheelOption> options;
  final int selectedIndex;
  final Function(int, String) onOptionSelected;
  final VoidCallback onDismiss;

  const WheelSelector({
    Key? key,
    required this.options,
    required this.selectedIndex,
    required this.onOptionSelected,
    required this.onDismiss,
  }) : super(key: key);

  @override
  _WheelSelectorState createState() => _WheelSelectorState();
}

class _WheelSelectorState extends State<WheelSelector>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isDragging = false;
  Offset? _dragPosition;
  int _hoveredIndex = -1;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onDismiss,
      onTapDown: (details) {
        final center = _getCenter(context);
        final distance = _getDistanceFromCenter(details.localPosition, center);

        // Only allow selection if tap is on a slice (not center)
        if (distance > 50) {
          final selectedIndex = _getSliceIndexFromPosition(
            details.localPosition,
          );
          if (selectedIndex != -1) {
            _selectOption(selectedIndex, 'tap');
          }
        }
      },
      onPanStart: (details) {
        final center = _getCenter(context);
        final distance = _getDistanceFromCenter(details.localPosition, center);

        // Only start drag from center area
        if (distance <= 50) {
          setState(() {
            _isDragging = true;
            _dragPosition = details.localPosition;
          });
        }
      },
      onPanUpdate: (details) {
        if (!_isDragging) return;

        setState(() {
          _dragPosition = details.localPosition;
        });

        // Check which slice we're dragging toward
        final selectedIndex = _getSliceIndexFromPosition(details.localPosition);
        if (selectedIndex != -1 && selectedIndex != _hoveredIndex) {
          setState(() {
            _hoveredIndex = selectedIndex;
          });
        }
      },
      onPanEnd: (details) {
        if (_isDragging) {
          final selectedIndex = _getSliceIndexFromPosition(
            details.localPosition,
          );
          if (selectedIndex != -1) {
            _selectOption(selectedIndex, 'drag');
          }

          setState(() {
            _isDragging = false;
            _dragPosition = null;
            _hoveredIndex = -1;
          });
        }
      },
      onPanCancel: () {
        setState(() {
          _isDragging = false;
          _dragPosition = null;
          _hoveredIndex = -1;
        });
      },
      child: AnimatedBuilder(
        animation: Listenable.merge([_scaleAnimation, _pulseAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: WheelPainter(
              options: widget.options,
              selectedIndex: widget.selectedIndex,
              isDragging: _isDragging,
              dragPosition: _dragPosition,
              hoveredIndex: _hoveredIndex,
              pulseValue: _pulseAnimation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Offset _getCenter(BuildContext context) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return Offset.zero;
    return Offset(renderBox.size.width / 2, renderBox.size.height / 2);
  }

  double _getDistanceFromCenter(Offset position, Offset center) {
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    return math.sqrt(dx * dx + dy * dy);
  }

  int _getSliceIndexFromPosition(Offset position) {
    final center = _getCenter(context);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;

    // Calculate angle from center to position
    double angle = math.atan2(dy, dx);

    // Convert to 0-2π range
    if (angle < 0) angle += 2 * math.pi;

    // Adjust to match the drawing coordinate system
    // The drawing starts at -π/2 (top), so we need to add π/2 to align
    angle = (angle + math.pi / 2) % (2 * math.pi);

    final sliceAngle = 2 * math.pi / widget.options.length;
    final sliceIndex = (angle / sliceAngle).floor() % widget.options.length;

    return sliceIndex;
  }

  void _selectOption(int index, String action) {
    if (index != widget.selectedIndex) {
      widget.onOptionSelected(index, action);
    }
  }
}

class WheelPainter extends CustomPainter {
  final List<WheelOption> options;
  final int selectedIndex;
  final bool isDragging;
  final Offset? dragPosition;
  final int hoveredIndex;
  final double pulseValue;

  WheelPainter({
    required this.options,
    required this.selectedIndex,
    required this.isDragging,
    this.dragPosition,
    required this.hoveredIndex,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    final sliceAngle = 2 * math.pi / options.length;

    // Draw outer ring
    final outerRingPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius + 5, outerRingPaint);

    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final startAngle = -math.pi / 2 + i * sliceAngle;
      final isSelected = i == selectedIndex;
      final isHovered = i == hoveredIndex;

      // Slice colors
      final baseColor = option.color;
      Color sliceColor;
      if (isSelected) {
        sliceColor = baseColor.withOpacity(0.9);
      } else if (isHovered) {
        sliceColor = baseColor.withOpacity(0.8);
      } else {
        sliceColor = baseColor.withOpacity(0.6);
      }

      // Draw slice
      final paint = Paint()
        ..color = sliceColor
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(center.dx, center.dy);
      path.arcTo(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sliceAngle,
        false,
      );
      path.close();

      canvas.drawPath(path, paint);

      // Draw slice border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawPath(path, borderPaint);

      // Draw selection/hover indicator
      if (isSelected || isHovered) {
        final indicatorPaint = Paint()
          ..color = isSelected ? Colors.white : Colors.white70
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 4 : 3;

        canvas.drawPath(path, indicatorPaint);
      }

      // Draw label
      final iconAngle = startAngle + sliceAngle / 2;
      final labelRadius = radius * 0.45;
      final labelOffset = Offset(
        center.dx + math.cos(iconAngle) * labelRadius,
        center.dy + math.sin(iconAngle) * labelRadius,
      );

      final labelSize = isSelected ? 14.0 : (isHovered ? 13.0 : 12.0);
      final labelPainter = TextPainter(
        text: TextSpan(
          text: option.label,
          style: TextStyle(
            color: Colors.white,
            fontSize: labelSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(
          labelOffset.dx - labelPainter.width / 2,
          labelOffset.dy - labelPainter.height / 2,
        ),
      );
    }

    // Draw center circle with pulsing effect
    final centerRadius = isDragging ? 50.0 : 40.0;
    final pulseRadius = centerRadius * pulseValue;

    // Draw pulsing background
    if (!isDragging) {
      final pulsePaint = Paint()
        ..color = Colors.blue.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    // Draw main center circle
    final centerPaint = Paint()
      ..color = isDragging ? Colors.blue.withOpacity(0.9) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, centerRadius, centerPaint);

    final centerBorderPaint = Paint()
      ..color = isDragging ? Colors.blue : Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, centerRadius, centerBorderPaint);

    // Draw center instruction text
    if (!isDragging) {
      final instructionPainter = TextPainter(
        text: TextSpan(
          text: 'Drag\nfrom\nhere',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 10,
            fontWeight: FontWeight.w500,
            height: 1.1,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );

      instructionPainter.layout();
      instructionPainter.paint(
        canvas,
        Offset(
          center.dx - instructionPainter.width / 2,
          center.dy - instructionPainter.height / 2,
        ),
      );
    }

    // Draw drag line
    if (isDragging && dragPosition != null) {
      final dragLinePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(center, dragPosition!, dragLinePaint);

      // Draw drag endpoint
      final dragEndPaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.fill;
      canvas.drawCircle(dragPosition!, 8, dragEndPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
