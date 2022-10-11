import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

// Channels
const String _fileMethodChannel = 'file_channel';

// Methods
const String _methodGetTemporaryDirectory = 'get_temporary_directory';

class FilePlugin {
  final _fileChannel = const BasicMessageChannel<String>(_fileMethodChannel, StringCodec());

  Future<Uri> createAssetFileUri(String prefix, String fileName) async {
    final byteData = await rootBundle.load('$prefix$fileName');
    final file = File('${await _getTemporaryDirectoryPath()}/$fileName');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file.uri;
  }

  Future<String> _getTemporaryDirectoryPath() async {
    if (Platform.isAndroid) {
      return _getPlatformTemporaryDirectoryPath();
    } else {
      final dir = await getTemporaryDirectory();
      return dir.path;
    }
  }

  Future<String> _getPlatformTemporaryDirectoryPath() async {
    const message = _methodGetTemporaryDirectory;
    final dirPath = await _fileChannel.send(message);
    if (dirPath != null) {
      return dirPath;
    } else {
      throw Exception(
        'Temporary directory path is null',
      );
    }
  }
}
