import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mz_pbx_report/constans.dart';
import 'package:mz_pbx_report/controllers/checklogin.dart';
import 'package:mz_pbx_report/controllers/gettoken.dart';
import 'package:mz_pbx_report/controllers/showpasswordProvider.dart';
import 'package:mz_pbx_report/logo.dart';
import 'package:mz_pbx_report/models/loginModel.dart';
import 'package:mz_pbx_report/pages/homepage.dart';
import 'package:mz_pbx_report/widgets/textformfield.dart';
import 'package:provider/provider.dart';

class LogIn extends StatefulWidget {
  static String routeName = "/";

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  List<LogInModel> loginModelelement = [
    LogInModel(
        label: "اسم المستخدم",
        controller: TextEditingController(),
        validate: (x) {
          if (x == null || x.trim().isEmpty) {
            return validateMsg['empty'];
          }
        }),
    LogInModel(
        label: "كلمة المرور",
        obsucre: true,
        suffix: true,
        suffixIcon: Icons.visibility,
        controller: TextEditingController(),
        validate: (x) {
          if (x == null || x.trim().isEmpty) {
            return validateMsg['empty'];
          }
        })
  ];
  bool wait = false;

  @override
  Widget build(BuildContext context) {
    loginModelelement[1].suffixOnpress = () {
      setState(() {
        loginModelelement[1].obsucre = !loginModelelement[1].obsucre;
      });
    };
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: ListView(
          children: [
            const SizedBox(height: 200),
            Stack(
              children: [
                Form(
                    key: _formkey,
                    child: Align(
                      alignment: Alignment.center,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Hero(tag: "logoHero", child: const Mzlogo()),
                              ...loginModelelement.map((e) => CtextFormField(
                                  label: e.label,
                                  obscure: e.obsucre,
                                  suffix: e.suffix,
                                  suffixIcon: e.suffixIcon,
                                  suffixOnpress: e.suffixOnpress,
                                  validate: e.validate,
                                  controller: e.controller)),
                              const SizedBox(width: 500, child: Divider()),
                              TextButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      wait = true;
                                    });
                                    if (_formkey.currentState!.validate()) {
                                      bool checklogin = await checkLogIn(
                                          username: loginModelelement[0]
                                              .controller
                                              .text,
                                          password: loginModelelement[1]
                                              .controller
                                              .text);
                                      checklogin
                                          ? {
                                              Navigator.pushReplacementNamed(
                                                  context, HomePage.routeName),
                                            }
                                          : null;
                                    }
                                    setState(() {
                                      wait = false;
                                    });
                                  },
                                  icon: const Icon(Icons.login),
                                  label: const Text("تسجيل الدخول"))
                            ],
                          ),
                        ),
                      ),
                    )),
                Visibility(
                  visible: wait,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 600,
                      height: 300,
                      color: Colors.white.withOpacity(0.7),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 200),
          ],
        ),
      ),
    );
  }
}
