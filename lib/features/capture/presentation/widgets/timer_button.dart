import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

class _TimerGlassButtonState extends State<TimerGlassButton>
    with SingleTickerProviderStateMixin {
  static const _durations = [1, 5, 10, 20, 30, 60];

  late int _selected;
  bool _expanded = false;
  bool _gridMounted = false; // unmounted only after animation fully reverses
  bool _tapped = false;

  late final AnimationController _controller;
  late final Animation<double> _expandAnim;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _pillFadeAnim;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDuration;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _expandAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _pillFadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Unmount grid only once animation has fully reversed
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() => _gridMounted = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_expanded) {
      _expanded = false;
      _controller.reverse();
      // _gridMounted stays true until dismissed (via listener)
    } else {
      setState(() {
        _expanded = true;
        _gridMounted = true;
      });
      _controller.forward();
    }
  }

  void _selectDuration(int seconds) {
    setState(() => _selected = seconds);
    widget.onDurationChanged?.call(seconds);
    Future.delayed(const Duration(milliseconds: 180), _toggle);
    // _toggle();
  }

  String _label(int seconds) {
    if (seconds == 1) return '1 sec';
    if (seconds < 60) return '$seconds sec';
    return '1 min';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _GlassContainer(
          borderRadius: 26.0,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _tapped = true),
            onTapUp: (_) async {
              _toggle();
              await Future.delayed(const Duration(milliseconds: 120));
              if (mounted) setState(() => _tapped = false);
            },
            onTapCancel: () => setState(() => _tapped = false),
            child: AnimatedOpacity(
              opacity: _tapped ? 0.55 : 1.0,
              duration: const Duration(milliseconds: 80),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: _expanded ? 160 : 80,
                height: _expanded ? 150 : 34,
                color: Colors.transparent,
                child: ClipRect(
                  child: Stack(
                    children: [
                      // ── Collapsed pill ──────────────────────────
                      Positioned(
                        top: 7,
                        left: 0,
                        right: 0,
                        child: FadeTransition(
                          opacity: _pillFadeAnim,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                CupertinoIcons.timer,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _label(_selected),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ── Expanded grid ───────────────────────────
                      Positioned(
                        // top: 10,
                        // left: 8,
                        // right: 8,
                        child: FadeTransition(
                          opacity: _fadeAnim,
                          child: _DurationGrid(
                            durations: _durations,
                            selected: _selected,
                            onSelect: _selectDuration,
                            labelOf: _label,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glass container ──────────────────────────────────────────────────────────

class _GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;

  const _GlassContainer({required this.child, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.25),
              width: 0.8,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ─── Duration grid ────────────────────────────────────────────────────────────

class _DurationGrid extends StatelessWidget {
  final List<int> durations;
  final int selected;
  final ValueChanged<int> onSelect;
  final String Function(int) labelOf;

  const _DurationGrid({
    required this.durations,
    required this.selected,
    required this.onSelect,
    required this.labelOf,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < durations.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _DurationChip(
                  label: labelOf(durations[i]),
                  selected: durations[i] == selected,
                  onTap: () => onSelect(durations[i]),
                ),
                const SizedBox(width: 10),
                _DurationChip(
                  label: labelOf(durations[i + 1]),
                  selected: durations[i + 1] == selected,
                  onTap: () => onSelect(durations[i + 1]),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 58,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withOpacity(0.2),
            width: 0.8,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? Colors.black.withOpacity(0.85) : Colors.white,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}
