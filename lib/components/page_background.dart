import 'package:flutter/material.dart';
import 'package:flutter_demo/repository/app_theme.dart';

class PageBackground extends StatelessWidget {
  const PageBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100,
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.colorBgUnderCard,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
      ),
    );
  }
}
