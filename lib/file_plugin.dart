import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Util class to prepare audio files for custom audio browser
class FilePlugin {
  Future<Uri> createAssetFileUri(String prefix, String fileName) async {
    final byteData = await rootBundle.load('$prefix$fileName');
    final file = File('${await _getTemporaryDirectoryPath()}/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.uri;
  }

  Future<String> _getTemporaryDirectoryPath() async {
    if (Platform.isAndroid) {
      final result = await getExternalStorageDirectories();
      if (result == null || result.isEmpty) {
        throw Exception("Cannot resolve temporary directory!");
      } else {
        return result.first.path;
      }
    } else {
      final dir = await getTemporaryDirectory();
      return dir.path;
    }
  }
}
