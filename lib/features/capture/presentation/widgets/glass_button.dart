import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GlassTimerButton extends StatefulWidget {
  const GlassTimerButton({super.key});

  @override
  State<GlassTimerButton> createState() => _GlassTimerButtonState();
}

class _GlassTimerButtonState extends State<GlassTimerButton> {
  bool _isExpanded = false;
  int _selectedDuration = 1; // Default to 1 second

  final List<int> _durations = [1, 5, 10, 20];

  @override
  Widget build(BuildContext context) {
    // Dynamically calculate width based on state
    // Collapsed: just icon and text. Expanded: wider to fit the options.
    final double width = _isExpanded ? 280.0 : 90.0;
    final double height = _isExpanded ? 80.0 : 40.0;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2), // Standard iOS glass tint
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isExpanded
                          ? _buildExpandedContent()
                          : _buildCollapsedContent(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Mini pill state (Collapsed)
  Widget _buildCollapsedContent() {
    return Row(
      key: const ValueKey('collapsed'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          CupertinoIcons.timer,
          size: 18,
          color: Colors.white,
        ),
        const SizedBox(width: 6),
        Text(
          '$_selectedDurations',
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Row of options state (Expanded)
  Widget _buildExpandedContent() {
    return Row(
      key: const ValueKey('expanded'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDuration = duration;
              _isExpanded = false; // Auto-collapse after selection like iOS
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.2)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${duration}s',
              style: TextStyle(
                color: isSelected ? Colors.amber : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Helper getter for the collapsed string format
  String get _selectedDurations =>
      _selectedDuration == 1 ? '1 sec' : '$_selectedDuration sec';
}
