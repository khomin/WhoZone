import 'package:flutter/material.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';

/// The pill every overlay control on the camera sits in.
class CameraChip extends StatelessWidget {
  static const height = 30.0;

  final Widget child;
  final EdgeInsets padding;

  const CameraChip({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    super.key,
  });

  static const textStyle = TextStyle(
    color: Colors.white,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    // digits keep their width, so a running clock doesn't wobble
    fontFeatures: [FontFeature.tabularFigures()],
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.colorButton,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [child]),
    );
  }
}

/// Elapsed time of the running capture, with a slowly pulsing dot.
class RecordingChip extends StatefulWidget {
  final String time;

  const RecordingChip({required this.time, super.key});

  @override
  State<RecordingChip> createState() => _RecordingChipState();
}

class _RecordingChipState extends State<RecordingChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.3,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CameraChip(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        FadeTransition(
          opacity: _pulse,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.colorButtonRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(widget.time, style: CameraChip.textStyle),
      ]),
    );
  }
}
