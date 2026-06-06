import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/core/repository/app_theme.dart';
import 'package:flutter_demo/components/disposable_stream.dart';
import 'package:flutter_demo/features/history/domain/entities/history_state.dart';

class NoRecords extends StatefulWidget {
  NoRecords({required this.stream});
  final Stream<HistoryState> stream;

  @override
  State<NoRecords> createState() => _State();
}

class _State extends State<NoRecords> with TickerProviderStateMixin {
  late AnimationController _ctrShakeIcon;
  late final Animation<double> _iconRotate;
  final _disp = DisposableStream();

  @override
  void initState() {
    super.initState();

    _ctrShakeIcon = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _iconRotate = TweenSequence<double>([
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: 0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0.005, end: 0), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: 0, end: -0.005), weight: 1),
      TweenSequenceItem<double>(
          tween: Tween<double>(begin: -0.005, end: 0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _ctrShakeIcon.view,
      curve: Curves.linear,
    ));

    _disp.add(widget.stream.listen((v) {
      if (v.list.isEmpty) {
        _triggerAnimation();
      }
    }));
  }

  @override
  void dispose() {
    _ctrShakeIcon.dispose();
    _disp.dispose();
    super.dispose();
  }

  void _triggerAnimation() {
    if (!mounted) return;
    if (_ctrShakeIcon.isAnimating) return;
    if (_ctrShakeIcon.isForwardOrCompleted) {
      _ctrShakeIcon.reverse().orCancel;
    } else {
      _ctrShakeIcon.forward().orCancel;
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context);
    return RotationTransition(
      turns: _iconRotate,
      child: SizedBox(
        height: size.height / 1.5,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RoundButton(
                iconData: Icons.create_new_folder_rounded,
                color: Theme.of(context).colorScheme.colorPrimary,
                iconColor: Theme.of(context).colorScheme.colorBar,
                size: 100,
                iconSize: 80,
                useScaleAnimation: true,
                useShadow: true,
                onPressed: (_) {
                  _triggerAnimation();
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                child: Column(
                  children: [
                    Text(
                      'There are no entries yet',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.colorTextAccent,
                        fontSize: 18,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Click',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.colorTextAccent,
                            fontSize: 18,
                          ),
                        ),
                        Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Icon(Icons.create_new_folder_rounded,
                                color: Theme.of(context)
                                    .colorScheme
                                    .colorTextSecond
                                    .withValues(alpha: 0.5))),
                        Text(
                          'to start',
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.colorTextAccent,
                            fontSize: 18,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
