import 'package:flutter/material.dart';
import 'package:mz_pbx_report/controllers/gettoken.dart';
import 'package:mz_pbx_report/controllers/requestpost.dart';
import 'package:mz_pbx_report/controllers/selectedforachiveprovider.dart';
import 'package:mz_pbx_report/logo.dart';
import 'package:mz_pbx_report/models/singleModel.dart';
import 'package:mz_pbx_report/models/topinfocardmodel.dart';
import 'package:provider/provider.dart';

class RealTime extends StatelessWidget {
  const RealTime({super.key});
  static const String routeName = "/homepage/realtime";
  @override
  Widget build(BuildContext context) {
    final _token = ModalRoute.of(context)!.settings.arguments as String?;
    List<Extension>? extensionlist;
    return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Mzlogo(),
          ),
          body: FutureBuilder(future: Future(() async {
            String? mytoken = _token ?? await gettoken();

            return mytoken;
          }), builder: (context, snaps) {
            if (snaps.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  width: 175,
                  child: LinearProgressIndicator(),
                ),
              );
            } else if (!snaps.hasData) {
              return const Center(child: Text("خطأ في الوصول للمخدم"));
            } else {
              return RealTimePage(token: snaps.data!);
            }
          }),
        ));
  }
}

class RealTimePage extends StatelessWidget {
  RealTimePage({super.key, required this.token});
  final String token;
  List<Extension>? extlist = [];
  List<CallsInNotRecieve>? waitingcalllist = [];
  List<Extension>? realtimecalls = [];

  @override
  Widget build(BuildContext context) {
    Queue selectedQueu =
        context.watch<SelectedSingleModelQueueProvider>().selected;

    return StreamBuilder(
        stream: Stream.periodic(Duration(seconds: 5), (x) => x),
        builder: (_, s) {
          Future(() async {
            //extinfolist
            var extsinfo = await requestpost(
                endpoint: "extension/query",
                token: token,
                body: {"number": selectedQueu.agents},
                maindata: "extinfos");

            extlist!.clear();
            if (extsinfo != null) {
              for (var i in extsinfo) {
                extlist!.add(Extension.fromextinfo(data: i));
              }
            }
            //waiting call list
            var callquery = await requestpost(
              endpoint: "call/query",
              token: token,
              body: {"type": "inbound"},
              maindata: "Calls",
            );
            waitingcalllist!.clear();
            if (callquery != null) {
              for (var c in callquery) {
                waitingcalllist!.add(CallsInNotRecieve.fromdata(data: c));
              }
            }

            //realtime call

            var extcalls = await requestpost(
                endpoint: "extension/query_call",
                token: token,
                body: {"number": selectedQueu.agents},
                maindata: "calllist");

            realtimecalls!.clear();
            for (var ec in extcalls) {
              realtimecalls!
                  .add(Extension.fromdataascallqueue(data: ec, exts: extlist!));
            }
          });
          List extinq = [];
          try {
            extinq = selectedQueu.agents.split(",")
              ..removeWhere((element) => element == "");
          } catch (e) {}

          TopInfoCardModel queue =
              TopInfoCardModel(label: "Queue", value: selectedQueu.name);
          TopInfoCardModel allexts = TopInfoCardModel(
              label: "عدد التحويلات",
              value: selectedQueu.name == "all"
                  ? "all"
                  : extinq.length.toString());
          TopInfoCardModel availableext = TopInfoCardModel(
              label: "التحويلات المتاحة",
              value: extlist!
                  .where((element) => element.status == "Registered")
                  .length
                  .toString());
          TopInfoCardModel busyext = TopInfoCardModel(
              label: "المكالمات الجارية",
              value: extlist!
                  .where((element) => element.status == "Busy")
                  .length
                  .toString());

          TopInfoCardModel waitingcallnum = TopInfoCardModel(
              label: "المكالمات على الانتظار",
              value: waitingcalllist!
                  .where((element) =>
                      element.type == "inbound" && element.memebers.length == 1)
                  .length
                  .toString());
          if (s.data != null && s.data! > 0) {
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    TopInfoCard(label: queue.label, value: queue.value),
                    TopInfoCard(label: allexts.label, value: allexts.value),
                    TopInfoCard(
                        label: availableext.label, value: availableext.value),
                    TopInfoCard(label: busyext.label, value: busyext.value),
                    TopInfoCard(
                        label: waitingcallnum.label,
                        value: waitingcallnum.value)
                  ]),
                ),
                const Divider(),
                Expanded(
                    child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text("المكالمات الواردة"),
                          const Divider(),
                          Expanded(
                              child: ListView(
                            children: [
                              ...waitingcalllist!
                                  .where((element) =>
                                      element.type == "inbound" &&
                                      element.memebers.length == 1)
                                  .map((e) => RealTimeCard(
                                        color: Colors.amberAccent,
                                        caller: e.from,
                                      )),
                              ...realtimecalls!
                                  .where((element) => element.type == "inbound")
                                  .map((e) => RealTimeCard(
                                        color: Colors.blueAccent,
                                        caller: e.from!,
                                        agent: e.name,
                                      ))
                            ],
                          ))
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          const Text("المكالمات الصادرة"),
                          const Divider(),
                          Expanded(
                              child: ListView(
                            children: [
                              ...realtimecalls!
                                  .where(
                                      (element) => element.type == "outbound")
                                  .map((e) => RealTimeCard(
                                        color: Colors.greenAccent,
                                        caller: e.to!,
                                        agent: e.name,
                                      ))
                            ],
                          ))
                        ],
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          const Text("التحويلات"),
                          const Divider(),
                          Expanded(
                              child: ListView(
                            children: [
                              ...extlist!
                                  .where((element) =>
                                      element.status == "Busy" ||
                                      element.status == "Registered")
                                  .map((e) => ExtInof(
                                      color: e.status == "Registered"
                                          ? Colors.green
                                          : e.status == "Busy"
                                              ? Colors.redAccent
                                              : Colors.grey,
                                      status: e.status.toString(),
                                      agent: e.name)),
                              ...extlist!
                                  .where((element) =>
                                      element.status != "Busy" ||
                                      element.status != "Registered")
                                  .map((e) => ExtInof(
                                      color: e.status == "Registered"
                                          ? Colors.green
                                          : e.status == "Busy"
                                              ? Colors.redAccent
                                              : Colors.grey,
                                      status: e.status.toString(),
                                      agent: e.name))
                            ],
                          ))
                        ],
                      ),
                    ),
                  ],
                ))
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class TopInfoCard extends StatelessWidget {
  TopInfoCard({
    super.key,
    required this.label,
    required this.value,
  });
  final String label;
  String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(label),
              const SizedBox(width: 60, child: Divider()),
              Text(value)
            ],
          ),
        ),
      ),
    );
  }
}

class RealTimeCard extends StatelessWidget {
  RealTimeCard(
      {super.key, required this.color, required this.caller, this.agent});
  final Color color;
  String? agent;
  String caller;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: ListTile(
        title: Text(agent ?? ""),
        subtitle: Text(caller),
      ),
    );
  }
}

class ExtInof extends StatelessWidget {
  ExtInof({super.key, required this.color, required this.status, this.agent});
  final Color color;
  String? agent;
  String status;
  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: ListTile(
        title: Text(
          agent ?? "",
          style: TextStyle(fontSize: 12),
        ),
        subtitle: Text(status),
      ),
    );
  }
}  
//-----------------------------
          
//            args == null
//               ? const Center(
//                   child: Text("حدث خطأ في المصادقة"),
//                 )
//               : Column(
//                   children: [
//                     Row(
//                       children: [],
//                     ),
//                     const Divider(),
//                     Expanded(
//                       child: Row(
//                         children: [
//                           args != null
//                               ? StreamBuilder(
//                                   stream: requestpostStream(
//                                     endpoint: "extension/query_call",
//                                     token: args['token'],
//                                     body: {
//                                       "number": context
//                                           .read<
//                                               SelectedSingleModelQueueProvider>()
//                                           .selected
//                                           .agents
//                                     },
//                                     maindata: "calllist",
//                                   ),
//                                   builder: (context, snaps) {
//                                     if (snaps.connectionState ==
//                                         ConnectionState.waiting) {
//                                       return const Expanded(
//                                         flex: 4,
//                                         child: Center(
//                                             child: CircularProgressIndicator()),
//                                       );
//                                     } else {
//                                       if (!snaps.hasData) {
//                                         return const Expanded(
//                                             flex: 4,
//                                             child: Text(
//                                               "لا يوجد مكالمات",
//                                               textAlign: TextAlign.center,
//                                             ));
//                                       } else {
//                                         List x = snaps.data;
//                                         List<Extension> extlist = [];
//                                         for (var i in x) {
//                                           extlist.add(
//                                               Extension.fromdataascallqueue(
//                                                   exts: args['exts'], data: i));
//                                         }

//                                         return Expanded(
//                                           flex: 4,
//                                           child: Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Column(
//                                                   children: [
//                                                     const Text(
//                                                         "المكالمات الواردة"),
//                                                     const Divider(),
//                                                     Expanded(
//                                                         child: ListView(
//                                                       children: [
//                                                         waitingM(args),
//                                                         Inbound(
//                                                             extlist: extlist)
//                                                       ],
//                                                     ))
//                                                   ],
//                                                 ),
//                                               ),
//                                               VerticalDivider(),
//                                               Expanded(
//                                                 child: Column(
//                                                   children: [
//                                                     const Text(
//                                                         "المكالمات الصادرة"),
//                                                     const Divider(),
//                                                     Outbound(extlist: extlist),
//                                                   ],
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         );
//                                       }
//                                     }
//                                   },
//                                 )
//                               : const Expanded(
//                                   flex: 3,
//                                   child: Text(
//                                     "خطأ في المصادقة",
//                                     textAlign: TextAlign.center,
//                                   )),
//                           const VerticalDivider(thickness: 5),
//                           Expanded(
//                             flex: 1,
//                             child: Column(
//                               children: [
//                                 const Text("حالة التحويلات"),
//                                 const Divider(),
//                                 args != null
//                                     ? ExtInfo(args: args)
//                                     : const Text("خطأ في المصادقة"),
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     )
//                   ],
//                 )),
//     );
//   }

//   StreamBuilder<dynamic> waitingM(Map<dynamic, dynamic> args) {
//     return StreamBuilder(
//       stream: requestpostStream(
//         endpoint: "call/query",
//         token: args['token'],
//         body: {"type": "inbound"},
//         maindata: "Calls",
//       ),
//       builder: (_, mysnap) {
//         if (!mysnap.hasData) {
//           return const SizedBox();
//         } else {
//           List x = mysnap.data;
//           List<CallsInNotRecieve> calls = [];
//           calls.clear();
//           for (var i in x) {
//             calls.add(CallsInNotRecieve.fromdata(data: i));
//           }
//           return Column(children: [
//             ...calls
//                 .where((element) =>
//                     element.memebers.length == 1 && element.type == "inbound")
//                 .map((e) => Card(
//                       color: Colors.amber[50],
//                       child: ListTile(
//                         title: Text(e.from),
//                         trailing: Text(e.memebers.length.toString()),
//                       ),
//                     ))
//           ]);
//         }
//       },
//     );
//   }
// }

// class ExtInfo extends StatelessWidget {
//   const ExtInfo({
//     super.key,
//     required this.args,
//   });

//   final Map? args;

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: requestpostStream(
//         endpoint: "extension/query",
//         token: args!['token'],
//         body: {
//           "number":
//               context.read<SelectedSingleModelQueueProvider>().selected.agents
//         },
//         maindata: "extinfos",
//       ),
//       builder: (context, snaps) {
//         if (snaps.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else {
//           if (!snaps.hasData) {
//             return const Text("لا يوجد تحويلات");
//           } else {
//             List x = snaps.data;
//             List<Extension> extlist = [];
//             for (var i in x) {
//               extlist.add(Extension.fromextinfo(data: i));
//             }
//             return Expanded(
//                 child: Column(
//               children: [
//                 Expanded(
//                   child: ListView(children: [
//                     ...extlist.map((e) => Card(
//                           child: ListTile(
//                             title: Text(e.name),
//                             subtitle: Text(e.status!),
//                             trailing: Transform.rotate(
//                               angle: 45,
//                               child: Container(
//                                   width: 25,
//                                   height: 25,
//                                   decoration: BoxDecoration(
//                                       color: e.status == "Registered"
//                                           ? Colors.green
//                                           : e.status == "Busy"
//                                               ? Colors.amber
//                                               : Colors.grey)),
//                             ),
//                           ),
//                         ))
//                   ]),
//                 ),
//               ],
//             ));
//           }
//         }
//       },
//     );
//   }
// }

// class MainElementattop extends StatelessWidget {
//   MainElementattop(
//       {super.key,
//       required this.label,
//       required this.value,
//       this.stream,
//       this.listelement,
//       required this.list});
//   final String label, value;
//   final listelement;
//   List list;
//   Stream? stream;
//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//         stream: stream,
//         builder: (_, snaps) {
//           if (!snaps.hasData) {
//             return SizedBox();
//           } else {
//             list = [];
//             list.clear();
//             for (var i in snaps.data) {
//               list.add(Extension.fromextinfo(data: i));
//             }

//             context.read<ExtListInfoProvider>().list = snaps.data;
//             return Container(
//               margin: const EdgeInsets.all(5),
//               decoration: BoxDecoration(border: Border.all()),
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 children: [
//                   Text(label),
//                   const SizedBox(width: 50, child: Divider()),
//                   Text(value)
//                 ],
//               ),
//             );
//           }
//         });
//   }
// }

// class Inbound extends StatelessWidget {
//   const Inbound({
//     super.key,
//     required this.extlist,
//   });

//   final List<Extension> extlist;

//   @override
//   Widget build(BuildContext context) {
//     return Column(children: [
//       ...extlist.where((element) => element.type == "inbound").map((e) => Card(
//             child: ListTile(
//               trailing: Text(e.status!),
//               title: Text(e.name),
//               subtitle: Text(e.from!),
//             ),
//           ))
//     ]);
//   }
// }

// class Outbound extends StatelessWidget {
//   const Outbound({
//     super.key,
//     required this.extlist,
//   });

//   final List<Extension> extlist;

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//         child: ListView(children: [
//       ...extlist.where((element) => element.type == "outbound").map((e) => Card(
//             child: ListTile(
//               trailing: Text(e.status!),
//               title: Text(e.name),
//               subtitle: Text(e.to!),
//             ),
//           ))
//     ]));
//   }
// }
