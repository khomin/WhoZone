import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/repository/app_theme.dart';

class LoadRecords extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: size.height / 1.5,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RoundButton(
              iconData: Icons.pending,
              color: Theme.of(context).colorScheme.colorPrimary,
              iconColor: Theme.of(context).colorScheme.colorBar,
              size: 100,
              iconSize: 80,
              useScaleAnimation: true,
              useShadow: true,
              onPressed: (_) {},
            ),
            const SizedBox(height: 20),
            SizedBox(height: 80)
          ]),
    );
  }
}
