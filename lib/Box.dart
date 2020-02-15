import 'package:flutter/material.dart';
// import 'dart:math' as math;

class EnclosedBox extends StatelessWidget {

  final List<dynamic> results;
  final int previewH;
  final int previewW;
  final double screenH;
  final double screenW;
  // final String model;

  EnclosedBox(this.results, this.previewH, this.previewW, this.screenH, this.screenW);

  List<Widget> _renderStrings() {
      double offset = -10;
      return results.map((re) {
        offset = offset + 14;
        return Positioned(
          left: 10,
          top: offset,
          width: screenW,
          height: screenH,
          child: Text(
            "${re["label"].toString().substring(2)} ${(re["confidence"] * 100).toStringAsFixed(0)}%",
            style: TextStyle(
              // color: Color.fromRGBO(37, 213, 253, 1.0),
              color: Colors.red,
              fontSize: 54.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList();
    }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _renderStrings(),
    );
  }
}