import 'package:diff_match_patch/diff_match_patch.dart';
import 'package:flutter/material.dart';

class DifferedText extends StatefulWidget {
  final String textA;
  final String textB;

  const DifferedText({super.key, required this.textA, required this.textB});

  @override
  State<StatefulWidget> createState() => _DifferedTextState();
}

class _DifferedTextState extends State<DifferedText> {
  final Map<int, Color> colorMap = {
    DIFF_INSERT: Colors.green.shade600,
    DIFF_EQUAL: Colors.black,
    DIFF_DELETE: Colors.red.shade600,
  };

  TextSpan createSpan(Diff span) {
    return TextSpan(
      text: span.text,
      style: TextStyle(color: colorMap[span.operation]),
    );
  }

  @override
  Widget build(BuildContext context) {
    var diffs = diff(
      widget.textA,
      widget.textB,
    ).where((d) => d.operation != DIFF_DELETE);

    return RichText(
      text: TextSpan(children: [for (var span in diffs) createSpan(span)]),
    );
  }
}
