import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mz_pbx_report/constans.dart';

Future<String?> gettoken() async {
  try {
    http.Response resp = await http.post(Uri.http(kBaseUrl, "$kapi/login"),
        body: jsonEncode({"username": kapiuser, "password": kapipassword}),
        headers: {"Content-Type": "application/json"});
    if (resp.statusCode == 200) {
      String token = jsonDecode(resp.body)['token'];
      await http.post(
          Uri.http(kBaseUrl, "$kapi/heartbeat",
              {"token": token, "ipaddr": "192.168.30.160"}),
          headers: {"Content-Type": "application/json"});

      return token;
    }
  } on http.ClientException catch (r) {
    print(r.message);
  } catch (e) {
    print(e);
  }
  return null;
}
