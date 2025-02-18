import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRScreen extends StatefulWidget {
  @override
  _OCRScreenState createState() => _OCRScreenState();
}

class _OCRScreenState extends State<OCRScreen> {
  String extractedText = '';

  Future<void> pickAndExtractText() async {
    final pickedFile = await pickImage();

    if (pickedFile != null) {
      // Extract text from the picked image
      final text = await extractText(pickedFile.path);

      setState(() {
        extractedText = text;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('OCR with Google ML Kit')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickAndExtractText,
              child: Text('Pick Image for OCR'),
            ),
            SizedBox(height: 20),
            Text('Extracted Text:'),
            SizedBox(height: 10),
            Text(
              extractedText.isEmpty ? 'No text extracted' : extractedText,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
