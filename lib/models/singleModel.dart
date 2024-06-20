import 'package:flutter/material.dart';
import 'package:mz_pbx_report/controllers/selectedforachiveprovider.dart';
import 'package:provider/provider.dart';

class SingleModel {
  String name;
  String number;
  bool search;

  SingleModel({required this.name, required this.number, this.search = true});

  static searchMethode(
      {required String value,
      required List<SingleModel> list,
      required BuildContext context}) {
    if (value.isEmpty) {
      for (var i in list) {
        i.search = true;
      }
    } else {
      if (!list.any((element) =>
          element.name.toLowerCase().contains(value.toLowerCase()))) {
        list.any((element) => element.search = false);
        context.read<SelectedSingleModelExtProvider>().selected =
            Queue(name: "all", number: "all", agents: "all");
      } else {
        for (var j in list) {
          if (j.name.toLowerCase().contains(value.toLowerCase())) {
            j.search = true;
            context.read<SelectedSingleModelExtProvider>().selected = j;
          } else {
            j.search = false;
          }
        }
      }
    }
  }
}

class Queue extends SingleModel {
  String agents;

  Queue(
      {required super.name,
      required super.number,
      super.search,
      required this.agents});
  factory Queue.fromdata({data}) {
    return Queue(
        name: data['queuename'],
        number: data['number'],
        agents: data['agents'],
        search: true);
  }
}

class Extension extends SingleModel {
  String? status;
  String? from, to, trukname, type;
  Function()? searchMethod;
  Extension({
    required super.number,
    required super.name,
    this.status,
    this.from,
    this.to,
    this.trukname,
    this.type,
    super.search,
  });

  factory Extension.fromdata({data}) {
    return Extension(
        number: data['number'], name: data['username'], search: true);
  }

  factory Extension.fromextinfo({data}) {
    return Extension(
      number: data['number'],
      name: data['username'],
      status: data['status'],
    );
  }

  factory Extension.fromdataascallqueue({data, required List<Extension> exts}) {
    if (data['numbercalls'][0]['members'][0].keys.first == "inbound") {
      return Extension(
        name: exts
            .where((element) => element.number == data['number'])
            .first
            .name,
        type: "inbound",
        number: data['number'],
        from: data['numbercalls'][0]['members'][0]['inbound']['from'],
        trukname: data['numbercalls'][0]['members'][0]['inbound']['trunkname'],
        status: data['numbercalls'][0]['members'][0]['inbound']['memberstatus'],
      );
    } else {
      return Extension(
        name: exts
            .where((element) => element.number == data['number'])
            .first
            .name,
        type: "outbound",
        number: data['number'],
        to: data['numbercalls'][0]['members'][1]['outbound']['to'],
        trukname: data['numbercalls'][0]['members'][1]['outbound']['trunkname'],
        status: data['numbercalls'][0]['members'][1]['outbound']
            ['memberstatus'],
      );
    }
  }
}

class CallsInNotRecieve {
  final List memebers;
  final String from;
  final String type;
  String memberstatus;
  CallsInNotRecieve(
      {required this.memebers,
      required this.from,
      required this.type,
      required this.memberstatus});
  factory CallsInNotRecieve.fromdata({data}) {
    if (data['members'][0].keys.first == "inbound") {
      return CallsInNotRecieve(
          type: "inbound",
          memebers: data['members'],
          from: data['members'][0]['inbound']['from'],
          memberstatus: data['members'][0]['inbound']['memberstatus']);
    } else {
      return CallsInNotRecieve(
          type: "outbound", memebers: [], from: "", memberstatus: "");
    }
  }
}
