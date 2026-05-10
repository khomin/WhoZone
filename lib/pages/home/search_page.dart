// import 'package:flutter/material.dart';
// import 'package:flutter_demo/components/circle_button.dart';
// import 'package:flutter_demo/components/hover_click.dart';
// import 'package:flutter_demo/main.dart';
// import 'package:flutter_demo/pages/home/history_page.dart';
// import 'package:flutter_demo/pages/home/view_item1.dart';
// import 'package:flutter_demo/pages/home/search_model.dart';
// import 'package:flutter_demo/repository/app_theme.dart';
// import 'package:flutter_demo/repository/history_rep.dart';
// import 'package:flutter_demo/resource/disposable_stream.dart';
// import 'package:provider/provider.dart';

// class SearchPage extends StatefulWidget {
//   const SearchPage({super.key});

//   @override
//   State<SearchPage> createState() => SearchPageState();
// }

// class SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
//   final _model = SearchModel();
//   final _scrollCtr = ScrollController();
//   final _focus = FocusNode();
//   final _dispStream = DisposableStream();
//   final _textCtr = TextEditingController();

//   @override
//   void initState() {
//     super.initState();

//     _scrollCtr.addListener(() {
//       _focus.unfocus();
//     });
//     _textCtr.addListener(() {
//       _model.setSearch(_textCtr.value.text);
//     });
//   }

//   @override
//   void dispose() {
//     _scrollCtr.dispose();
//     _dispStream.dispose();
//     _textCtr.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         color: Theme.of(context).colorScheme.colorBar,
//         child: SafeArea(
//           child: Scaffold(
//             backgroundColor: Theme.of(context).colorScheme.colorBgUnderCard,
//             appBar: AppBar(
//                 centerTitle: false,
//                 shadowColor: Colors.black,
//                 elevation: 0.1,
//                 backgroundColor: Theme.of(context).colorScheme.colorBgUnderCard,
//                 leading: RoundButton(
//                     color: Colors.transparent,
//                     iconColor: Colors.black,
//                     size: 50,
//                     iconSize: 22,
//                     padding: const EdgeInsets.only(left: 10),
//                     iconData: Icons.arrow_back_ios,
//                     onPressed: (v) async {
//                       Navigator.pop(context);
//                     }),
//                 titleSpacing: 0,
//                 title: _header()),
//             body: ChangeNotifierProvider.value(
//               value: _model,
//               builder: (context, child) {
//                 return _gallery();
//               },
//             ),
//           ),
//         ));
//   }

//   Widget _header() {
//     return HoverClick(
//         onPressedL: (_) {
//           _focus.requestFocus();
//         },
//         child: SizedBox(
//             height: kToolbarHeight,
//             child: Row(children: [
//               Flexible(
//                   child: TextField(
//                       controller: _textCtr,
//                       focusNode: _focus,
//                       maxLines: 1,
//                       decoration: InputDecoration.collapsed(
//                           hintText: 'Search ex: 01.01.2025',
//                           hintStyle: TextStyle(
//                               color:
//                                   Theme.of(context).colorScheme.colorTextSecond,
//                               fontSize: 15,
//                               fontWeight: FontWeight.w400)),
//                       style: TextStyle(
//                           color: Theme.of(context).colorScheme.colorTextAccent,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w400),
//                       cursorColor:
//                           Theme.of(context).colorScheme.colorTextSecond)),
//               Builder(builder: (context) {
//                 var search = context.watch<SearchModel>().search;
//                 var empty = search == null || search.isEmpty;
//                 if (empty) {
//                   return const SizedBox();
//                 }
//                 return RoundButton(
//                     iconData: Icons.clear_sharp,
//                     color: Colors.transparent,
//                     iconSize: 22,
//                     margin: const EdgeInsets.only(right: 15),
//                     size: 40,
//                     iconColor: Theme.of(context)
//                         .colorScheme
//                         .colorTextAccent
//                         .withValues(alpha: 0.5),
//                     onPressed: (_) {
//                       _textCtr.clear();
//                     });
//               })
//             ])));
//   }

//   Widget _gallery() {
//     return Builder(builder: (context) {
//       var search = context.watch<SearchModel>().search;
//       var history = context.select<SearchModel, List<HistoryRoot>>(
//         (v) => v.result,
//       );
//       var size = MediaQuery.of(context).size;
//       if (history.isEmpty) {
//         return HoverClick(
//             onPressedL: (_) {
//               _focus.unfocus();
//             },
//             child: SizedBox(
//                 height: size.height / 1.2,
//                 width: double.infinity,
//                 child: search != null && search.isNotEmpty
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                             Icon(
//                               Icons.screen_search_desktop_rounded,
//                               size: size.width / 5,
//                               color: Theme.of(context).colorScheme.colorPrimary,
//                               shadows: [
//                                 Shadow(
//                                     color: Theme.of(context)
//                                         .colorScheme
//                                         .colorPrimary
//                                         .withValues(alpha: 0.3),
//                                     blurRadius: 15,
//                                     offset: const Offset(0, 1))
//                               ],
//                             ),
//                             const SizedBox(height: 20),
//                             Text(
//                               'No results',
//                               style: TextStyle(
//                                 color: Theme.of(context)
//                                     .colorScheme
//                                     .colorTextAccent
//                                     .withValues(alpha: 0.7),
//                                 fontSize: 18,
//                               ),
//                             )
//                           ])
//                     : const SizedBox()));
//       }
//       return SizedBox(
//           height: ((270 + 28) * history.length).toDouble(),
//           child: CustomScrollView(
//               physics: const ClampingScrollPhysics(),
//               slivers: [
//                 SliverList.builder(
//                     itemCount: history.length,
//                     itemBuilder: (context, index) {
//                       var model = history[index];
//                       return ViewItem1(
//                           history: model,
//                           useSwipe: false,
//                           key: ValueKey('history-${model.date}'),
//                           onPressed: () {
//                             HistoryPageDialog()
//                                 .show(
//                                     context: context,
//                                     history: model,
//                                     initialIndex: index)
//                                 .then((value) {});
//                           },
//                           onDelete: () async {
//                             await getIt<HistoryRep>()
//                                 .deleteHistoryRoot([model]);
//                           });
//                     })
//               ]));
//     });
//   }
// }
