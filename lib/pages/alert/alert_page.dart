import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/circle_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/item_in_menu_list.dart';
import 'package:flutter_demo/main.dart';
import 'package:flutter_demo/pages/alert/alert_addr_page.dart';
import 'package:flutter_demo/pages/alert/alert_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/repository/camera_rep.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({this.arg, super.key});
  final HistoryRecord? arg;

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
  late AlertModel _model;

  final tag = 'aletPage';

  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      _model.init();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _model = context.read<AlertModel>();
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.colorBar,
        body: Stack(alignment: Alignment.center, children: [
          Positioned(
              top: (kToolbarHeight * 2) - 30,
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.colorBgUnderCard,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20))))),
          CustomScrollView(physics: const ClampingScrollPhysics(), slivers: [
            SliverAppBar(
                backgroundColor: Theme.of(context).colorScheme.colorBar,
                automaticallyImplyLeading: false,
                flexibleSpace: _sliverAppBar()),
            SliverToBoxAdapter(child: _header()),
            DecoratedSliver(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.colorBgUnderCard,
                ),
                sliver: _list())
          ])
        ]));
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
                Container(
                  width: 100,
                  margin: const EdgeInsets.only(left: 25),
                  child: Text('Alert',
                      style: Theme.of(context).colorScheme.homeCardH1Style),
                ),
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

  Widget _list() {
    return SliverList.list(children: [
      _headerInList(),
      //
      // notification
      _sound(),
      //
      // TCP/UDP
      _packet()
    ]);
  }

  Widget _headerInList() {
    return Builder(builder: (context) {
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: 10, bottom: 30, left: 25, right: 25),
                child: Row(children: [
                  Text('Motion detection',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.menuFontColor1,
                          fontSize: Constants.fontSize1,
                          fontWeight: FontWeight.w400))
                ])),
          ]);
    });
  }

  Widget _sound() {
    return Builder(builder: (context) {
      var soundList = context.watch<AlertModel>().sounds;
      var useSound = context.watch<AlertModel>().useSound;
      return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //
            // use sound
            ItemInMenuList(
                height: 80,
                useBorderTop: true,
                useBorderBot: false,
                child: Row(children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                            child: Text('Sound notification',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .menuFontColor1,
                                    fontSize: Constants.fontSize1,
                                    fontWeight: FontWeight.w400))),
                        const SizedBox(height: 4),
                        Flexible(
                            child: Text('For every capture',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .menuFontColor2,
                                    fontSize: Constants.fontSize3,
                                    fontWeight: FontWeight.w400)))
                      ]),
                  const Spacer(),
                  Switch(
                      value: useSound,
                      onChanged: (bool value) {
                        var model = context.read<AlertModel>();
                        if (value) {
                          var i = model.sounds.firstOrNull;
                          model.setSound(i);
                        } else {
                          model.setSound(null);
                        }
                      })
                ])),
            //
            // sound
            IgnorePointer(
                ignoring: !useSound,
                child: SizedBox(
                    height: 80,
                    child: AnimatedOpacity(
                        opacity: useSound ? 1 : 0.5,
                        duration: Constants.animationDuraton,
                        child: ItemInMenuList(
                            height: double.infinity,
                            useBorderTop: true,
                            useBorderBot: false,
                            child: Row(children: [
                              Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        child: Text('Sound',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .menuFontColor1,
                                                fontSize: Constants.fontSize1,
                                                fontWeight: FontWeight.w400))),
                                    const SizedBox(height: 4),
                                    Flexible(
                                        child: Text('Particular type',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .menuFontColor2,
                                                fontSize: Constants.fontSize3,
                                                fontWeight: FontWeight.w400)))
                                  ]),
                              const Spacer(),
                              RoundButton(
                                  color: Colors.transparent,
                                  iconColor: Theme.of(context)
                                      .colorScheme
                                      .colorPrimary,
                                  size: 70,
                                  iconData: Icons.play_circle_fill,
                                  onPressed: (p0) async {
                                    var sound =
                                        context.read<AlertModel>().sound;
                                    if (sound == null) return;
                                    getIt<CameraRep>()
                                        .playSound(sound: sound.uri);
                                  }),
                              Expanded(
                                  flex: 2,
                                  child: Row(children: [
                                    Expanded(
                                        child: DropdownButton<Sound>(
                                            padding:
                                                const EdgeInsets.only(right: 6),
                                            value: context
                                                .watch<AlertModel>()
                                                .sound,
                                            isExpanded: true,
                                            onChanged: (Sound? value) {
                                              context
                                                  .read<AlertModel>()
                                                  .setSound(value);
                                            },
                                            items: soundList
                                                .map<DropdownMenuItem<Sound>>(
                                                    (Sound value) {
                                              return DropdownMenuItem<Sound>(
                                                  value: value,
                                                  child: Text(
                                                    value.name,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .colorPrimary,
                                                        fontSize: Constants
                                                            .fontSize2),
                                                  ));
                                            }).toList()))
                                  ]))
                            ])))))
          ]);
    });
  }

  Widget _packet() {
    return Builder(builder: (context) {
      var usePacket = context.watch<AlertModel>().usePacket;
      var packets = context.watch<AlertModel>().packetList;
      var packet = context.watch<AlertModel>().packetValue;
      var packetToAddr = context.watch<AlertModel>().packetToAddr;
      return Column(children: [
        //
        // send packets
        ItemInMenuList(
            useBorderTop: true,
            useBorderBot: false,
            height: 80,
            child: Row(children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Packet sending',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.menuFontColor1,
                            fontSize: Constants.fontSize1,
                            fontWeight: FontWeight.w400)),
                    const SizedBox(height: 4),
                    Text('For every capture',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.menuFontColor2,
                            fontSize: Constants.fontSize3,
                            fontWeight: FontWeight.w400))
                  ]),
              const Spacer(),
              Switch(
                  value: usePacket,
                  onChanged: (bool value) {
                    context
                        .read<AlertModel>()
                        .setUsePacket(value: value, saveConfig: true);
                  })
            ])),
        //
        // tcp/udp mode
        IgnorePointer(
            ignoring: !usePacket,
            child: SizedBox(
                height: 80,
                child: AnimatedOpacity(
                    opacity: usePacket ? 1 : 0.5,
                    duration: Constants.animationDuraton,
                    child: ItemInMenuList(
                        height: double.infinity,
                        useBorderTop: true,
                        useBorderBot: false,
                        child: Row(children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                    child: Text('TCP/UDP',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .menuFontColor1,
                                            fontSize: Constants.fontSize1,
                                            fontWeight: FontWeight.w400))),
                                const SizedBox(height: 4),
                                Flexible(
                                    child: Text('One of protocols',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .menuFontColor2,
                                            fontSize: Constants.fontSize3,
                                            fontWeight: FontWeight.w400)))
                              ]),
                          const Spacer(),
                          SizedBox(
                              height: 50,
                              child: packets.isNotEmpty
                                  ? DropdownButton<String>(
                                      padding: const EdgeInsets.only(right: 6),
                                      value: packet,
                                      onChanged: (String? value) {
                                        if (value == null) return;
                                        context
                                            .read<AlertModel>()
                                            .setPacketValue(
                                                v: value, saveConfig: true);
                                      },
                                      items: packets
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: Constants.fontSize2,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .colorPrimary)),
                                        );
                                      }).toList())
                                  : const SizedBox())
                        ]))))),
        //
        // IP/URI
        IgnorePointer(
            ignoring: !usePacket,
            child: SizedBox(
                height: 80,
                child: AnimatedOpacity(
                    opacity: usePacket ? 1 : 0.5,
                    duration: Constants.animationDuraton,
                    child: ItemInMenuList(
                        height: double.infinity,
                        useBorderTop: true,
                        useBorderBot: true,
                        child: Row(children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                    child: Text('IP/URI',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .menuFontColor1,
                                            fontSize: Constants.fontSize1,
                                            fontWeight: FontWeight.w400))),
                                const SizedBox(height: 4),
                                Flexible(
                                    child: Text('Destination address',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .menuFontColor2,
                                            fontSize: Constants.fontSize3,
                                            fontWeight: FontWeight.w400)))
                              ]),
                          const Spacer(),
                          Expanded(
                              flex: 2,
                              child: HoverClick(
                                onPressedL: (p0) {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          settings: const RouteSettings(),
                                          builder: (context) {
                                            return AlertAddrPage(model: _model);
                                          }));
                                },
                                child: SizedBox(
                                    height: 40,
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .colorCard,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        width: 150,
                                        child: Center(
                                          child: Text(
                                              packetToAddr ?? 'ex: 192.168.1.1',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .colorTextSecond,
                                                  fontSize: Constants.fontSize2,
                                                  fontWeight: FontWeight.w400)),
                                        ))),
                              ))
                        ])))))
      ]);
    });
  }
}
