import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tflite_posenet_image/born_paint.dart';
import 'package:flutter_tflite_posenet_image/posenet_model.dart';
import 'package:flutter_tflite_posenet_image/video_to_image_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter_tflite_posenet_image/posenet_model.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<PoseNetModel>(
      create: (context) => PoseNetModel(),
      child: MaterialApp(
        home: MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  VideoToImageModel videoToImageModel;

  @override
  Widget build(BuildContext context) {
    return Consumer<PoseNetModel>(builder: (context, model, child) {
      return Scaffold(
        appBar: AppBar(
          title: Text("pose detection demo"),
        ),
        body: model.allStack != null
            ? Container(
                child: GridView.builder(
                  itemCount: model.allStack.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 5,
                    childAspectRatio: 0.5625,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: model.allStack[index],
                    );
                  },
                ),
              )
            : Container(),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await model.loadModel();
            Size size = MediaQuery.of(context).size;
            await model.pickImage(size);

            //await model.bornPaint(size);
          },
          child: Icon(Icons.image),
        ),
      );
    });
  }
}
