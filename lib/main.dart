import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ExtractedDetail {
  final String text;
  final Rect boundingBox;

  ExtractedDetail(this.text, this.boundingBox);
}

Future<List<ExtractedDetail>> extractANECOBillDetails(File image) async {
  final inputImage = InputImage.fromFile(image);
  final textRecognizer = GoogleMlKit.vision.textRecognizer();
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

  List<ExtractedDetail> extractedDetails = [];
  for (TextBlock block in recognizedText.blocks) {
    for (TextLine line in block.lines) {
      if (line.text.contains('Account Number :') || 
          line.text.contains('This Month') || 
          line.text.contains('Previous Reading ') || 
          line.text.contains('Present Reading ') || 
          line.text.contains('kWh Consumption') || 
          line.text.contains('Substation:') || 
          line.text.contains('Current Bill Due Date') || 
          line.text.contains('Arrears/Overdue') || 
          line.text.contains('Surcharge') || 
          line.text.contains('Surcharge EVAT') || 
          line.text.contains('TOTAL AMOUNT')) {
        extractedDetails.add(ExtractedDetail(line.text, line.boundingBox));
      }
    }
  }
  textRecognizer.close();
  return extractedDetails;
}

FlutterTts flutterTts = FlutterTts();
Future<void> speakDetails(List<ExtractedDetail> details) async {
  String textToSpeak = '';
  details.forEach((detail) {
    textToSpeak += '${detail.text}. ';
  });
  await flutterTts.speak(textToSpeak);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ANECOTextExtractor(),
    );
  }
}

class ANECOTextExtractor extends StatefulWidget {
  @override
  _ANECOTextExtractorState createState() => _ANECOTextExtractorState();
}

class _ANECOTextExtractorState extends State<ANECOTextExtractor> {
  List<ExtractedDetail>? details;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      List<ExtractedDetail> extractedData = await extractANECOBillDetails(image);
      setState(() {
        details = extractedData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ANECO Bill Extractor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (details != null) ...details!.map((e) => Text('${e.text}')),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Select Image'),
            ),
            if (details != null)
              ElevatedButton(
                onPressed: () => speakDetails(details!),
                child: Text('Read Details Aloud'),
              ),
          ],
        ),
      ),
    );
  }
}
