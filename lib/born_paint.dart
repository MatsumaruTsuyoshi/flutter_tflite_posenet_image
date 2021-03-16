import 'dart:math' as math;

import 'package:flutter/material.dart';

class BornPaint extends CustomPainter {
  List recognitions;
  Size screen;
  double imageHeight;
  double imageWidth;

  BornPaint(
      {this.recognitions, this.screen, this.imageHeight, this.imageWidth});

  @override
  void paint(Canvas canvas, Size size) {
    if (imageWidth == 0.0 && imageHeight == 0.0) return;
    if (recognitions.length == 0) return;
    final blue = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4;
    final red = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;
    final green = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;
    final greenAccent = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    double factorX = screen.width;

    double factorY = imageHeight / imageWidth * screen.width;
    final re = recognitions[0]['keypoints'];
    final dec0 = Offset(re[0]['x'] * factorX, re[0]['y'] * factorY);
    final dec5 = Offset(re[5]['x'] * factorX, re[5]['y'] * factorY);
    final dec6 = Offset(re[6]['x'] * factorX, re[6]['y'] * factorY);
    final dec7 = Offset(re[7]['x'] * factorX, re[7]['y'] * factorY);
    final dec8 = Offset(re[8]['x'] * factorX, re[8]['y'] * factorY);
    final dec9 = Offset(re[9]['x'] * factorX, re[9]['y'] * factorY);
    final dec10 = Offset(re[10]['x'] * factorX, re[10]['y'] * factorY);
    final dec11 = Offset(re[11]['x'] * factorX, re[11]['y'] * factorY);
    final dec12 = Offset(re[12]['x'] * factorX, re[12]['y'] * factorY);
    final dec13 = Offset(re[13]['x'] * factorX, re[13]['y'] * factorY);
    final dec14 = Offset(re[14]['x'] * factorX, re[14]['y'] * factorY);
    final dec15 = Offset(re[15]['x'] * factorX, re[15]['y'] * factorY);
    final dec16 = Offset(re[16]['x'] * factorX, re[16]['y'] * factorY);
    final radius = math.min(size.width, size.height);
    //nose
    canvas.drawCircle(dec0, radius, green);
    canvas.drawLine(
        dec0,
        Offset((dec6.dx - dec5.dx) / 2 + dec5.dx,
            (dec6.dy - dec5.dy) / 2 + dec5.dy),
        green);
    //左手
    canvas.drawLine(dec5, dec7, red);
    canvas.drawLine(dec7, dec9, red);
    canvas.drawCircle(dec7, radius, red);
    canvas.drawCircle(dec9, radius, red);
    //右手
    canvas.drawLine(dec6, dec8, blue);
    canvas.drawLine(dec8, dec10, blue);
    canvas.drawCircle(dec8, radius, blue);
    canvas.drawCircle(dec10, radius, blue);

    //左足
    canvas.drawLine(dec13, dec15, red);
    canvas.drawLine(dec11, dec13, red);
    canvas.drawCircle(dec13, radius, red);
    canvas.drawCircle(dec15, radius, red);
    //右足
    canvas.drawLine(dec12, dec14, blue);
    canvas.drawLine(dec14, dec16, blue);
    canvas.drawCircle(dec14, radius, blue);
    canvas.drawCircle(dec16, radius, blue);
    //上半身
    canvas.drawLine(dec5, dec6, green);
    canvas.drawLine(dec6, dec12, green);
    canvas.drawLine(dec11, dec12, green);
    canvas.drawLine(dec11, dec5, green);
    canvas.drawCircle(dec5, radius, green);
    canvas.drawCircle(dec6, radius, green);
    canvas.drawCircle(dec11, radius, green);
    canvas.drawCircle(dec12, radius, green);

    //右半身と右足の角度
    List angle12 =
        calRad(dec12.dx, dec12.dy, dec6.dx, dec6.dy, dec14.dx, dec14.dy);
    final _angle12 = '${(angle12[0] * 180 / math.pi).toStringAsFixed(0) + '°'}';
    canvas.drawArc(
        Rect.fromCircle(center: Offset(dec12.dx, dec12.dy), radius: 15),
        -angle12[1],
        angle12[0],
        false,
        greenAccent);
    TextPainter textPainter5 = textPainterCustom(_angle12);
    textPainter5.paint(canvas, Offset(dec12.dx + 18, dec12.dy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

List calRad(Xa, Ya, Xb, Yb, Xc, Yc) {
  //平方定理
  double ab = math.pow(math.pow(Xa - Xb, 2) + math.pow(Ya - Yb, 2), 0.5);
  double ac = math.pow(math.pow(Xa - Xc, 2) + math.pow(Ya - Yc, 2), 0.5);
  double bc = math.pow(math.pow(Xb - Xc, 2) + math.pow(Yb - Yc, 2), 0.5);
  //第二余弦定理
  double angle =
      (math.pow(ab, 2) + math.pow(ac, 2) - math.pow(bc, 2)) / (2 * ab * ac);
  //アークcosθでradianが算出、degを算出したいなら180/pi
  double angleRad = math.acos(angle);

  //角度の角度を合わせるための調整
  double deltaAngle =
      (Xb - Xa) / math.pow(math.pow(Xb - Xa, 2) + math.pow(Yb - Ya, 2), 0.5);
  double deltaAngleRad = math.acos(deltaAngle);

  return [angleRad, deltaAngleRad];
}

//角度を表示するために必要
TextPainter textPainterCustom(_angle) {
  final textStyle = TextStyle(
    shadows: [
      Shadow(
        blurRadius: 2.0,
        color: Colors.black,
        offset: Offset(1.0, 1.0),
      ),
      Shadow(
        blurRadius: 2.0,
        color: Colors.black,
        offset: Offset(-1.0, -1.0),
      )
    ],
    color: Colors.tealAccent,
    fontSize: 20.0,
  );
  final textSpan = TextSpan(text: _angle, style: textStyle);
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );

  textPainter.layout(minWidth: 0, maxWidth: 100);
  return textPainter;
}
