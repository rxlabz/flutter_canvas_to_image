import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

void main() => runApp(new App());

const kCanvasSize = 200.0;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        body: new ImageGenerator(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageGenerator extends StatefulWidget {
  final Random rd;
  final int numColors;

  ImageGenerator()
      : rd = new Random(),
        numColors = Colors.primaries.length;

  @override
  _ImageGeneratorState createState() => new _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  ByteData imgBytes;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(12.0),
            child: new RaisedButton(
                child: new Text('Generate image'), onPressed: generateImage),
          ),
          imgBytes != null
              ? new Center(
                  child: new Image.memory(
                  new Uint8List.view(imgBytes.buffer),
                  width: kCanvasSize,
                  height: kCanvasSize,
                ))
              : new Container(width: 100.0, height: 100.0, color: Colors.grey)
        ],
      ),
    );
  }

  void generateImage() async {
    final color = Colors.primaries[widget.rd.nextInt(widget.numColors)];

    final recorder = new ui.PictureRecorder();
    final canvas = new Canvas(
        recorder,
        new Rect.fromPoints(
            new Offset(0.0, 0.0), new Offset(kCanvasSize, kCanvasSize)));

    final stroke = new Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
        new Rect.fromLTWH(0.0, 0.0, kCanvasSize, kCanvasSize), stroke);

    final paint = new Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        new Offset(
          widget.rd.nextDouble() * kCanvasSize,
          widget.rd.nextDouble() * kCanvasSize,
        ),
        20.0,
        paint);

    final picture = recorder.endRecording();
    final img = picture.toImage(200, 200);
    final pngBytes = await img.toByteData(format: new ui.EncodingFormat.png());

    setState(() {
      imgBytes = pngBytes;
    });
  }
}
