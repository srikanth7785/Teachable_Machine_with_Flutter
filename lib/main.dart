// import 'dart:html';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';


void main()
{
  runApp(
    MaterialApp(
      title: 'Teachable Machine with Flutter',
      home: FlutterTeachable(),
    ),
  );
}

class FlutterTeachable extends StatefulWidget {
  @override
  _FlutterTeachableState createState() => _FlutterTeachableState();
}

class _FlutterTeachableState extends State<FlutterTeachable> {

  bool _load = false;
  File _pic;
  List _result;

  String numbers = '';

  @override
  void initState() {
    super.initState();

    _load = true;

    loadMyModel().then((v){
      setState(() {
        _load = false;
      });
    });

  }

  loadMyModel() async
  {
    await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite"
    );
  }

  chooseImage() async
  {
    File _img = await ImagePicker.pickImage(source: ImageSource.camera);

    if(_img == null) return;

    setState(() {
      _load = true;
      _pic = _img;
      applyModelonImage(_pic);
    });
  }

  applyModelonImage(File file) async
  {
    var _res = await Tflite.runModelOnImage(
      path: file.path
    );

    setState(() {
      _load = false;
      _result = _res;

      // for(int i = 0; i < _result.length; i++)
      // numbers = numbers + _res[]

      print(_result);
      String str = _result[0]["label"];
      print(str.substring(2));
      print("indexed : ${_result[0]["label"]}");
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Teachable Machine with FLUTTER"),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            _load ? Container(alignment: Alignment.center,child: CircularProgressIndicator(),)
              : Container(
                width: size.width*0.9,
                height: size.height*0.7,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: _pic != null ? Image.file(_pic,width: size.width*0.6,) : Container(),
                    ),
                    // _result == null ? Text("Cannot be Identified..!")
                    //       : Text("It is ")
                  ],
                ),
              )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RaisedButton(
          child: Text("Capture an Image"),
          onPressed: chooseImage,
        ),
      ),
    );
  }
}