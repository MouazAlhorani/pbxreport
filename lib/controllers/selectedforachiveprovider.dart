import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:mz_pbx_report/models/singleModel.dart';

class SelectedSingleModelProvider extends ChangeNotifier {
  SingleModel _selected = Queue(name: "all", number: "all", agents: "all");
  set selected(x) {
    _selected = x;
    notifyListeners();
  }

  SingleModel get selected => _selected;
}

class SelectedSingleModelQueueProvider extends ChangeNotifier {
  Queue _selected = Queue(name: "all", number: "all", agents: "all");
  set selected(x) {
    _selected = x;
    notifyListeners();
  }

  Queue get selected => _selected;
}

class SelectedSingleModelExtProvider extends SelectedSingleModelProvider {}

class ExtListInfoProvider extends ChangeNotifier {
  List<Extension> _extlistinfo = [];
  set list(data) {
    _extlistinfo = data;
    notifyListeners();
  }

  List<Extension> get list => _extlistinfo;
}
