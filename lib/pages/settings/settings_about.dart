import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';

class SettingsAbout extends StatefulWidget {
  const SettingsAbout({super.key});

  @override
  State<SettingsAbout> createState() => SettingsAboutState();
}

class SettingsAboutState extends State<SettingsAbout> {
  final tag = 'settingsAbout';

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Theme.of(context).colorScheme.colorBar,
        child: SafeArea(
            child: Scaffold(
                backgroundColor: Theme.of(context).colorScheme.colorBar,
                body: Stack(alignment: Alignment.center, children: [
                  Positioned(
                      top: (kToolbarHeight * 2) - 30,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .colorBgUnderCard,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20))))),
                  CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                            backgroundColor:
                                Theme.of(context).colorScheme.colorBar,
                            automaticallyImplyLeading: false,
                            flexibleSpace: _sliverAppBar()),
                        SliverToBoxAdapter(child: _header()),
                        DecoratedSliver(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .colorBgUnderCard,
                            ),
                            sliver: SliverToBoxAdapter(child: _view()))
                      ])
                ]))));
  }

  Widget _sliverAppBar() {
    return Stack(children: [
      Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
              color: Theme.of(context).colorScheme.colorBar,
              height: kToolbarHeight,
              child: Row(children: [
                RoundButton(
                    padding: const EdgeInsets.only(left: 10),
                    color: Colors.transparent,
                    iconColor: Theme.of(context).colorScheme.menuFontColor1,
                    iconData: Icons.arrow_back_ios,
                    size: 50,
                    iconSize: 22,
                    onPressed: (_) {
                      Navigator.of(context).pop();
                    }),
                Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 25),
                    child: Text('About',
                        style: TextStyle(
                          fontSize: 25,
                          color: Theme.of(context).colorScheme.menuFontColor1,
                        ))),
                const Spacer()
              ])))
    ]);
  }

  Widget _header() {
    return SizedBox(
        width: 300,
        height: 30,
        child: Stack(children: [
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                  height: 40,
                  width: 100,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20)))))
        ]));
  }

  Widget _view() {
    return Builder(builder: (context) {
      var size = MediaQuery.sizeOf(context);
      final _textStyle = TextStyle(
          color: Theme.of(context).colorScheme.menuFontColor1,
          fontSize: Constants.menuFontSize1,
          fontWeight: FontWeight.w400);

      return SizedBox(
          height: size.height / 1.5,
          child: Stack(alignment: Alignment.center, children: [
            Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WhoZone is a high-performance motion detection and object tracking utility designed for real-time outdoor activity monitoring.\nBuilt with a custom C++ backend and a YOLOv11 AI engine, it provides low-latency detection without the need for subscriptions.',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'How to Use\nSetup: Position your device with a clear, stable view of the area you want to monitor.',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Detection:',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Tap the Record button to begin the live analysis.\nThe AI will highlight detected objects with bounding boxes in real-time.',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Monitoring:',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Keep an eye on the session timer.\nThe app is optimized for high FPS to ensure you don\'t miss quick movements.\nPrivacy: All processing happens locally on your device.\nNo data is ever sent to the cloud.',
                        style: _textStyle,
                      ),
                      SizedBox(height: 8),
                    ]))
          ]));
    });
  }

  bool isValidIP(String ip) {
    try {
      InternetAddress(ip);
      return true; // Valid IP
    } catch (e) {
      return false; // Invalid IP
    }
  }

  bool isValidURI(String uri) {
    try {
      if (uri.startsWith('https://') || uri.startsWith('http://')) {
        var v = Uri.parse(uri);
        return v.host.isNotEmpty; // Valid URI
      }
    } catch (_) {}
    return false; // Invalid URI
  }
}
