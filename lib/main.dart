import 'package:flutter/material.dart';
import 'package:mz_pbx_report/controllers/selectedforachiveprovider.dart';
import 'package:mz_pbx_report/pages/homepage.dart';
import 'package:mz_pbx_report/pages/login.dart';
import 'package:mz_pbx_report/pages/realtimereport.dart';
import 'package:provider/provider.dart';

main() {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => SelectedSingleModelQueueProvider()),
    ChangeNotifierProvider(create: (_) => SelectedSingleModelExtProvider()),
    ChangeNotifierProvider(create: (_) => ExtListInfoProvider())
  ], child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: LogIn.routeName,
      routes: {
        LogIn.routeName: (context) => LogIn(),
        HomePage.routeName: (context) => HomePage(),
        RealTime.routeName: (context) => RealTime()
      },
    ));
  }
}
