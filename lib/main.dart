import 'dart:io';
import 'package:google_ml_vision/google_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

import 'pages/CapturePictureScreen.dart';

//import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

late List<CameraDescription> cameras;

void main() {
  
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image to Text Converter',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}



class _MyHomePageState extends State<MyHomePage> {
  final picker = ImagePicker();
  late List<CameraDescription> cameras;
  XFile? _image;
  String _text = '';
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }



  Future<void> _initializeCamera() async {
    //super.initState();
    cameras = await availableCameras();
  }

   


  Future<void> _takePicture() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CapturePictureScreen(camera: cameras.first),
    ),
  );
  if (result != null) {
    setState(() {
      _image = XFile(result);
    });
  }
   }

Future<void> _getImage() async {
  try {
    final image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  } catch (e) {
    // Handle the error here
    print('Error occurred while picking image: $e');
   
  }
}


  Future<void> _recognizeText() async {
    if (_image == null) return;

    final GoogleVisionImage visionImage =
        GoogleVisionImage.fromFilePath(_image!.path);

    final TextRecognizer textRecognizer =
        GoogleVision.instance.textRecognizer();
    
    try {
      final VisionText visionText =
          await textRecognizer.processImage(visionImage);

      String text = '';
      for (TextBlock block in visionText.blocks) {
        print(block.text);
        for (TextLine line in block.lines) {
          text += line.text! + '\n' ;
         // print(line.text);
        }
      }
      setState(() {
        _text = text;
      });
    } catch (e) {
      print('Error occurred while recognizing text: $e');
    } finally {
      textRecognizer.close();
    }
  }


  @override
  Widget build(BuildContext context) {
   /* if (_controller == null || !_controller!.value.isInitialized) {
      return Container();
    } */
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Image to Text Converter'),
        ),
        body: 
        
        ListView(
          padding: const EdgeInsets.all(8.0),
          children: [
            //Expanded(
           // child: CameraPreview(_controller!),
       //   ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _takePicture,
            child: Text('Take Picture'),
          ),
          SizedBox(height: 20),
            if (_image != null)
              Image.file(File(_image!.path)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _recognizeText,
              child: Text('Extract Text'),
            ),
            SizedBox(height: 20),
            if (_text.isNotEmpty)
              Text(
                _text,
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
