import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
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
                    iconColor: Colors.black,
                    size: 50,
                    iconSize: 22,
                    iconData: Icons.arrow_back_ios,
                    onPressed: (p0) {
                      Navigator.of(context).pop();
                    }),
                Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 25),
                    child: const Text('About', style: TextStyle(fontSize: 25))),
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
      var size = MediaQuery.of(context).size;
      return SizedBox(
          height: size.height / 1.5,
          child: Stack(alignment: Alignment.center, children: [
            Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('You may be wondering what this app is for',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.menuFontColor1,
                              fontSize: Constants.menuFontSize1,
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      Text(
                          'Perhaps you remember the day or days when you saw poop in your yard without any idea where it came from',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.menuFontColor1,
                              fontSize: Constants.menuFontSize1,
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      Text(
                          'Then you will agree that there is nothing more unpleasant then cleaning poop',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.menuFontColor1,
                              fontSize: Constants.menuFontSize1,
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      Text(
                          'Hope this app can help you find out the cause of that',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.menuFontColor1,
                              fontSize: Constants.menuFontSize1,
                              fontWeight: FontWeight.w400)),
                      SizedBox(height: 8),
                      Text(
                        'Just stick your phone to the window, press capture and see what it will catch',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.menuFontColor1,
                            fontSize: Constants.menuFontSize1,
                            fontWeight: FontWeight.w400),
                      )
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
