import 'dart:math' as math;

import 'package:flutter/material.dart';

class PieChart extends StatefulWidget {
  @override
  _PieChartState createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  final List<PieSlice> data = [
    PieSlice('Mobile', 40, Colors.blue),
    PieSlice('Desktop', 30, Colors.green),
    PieSlice('Tablet', 20, Colors.orange),
    PieSlice('Other', 10, Colors.red),
  ];

  int selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom Interactive Pie Chart')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                child: CustomPieChart(
                  data: data,
                  selectedIndex: selectedIndex,
                  onSliceSelected: (index) {
                    setState(() {
                      selectedIndex = index == selectedIndex ? -1 : index;
                    });
                  },
                ),
              ),
            ),
          ),
          _buildLegend(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: data.asMap().entries.map((entry) {
          int index = entry.key;
          PieSlice slice = entry.value;
          bool isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index == selectedIndex ? -1 : index;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(color: isSelected ? slice.color.withOpacity(0.1) : null, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
                  ),
                  SizedBox(width: 12),
                  Text(slice.label, style: TextStyle(fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  Spacer(),
                  Text(
                    '${slice.value}%',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? slice.color : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class PieSlice {
  final String label;
  final double value;
  final Color color;

  PieSlice(this.label, this.value, this.color);
}

class CustomPieChart extends StatefulWidget {
  final List<PieSlice> data;
  final int selectedIndex;
  final Function(int) onSliceSelected;

  const CustomPieChart({Key? key, required this.data, required this.selectedIndex, required this.onSliceSelected}) : super(key: key);

  @override
  _CustomPieChartState createState() => _CustomPieChartState();
}

class _CustomPieChartState extends State<CustomPieChart> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: Duration(milliseconds: 1000), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return GestureDetector(
          onTapDown: (details) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final localPosition = renderBox.globalToLocal(details.globalPosition);
            final center = Offset(renderBox.size.width / 2, renderBox.size.height / 2);
            final radius = math.min(renderBox.size.width, renderBox.size.height) / 2;

            final dx = localPosition.dx - center.dx;
            final dy = localPosition.dy - center.dy;
            final distance = math.sqrt(dx * dx + dy * dy);

            if (distance <= radius) {
              double angle = math.atan2(dy, dx);
              if (angle < 0) angle += 2 * math.pi;

              final sliceIndex = _getSliceIndexFromAngle(angle);
              if (sliceIndex != -1) {
                widget.onSliceSelected(sliceIndex);
              }
            }
          },
          child: CustomPaint(
            painter: PieChartPainter(data: widget.data, selectedIndex: widget.selectedIndex, animationValue: _animation.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  int _getSliceIndexFromAngle(double angle) {
    double currentAngle = -math.pi / 2; // Start from top
    double total = widget.data.fold(0, (sum, slice) => sum + slice.value);

    for (int i = 0; i < widget.data.length; i++) {
      double sliceAngle = (widget.data[i].value / total) * 2 * math.pi;
      double endAngle = currentAngle + sliceAngle;

      // Normalize angles to 0-2π range
      double normalizedAngle = angle;
      double normalizedCurrentAngle = currentAngle;
      double normalizedEndAngle = endAngle;

      if (normalizedCurrentAngle < 0) {
        normalizedCurrentAngle += 2 * math.pi;
      }
      if (normalizedEndAngle < 0) {
        normalizedEndAngle += 2 * math.pi;
      }

      // Handle wrap-around case
      if (normalizedCurrentAngle > normalizedEndAngle) {
        if (normalizedAngle >= normalizedCurrentAngle || normalizedAngle <= normalizedEndAngle) {
          return i;
        }
      } else {
        if (normalizedAngle >= normalizedCurrentAngle && normalizedAngle <= normalizedEndAngle) {
          return i;
        }
      }

      currentAngle += sliceAngle;
    }
    return -1;
  }
}

class PieChartPainter extends CustomPainter {
  final List<PieSlice> data;
  final int selectedIndex;
  final double animationValue;

  PieChartPainter({required this.data, required this.selectedIndex, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;
    final total = data.fold(0.0, (sum, slice) => sum + slice.value);

    double currentAngle = -math.pi / 2; // Start from top

    for (int i = 0; i < data.length; i++) {
      final slice = data[i];
      final sliceAngle = (slice.value / total) * 2 * math.pi * animationValue;
      final isSelected = i == selectedIndex;
      final sliceRadius = isSelected ? radius + 10 : radius;

      // Calculate offset for selected slice
      final sliceCenter = isSelected
          ? Offset(center.dx + math.cos(currentAngle + sliceAngle / 2) * 8, center.dy + math.sin(currentAngle + sliceAngle / 2) * 8)
          : center;

      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.fill;

      // Draw slice
      final path = Path();
      path.moveTo(sliceCenter.dx, sliceCenter.dy);
      path.arcTo(Rect.fromCircle(center: sliceCenter, radius: sliceRadius), currentAngle, sliceAngle, false);
      path.close();

      canvas.drawPath(path, paint);

      // Draw stroke
      final strokePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawPath(path, strokePaint);

      // Draw percentage text
      if (animationValue > 0.8) {
        final textAngle = currentAngle + sliceAngle / 2;
        final textRadius = sliceRadius * 0.7;
        final textOffset = Offset(sliceCenter.dx + math.cos(textAngle) * textRadius, sliceCenter.dy + math.sin(textAngle) * textRadius);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${slice.value.toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(offset: Offset(1, 1), blurRadius: 2, color: Colors.black54)],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();
        textPainter.paint(canvas, Offset(textOffset.dx - textPainter.width / 2, textOffset.dy - textPainter.height / 2));
      }

      currentAngle += sliceAngle;
    }

    // Draw center circle for donut effect (optional)
    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 40, centerPaint);

    // Draw center stroke
    final centerStrokePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 40, centerStrokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
