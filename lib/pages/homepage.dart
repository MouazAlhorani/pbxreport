import 'dart:html';
import 'dart:js';

import 'package:flutter/material.dart';
import 'package:mz_pbx_report/controllers/gettoken.dart';
import 'package:mz_pbx_report/controllers/requestpost.dart';
import 'package:mz_pbx_report/controllers/selectedforachiveprovider.dart';
import 'package:mz_pbx_report/logo.dart';
import 'package:mz_pbx_report/pages/login.dart';
import 'package:mz_pbx_report/pages/realtimereport.dart';
import 'package:provider/provider.dart';

import '../models/singleModel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String routeName = "/homepage";

  @override
  Widget build(BuildContext context) {
    List<SingleModel> queues = [
      Queue(name: "all", number: "all", agents: "all")
    ];
    List<Extension> exts = [];
    return Scaffold(
      body: FutureBuilder(future: Future(() async {
        String? xtoken = await gettoken();
        try {
          if (xtoken != null) {
            List xqueues = await requestpost(
                endpoint: "queue/query",
                token: xtoken,
                body: {"number": "all"},
                maindata: 'queues');
            List xexts = await requestpost(
              endpoint: "extension/list",
              token: xtoken,
              maindata: 'extlist',
            );
            for (var i in xqueues) {
              queues.add(Queue.fromdata(data: i));
            }
            for (var i in xexts) {
              exts.add(Extension.fromdata(data: i));
            }
          }
        } catch (e) {
          print(e);
        }
        return xtoken;
      }), builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snap.hasData) {
          return Center(
            child: Text("حصل خطأ في المصادقة"),
          );
        } else {
          return MainPage(
            queues: queues,
            exts: exts,
            token: snap.data!,
          );
        }
      }),
    );
  }
}

class MainPage extends StatefulWidget {
  MainPage(
      {super.key,
      required this.queues,
      required this.exts,
      required this.token});
  final List<SingleModel> queues, exts;
  final String token;
  List<String> archiveReportDate = [
    'today',
    'yestrday',
    'lastweek',
    'lastmonth',
    'lastyear'
  ];
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showlogoutlabel = false;
  String selectedarchiveReportDate = "today";
  SingleModel selectedQueue = Queue(name: "all", number: "all", agents: "all");
  SingleModel selectedExt = Queue(name: "all", number: "all", agents: "all");

  @override
  Widget build(BuildContext context) {
    selectedQueue = context.watch<SelectedSingleModelQueueProvider>().selected;
    selectedExt = context.watch<SelectedSingleModelExtProvider>().selected;

    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
            appBar: AppBar(
              flexibleSpace: Container(
                height: 150,
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        colors: [Colors.white, Colors.orangeAccent])),
                child: const Column(
                  children: [
                    Align(
                        alignment: Alignment.topRight,
                        child: Hero(tag: "logoHero", child: Mzlogo())),
                    Spacer(),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "programed by: Mouaz al-Horani",
                        style:
                            TextStyle(fontFamily: "IndieFlower", fontSize: 20),
                      ),
                    )
                  ],
                ),
              ),
              toolbarHeight: 150,
              automaticallyImplyLeading: false,
              actions: [
                Row(
                  children: [
                    Visibility(
                        visible: showlogoutlabel, child: Text("تسجيل خروج")),
                    MouseRegion(
                      onHover: (event) => setState(() {
                        showlogoutlabel = true;
                      }),
                      onExit: (event) => setState(() {
                        showlogoutlabel = false;
                      }),
                      child: IconButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, LogIn.routeName);
                          },
                          icon: Icon(Icons.logout_outlined)),
                    ),
                  ],
                )
              ],
            ),
            body: ListView(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    children: [
                      TextButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, RealTime.routeName,
                                arguments: widget.token);
                          },
                          icon: const Icon(Icons.local_cafe_outlined),
                          label: const Text("بدء الرصد في الزمن الحقيقي")),
                      DropdownButton(
                          value: selectedQueue.name,
                          items: [
                            ...widget.queues.map((e) => DropdownMenuItem(
                                value: e.name, child: Text(e.name)))
                          ],
                          onChanged: (x) {
                            context
                                    .read<SelectedSingleModelQueueProvider>()
                                    .selected =
                                widget.queues
                                    .where((element) => element.name == x)
                                    .first;
                          })
                    ],
                  ),
                ),
                const Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(width: 500, child: Divider())),
                SizedBox(
                  width: 500,
                  child: Row(
                    children: [
                      TextButton.icon(
                        label: Text("سجل التقارير"),
                        icon: Icon(Icons.history),
                        onPressed: () {},
                      ),
                      SizedBox(width: 15),
                      DropdownButton(
                          value: selectedarchiveReportDate,
                          items: widget.archiveReportDate
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (x) {
                            setState(() {
                              selectedarchiveReportDate = x!;
                            });
                          }),
                      const SizedBox(width: 15),
                      Column(
                        children: [
                          SizedBox(
                              width: 200,
                              child: TextField(
                                decoration:
                                    const InputDecoration(label: Text("بحث")),
                                onChanged: (value) {
                                  SingleModel.searchMethode(
                                      value: value,
                                      list: [...widget.queues, ...widget.exts],
                                      context: context);
                                },
                              )),
                          DropdownButton(
                              value: selectedExt.name,
                              items: [
                                ...widget.queues.map((e) => DropdownMenuItem(
                                    value: e.name, child: Text(e.name))),
                                ...widget.exts
                                    .where((element) => element.search)
                                    .map((e) => DropdownMenuItem(
                                        value: e.name,
                                        child: SizedBox(
                                            width: 200, child: Text(e.name))))
                              ],
                              onChanged: (x) {
                                context
                                    .read<SelectedSingleModelExtProvider>()
                                    .selected = [
                                  ...widget.queues,
                                  ...widget.exts
                                ].where((element) => element.name == x).first;
                              }),
                        ],
                      ),
                    ],
                  ),
                ),
                const Align(
                    alignment: Alignment.topRight,
                    child: SizedBox(width: 500, child: Divider())),
              ],
            )));
  }
}
