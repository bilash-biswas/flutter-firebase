import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MLDataSource {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableClassification: true,
    ),
  );

  // 1. OCR
  Future<String> recognizeText(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text.trim();
  }

  // 2. Barcode Scanning
  Future<List<String>> scanBarcodes(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final List<Barcode> barcodes = await _barcodeScanner.processImage(inputImage);
    return barcodes.map((b) => b.displayValue ?? 'Unknown Barcode').toList();
  }

  // 3. Face Detection
  Future<int> detectFaces(String imagePath) async {
    final InputImage inputImage = InputImage.fromFilePath(imagePath);
    final List<Face> faces = await _faceDetector.processImage(inputImage);
    return faces.length;
  }

  void dispose() {
    _textRecognizer.close();
    _barcodeScanner.close();
    _faceDetector.close();
  }
}
