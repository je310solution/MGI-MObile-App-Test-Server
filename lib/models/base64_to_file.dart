import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';

class ConvertBase64ToFile{
  Future createFileFromString({required String encoded}) async {
    Uint8List bytes = base64.decode(encoded);
    String dir = (await getApplicationDocumentsDirectory()).path;
    String fullPath = '$dir/signature.png';
    File file = File(fullPath);
    await file.writeAsBytes(bytes);
    final result = await ImageGallerySaverPlus.saveImage(bytes);
    return file;
  }
}