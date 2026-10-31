import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/features/capture/presentation/widgets/camera_chip.dart';

/// Capture interval. A chip with the current value that opens in place into a
/// row of values, the same way the iOS camera does it.
class TimerGlassButton extends StatefulWidget {
  final ValueChanged<int>? onDurationChanged;
  final int initialDuration;

  const TimerGlassButton({
    super.key,
    this.onDurationChanged,
    this.initialDuration = 1,
  });

  @override
  State<TimerGlassButton> createState() => _TimerGlassButtonState();
}

class _TimerGlassButtonState extends State<TimerGlassButton> {
  static const _durations = [1, 3, 6, 10, 20, 30];
  // Screen margins, the timer icon and the recording chip on the other side.
  // The open row has to fit between them on any screen width.
  static const _reservedWidth = 190.0;

  late int _selected = widget.initialDuration;
  bool _expanded = false;

  void _select(int seconds) {
    setState(() {
      _selected = seconds;
      _expanded = false;
    });
    widget.onDurationChanged?.call(seconds);
  }

  @override
  Widget build(BuildContext context) {
    final optionWidth =
        ((MediaQuery.sizeOf(context).width - _reservedWidth) / _durations.length)
            .clamp(26.0, 32.0);
    return TapRegion(
      onTapOutside: (_) {
        if (_expanded) setState(() => _expanded = false);
      },
      child: CameraChip(
        padding: EdgeInsets.zero,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.centerLeft,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(
                    CupertinoIcons.timer,
                    size: 15,
                    color: _expanded
                        ? AppColorScheme.accentDark
                        : Colors.white,
                  ),
                  if (!_expanded) ...[
                    const SizedBox(width: 5),
                    Text('${_selected}s', style: CameraChip.textStyle),
                  ],
                ]),
              ),
            ),
            if (_expanded)
              Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  for (final seconds in _durations)
                    _DurationOption(
                      label: '${seconds}s',
                      width: optionWidth,
                      selected: seconds == _selected,
                      onTap: () => _select(seconds),
                    ),
                ]),
              ),
          ]),
        ),
      ),
    );
  }
}

class _DurationOption extends StatelessWidget {
  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  const _DurationOption({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: width,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColorScheme.accentDark : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: CameraChip.textStyle.copyWith(
            color: selected ? const Color(0xFF0E1110) : Colors.white,
          ),
        ),
      ),
    );
  }
}
