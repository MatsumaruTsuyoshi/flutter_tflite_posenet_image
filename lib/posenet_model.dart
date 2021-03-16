import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tflite_posenet_image/born_paint.dart';
import 'package:flutter_tflite_posenet_image/video_to_image_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class PoseNetModel extends ChangeNotifier {
  double imageHeight = 0.0;
  double imageWidth = 0.0;
  File image;
  List recognitions = [];
  List<Widget> stackChildren = [];
  Map<int, List<Widget>> allStack = {};
  VideoToImageModel videoToImageModel = VideoToImageModel();

  Future pickImage(size) async {
    final pathList = await videoToImageModel.videoToImage();
    allStack = {};
    for (int i = 0; i < pathList.length; i++) {
      await predictImage(File(pathList[i]));
      image = File(pathList[i]);
      await bornPaint(size);
      allStack.addAll({i: stackChildren});
    }
    notifyListeners();
  }

  Future bornPaint(size) async {
    //デバイスごとにスクリーンサイズを取得する
    stackChildren = [];
    stackChildren.add(
      Positioned(
        top: 0.0,
        left: 0.0,
        width: size.width,
        child: image == null ? Center() : Image.file(image),
      ),
    );
    stackChildren.add(
      Positioned(
        left: 0.0,
        top: 0.0,
        child: CustomPaint(
          size: const Size(4, 4),
          painter: BornPaint(
              recognitions: recognitions,
              screen: size,
              imageHeight: imageHeight,
              imageWidth: imageWidth),
        ),
      ),
    );
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
    var decodedImage = await decodeImageFromList(image.readAsBytesSync());
    imageHeight = decodedImage.height.toDouble();
    imageWidth = decodedImage.width.toDouble();
  }

  Future poseNet(File image) async {
    //座標情報をrecognitionsに入れる
    var _recognitions = await Tflite.runPoseNetOnImage(
      path: image.path,
      numResults: 1,
    );
    recognitions = _recognitions;
  }
}
