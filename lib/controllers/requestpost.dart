import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mz_pbx_report/constans.dart';

Future? requestpost({endpoint, token, params, body, maindata}) async {
  try {
    http.Response resp = await http.post(
        Uri.http(kBaseUrl, "$kapi/$endpoint", {"token": token, ...?params}),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
        });
    if (resp.statusCode == 200) {
      var data = jsonDecode(resp.body)[maindata];

      return data;
    }
  } catch (e) {
    print(e);
  }
}

Stream? requestpostStream({endpoint, token, params, body, maindata}) async* {
  try {
    List data = [];
    data.clear();
    http.Response resp = await http.post(
        Uri.http(kBaseUrl, "$kapi/$endpoint", {"token": token, ...?params}),
        body: jsonEncode(body),
        headers: {
          "Content-Type": "application/json",
        });
    if (resp.statusCode == 200) {
      data = jsonDecode(resp.body)[maindata];
      yield data;
    }
  } catch (e) {}
}
