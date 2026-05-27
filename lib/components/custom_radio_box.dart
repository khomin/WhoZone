import 'package:flutter/material.dart';
import 'package:flutter_demo/components/hover_click.dart';

class CustomRadioBox extends StatelessWidget {
  const CustomRadioBox({
    required this.value,
    required this.text,
    required this.onChanged,
    super.key,
  });
  final bool value;
  final String text;
  final Function() onChanged;

  @override
  Widget build(BuildContext context) {
    return HoverClick(
      onPressedL: (_) {
        onChanged();
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 5,
            ),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 2,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: BoxDecoration(
                    color: value ? Colors.white : Colors.transparent,
                    shape: BoxShape.circle),
              ),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
