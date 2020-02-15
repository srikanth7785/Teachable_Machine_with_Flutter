// import 'dart:html';

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import './LiveFeed.dart';
import './Box.dart';

List<CameraDescription> cameras;

Future<Null> main() async
{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(
    MaterialApp(
      title: 'Teachable Machine with Flutter',
      home: FlutterTeachable(cameras),
    ),
  );
}

class FlutterTeachable extends StatefulWidget {
  final List<CameraDescription> cameras;
  FlutterTeachable(this.cameras);
  @override
  _FlutterTeachableState createState() => _FlutterTeachableState();
}

class _FlutterTeachableState extends State<FlutterTeachable> {

  bool liveFeed = false;

  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;

  bool _load = false;
  File _pic;
  List _result;
  String _confidence = "";
  String _fingers = "";

  String numbers = '';

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }
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
    var res = await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/model_unquant.tflite"
    );

    print("Result after Loading the Model is : $res");

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
      path: file.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5
    );

    setState(() {
      _load = false;
      _result = _res;
      print(_result);
      String str = _result[0]["label"];
      
      _fingers = str.substring(2);
      _confidence = _result != null ? (_result[0]["confidence"]*100.0).toString().substring(0,2) + "%" : "";

      print(str.substring(2));
      print((_result[0]["confidence"]*100.0).toString().substring(0,2)+"%");
      print("indexed : ${_result[0]["label"]}");
    });
  }

  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }  

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text("Teachable Machine with FLUTTER"),
      ),
      body: !liveFeed ? Center(
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
                    _result == null ? Container()
                          : Text("Number of Fingers : $_fingers\nConfidence: $_confidence"),
                  ],
                ),
              )
          ],
        ),
      )
      : Stack(
              children: [
                CameraLiveScreen(
                  widget.cameras,
                  setRecognitions,
                ),
                EnclosedBox(
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    size.height,
                    size.width,
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text("Image Feed"),
              onPressed: (){
                setState(() {
                  liveFeed = false;
                });
                chooseImage();
              },
            ),
            RaisedButton(
              child: Text("Live Feed"),
              onPressed: () {
                setState(() {
                  liveFeed = true;
                });
                loadMyModel();
              },
            ),
          ],
        ),
      ),
    );
  }
}