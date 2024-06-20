import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class Mzlogo extends StatelessWidget {
  const Mzlogo({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 500,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              SizedBox(width: 50),
              Icon(
                Icons.analytics_outlined,
                color: Colors.teal,
              ),
              Icon(
                Icons.phone,
                size: 50,
                color: Colors.orange,
              )
            ],
          ),
          Text(
            "MzPbxReports",
            style: TextStyle(
                color: Colors.teal, fontFamily: "IndieFlower", fontSize: 35),
          ),
        ],
      ),
    );
  }
}
