import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_demo/components/page_background.dart';
import 'package:flutter_demo/components/round_button.dart';
import 'package:flutter_demo/components/hover_click.dart';
import 'package:flutter_demo/components/item_in_menu_list.dart';
import 'package:flutter_demo/core/di/di.dart';
import 'package:flutter_demo/features/alert/domain/entities/sound.dart';
import 'package:flutter_demo/features/alert/presentation/pages/alert_addr_page.dart';
import 'package:flutter_demo/features/alert/data/models/alert_model.dart';
import 'package:flutter_demo/repository/app_theme.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';

class AlertPage extends StatefulWidget {
  const AlertPage({super.key});

  @override
  State<AlertPage> createState() => AlertPageState();
}

class AlertPageState extends State<AlertPage> {
  final tag = 'aletPage';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => getIt<AlertModel>(),
        builder: (context, child) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.colorBar,
            body: SafeArea(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageBackground(),
                  CustomScrollView(
                      physics: const ClampingScrollPhysics(),
                      slivers: [
                        SliverAppBar(
                          backgroundColor:
                              Theme.of(context).colorScheme.colorBar,
                          automaticallyImplyLeading: false,
                          flexibleSpace: _sliverAppBar(),
                        ),
                        SliverToBoxAdapter(
                          child: _header(),
                        ),
                        DecoratedSliver(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.colorBgUnderCard,
                          ),
                          sliver: _list(),
                        )
                      ])
                ],
              ),
            ),
          );
        });
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
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 25),
                child: Text(
                  'Alert',
                  style: Theme.of(context).colorScheme.homeCardH1Style,
                ),
              ),
              const Spacer()
            ],
          ),
        ),
      )
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
                  height: 30,
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
                padding: Constants.marginCard,
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
              useBorderTop: true,
              useBorderBot: false,
              margin: Constants.marginCard,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('Sound notification',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .menuFontColor1,
                                fontSize: Constants.fontSize1,
                                fontWeight: FontWeight.w400,
                              )),
                          const SizedBox(height: 4),
                          Text('Every capture event',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .menuFontColor2,
                                  fontSize: Constants.fontSize3,
                                  fontWeight: FontWeight.w400))
                        ])),
                    Switch(
                        value: useSound,
                        onChanged: (bool value) {
                          var model = context.read<AlertModel>();
                          if (value) {
                            var i = model.sounds.firstOrNull;
                            model.setCurrentSound(i);
                          } else {
                            model.setCurrentSound(null);
                          }
                        })
                  ]),
            ),
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
                    useBorderTop: false,
                    useBorderBot: false,
                    margin: Constants.marginCard,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sound',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .menuFontColor1,
                                        fontSize: Constants.fontSize1,
                                        fontWeight: FontWeight.w400)),
                                const SizedBox(height: 4),
                                Text('Particular type',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .menuFontColor2,
                                        fontSize: Constants.fontSize3,
                                        fontWeight: FontWeight.w400))
                              ]),
                          Row(children: [
                            RoundButton(
                                color: Colors.transparent,
                                iconColor:
                                    Theme.of(context).colorScheme.colorPrimary,
                                size: 50,
                                iconData: Icons.play_circle_fill,
                                onPressed: (p0) async {
                                  var model = context.read<AlertModel>();
                                  var sound = model.currentSound;
                                  if (sound == null) return;
                                  model.playSound(sound: sound);
                                }),
                            Row(children: [
                              DropdownButton<Sound>(
                                  padding: const EdgeInsets.only(right: 6),
                                  value:
                                      context.watch<AlertModel>().currentSound,
                                  onChanged: (Sound? value) {
                                    context
                                        .read<AlertModel>()
                                        .setCurrentSound(value);
                                  },
                                  items: soundList.map<DropdownMenuItem<Sound>>(
                                      (Sound value) {
                                    return DropdownMenuItem<Sound>(
                                        value: value,
                                        child: Text(
                                          value.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .colorPrimary,
                                              fontSize: Constants.fontSize2),
                                        ));
                                  }).toList())
                            ])
                          ]),
                        ]),
                  ),
                ),
              ),
            )
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
            margin: Constants.marginCard,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Packet sending',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .menuFontColor1,
                                fontSize: Constants.fontSize1,
                                fontWeight: FontWeight.w400)),
                        const SizedBox(height: 4),
                        Text('Every capture event',
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .menuFontColor2,
                                fontSize: Constants.fontSize3,
                                fontWeight: FontWeight.w400))
                      ]),
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
                useBorderTop: true,
                useBorderBot: false,
                margin: Constants.marginCard,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                      SizedBox(
                          height: 50,
                          child: packets.isNotEmpty
                              ? DropdownButton<String>(
                                  padding: const EdgeInsets.only(right: 6),
                                  value: packet,
                                  onChanged: (String? value) {
                                    if (value == null) return;
                                    context.read<AlertModel>().setPacketValue(
                                        v: value, saveConfig: true);
                                  },
                                  items: packets.map<DropdownMenuItem<String>>(
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
                    ]),
              ),
            ),
          ),
        ),
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
                        useBorderTop: false,
                        useBorderBot: true,
                        margin: Constants.marginCard,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
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
                              Flexible(
                                  flex: 2,
                                  child: HoverClick(
                                    onPressedL: (_) {
                                      final alertModel =
                                          context.read<AlertModel>();
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              settings: const RouteSettings(),
                                              builder: (context) {
                                                return ChangeNotifierProvider
                                                    .value(
                                                        value: alertModel,
                                                        child: AlertAddrPage());
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
                                                  packetToAddr ??
                                                      'ex: 192.168.1.1',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .colorTextSecond,
                                                      fontSize:
                                                          Constants.fontSize2,
                                                      fontWeight:
                                                          FontWeight.w400)),
                                            ))),
                                  ))
                            ])))))
      ]);
    });
  }
}
