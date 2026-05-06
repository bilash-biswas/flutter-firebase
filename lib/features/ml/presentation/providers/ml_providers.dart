import 'package:flutter_firebase/features/ml/data/datasources/ml_datasource.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final mlDataSourceProvider = Provider<MLDataSource>((ref) {
  final ds = MLDataSource();
  ref.onDispose(() => ds.dispose());
  return ds;
});

enum MLTask { ocr, barcode, face }

final mlScannerProvider = Provider<Future<String?> Function(MLTask)>((ref) {
  final ds = ref.watch(mlDataSourceProvider);
  final picker = ImagePicker();

  return (task) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    
    switch (task) {
      case MLTask.ocr:
        return await ds.recognizeText(image.path);
      case MLTask.barcode:
        final barcodes = await ds.scanBarcodes(image.path);
        return barcodes.isNotEmpty ? barcodes.join(', ') : 'No barcodes found';
      case MLTask.face:
        final count = await ds.detectFaces(image.path);
        return 'Detected $count faces in image';
    }
  };
});
