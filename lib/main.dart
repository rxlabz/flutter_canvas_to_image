import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(App());

const kCanvasSize = 200.0;

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: ImageGenerator(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ImageGenerator extends StatefulWidget {
  final Random rd;
  final int numColors;

  ImageGenerator()
      : rd = Random(),
        numColors = Colors.primaries.length;

  @override
  _ImageGeneratorState createState() => _ImageGeneratorState();
}

class _ImageGeneratorState extends State<ImageGenerator> {
  ByteData imgBytes;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: RaisedButton(
                child: Text('Generate image'), onPressed: generateImage),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: RaisedButton(child: Text('upload'), onPressed: uploadImage),
          ),
          imgBytes != null
              ? Center(
                  child: Image.memory(
                  Uint8List.view(imgBytes.buffer),
                  width: kCanvasSize,
                  height: kCanvasSize,
                ))
              : Container()
        ],
      ),
    );
  }

  void uploadImage() {
    final url = Uri.parse('http://app.youtabox.com/engine/scripts/upload.php');

    var request = new MultipartRequest("POST", url);
    request.fields['obscurator'] = 'f0rm4l7s';
    request.fields['filename'] = 'test.png';
    request.fields['instanceId'] = '3';
    request.fields['uploadType'] = 'instanceMetaFile';

    request.files.add(new MultipartFile.fromBytes(
        'uploadedFile', Uint8List.view(imgBytes.buffer),
        filename: 'test.png'));
    request.send().then((response) {
      if (response.statusCode == 200)
        print("Uploaded!");
      else
        print('_ImageGeneratorState.uploadImage... ERROR $response');
    });
  }

  void generateImage() async {
    final color = Colors.primaries[widget.rd.nextInt(widget.numColors)];

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromPoints(Offset(0.0, 0.0), Offset(kCanvasSize, kCanvasSize)));

    final stroke = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke;

    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, kCanvasSize, kCanvasSize), fill);
    canvas.drawRect(Rect.fromLTWH(0.0, 0.0, kCanvasSize, kCanvasSize), stroke);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
        Offset(
          widget.rd.nextDouble() * kCanvasSize,
          widget.rd.nextDouble() * kCanvasSize,
        ),
        20.0,
        paint);

    final picture = recorder.endRecording();
    final img = picture.toImage(200, 200);
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    setState(() {
      imgBytes = pngBytes;
    });
  }
}
