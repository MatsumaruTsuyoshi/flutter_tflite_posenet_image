import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  File _image;
  List _recognitions;
  double _imageHeight;
  double _imageWidth;
  ImagePicker picker;

  @override
  void initState() {
    super.initState();
    loadModel();
    picker = ImagePicker();
  }

  //ギャラリーから画像を選択
  Future imageFromGallery() async {
    PickedFile pickedFile = await picker.getImage(source: ImageSource.gallery);
    File image = File(pickedFile.path);
    predictImage(image);
  }

  Future loadModel() async {
    Tflite.close();
    try {
      String res;
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
      );
      print(res);
    } on PlatformException {
      print("Failed to load model");
    }
  }

  Future predictImage(File image) async {
    if (image == null) return;
    await poseNet(image);
    //画像の情報を取得。
    new FileImage(image)
        .resolve(new ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        _imageHeight = info.image.height.toDouble();
        _imageWidth = info.image.width.toDouble();
      });
    }));

    setState(() {
      _image = image;
    });
  }

  Future poseNet(File image) async {
    //座標情報をrecognitionsに入れる
    var recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 1,
    );
    print(recognitions);
    print(recognitions[0]['keypoints'][0]['x']);

    setState(() {
      _recognitions = recognitions;
    });
  }

  List<Widget> renderKeypoints(Size screen) {
    if (_recognitions == null) return [];
    if (_imageHeight == null || _imageWidth == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = <Widget>[];
    //_recognitionsに入っているmapデータをパーツごとに取り出してプロット
    _recognitions.forEach((re) {
      var color = Colors.red;
      var list = re["keypoints"].values.map<Widget>((k) {
        return Positioned(
          //スクリーンサイズに合わせて座標移動
          left: k["x"] * factorX - 6,
          top: k["y"] * factorY - 6,
          width: 100,
          height: 12,
          child: Text(
            "● ${k["part"]}",
            style: TextStyle(
              color: color,
              fontSize: 12.0,
            ),
          ),
        );
      }).toList();

      //最後に全部がっちゃんこ
      lists..addAll(list);
    });

    return lists;
  }

  //rightAnkle:16,rightKnee:14を結ぶ
  //List<Widget> bornPaint(Size screen) {}

  @override
  Widget build(BuildContext context) {
    //デバイスごとにスクリーンサイズを取得する
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    stackChildren.add(Positioned(
      top: 0.0,
      left: 0.0,
      width: size.width,
      child: _image == null ? Center() : Image.file(_image),
    ));

    //座標をプロット
    stackChildren.addAll(renderKeypoints(size));
    stackChildren.add(
      Positioned(
        left: 0.0,
        top: 0.0,
        child: CustomPaint(
          size: const Size(10, 10),
          painter: BornPaint(
              recognitions: _recognitions,
              screen: size,
              imageHeight: _imageHeight,
              imageWidth: _imageWidth),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("pose detection demo"),
      ),
      body: Stack(
        children: stackChildren,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: imageFromGallery,
        child: Icon(Icons.image),
      ),
    );
  }
}

class BornPaint extends CustomPainter {
  List recognitions;
  Size screen;
  double imageHeight;
  double imageWidth;

  BornPaint(
      {this.recognitions, this.screen, this.imageHeight, this.imageWidth});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.blue;
    final center = Offset(
        recognitions[0]['keypoints'][0]['x'] * screen.width - 6,
        recognitions[0]['keypoints'][0]['y'] *
                imageHeight /
                imageWidth *
                screen.width -
            6);
    final radius = min(size.width, size.height);
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
