import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_demo/resource/constants.dart';
import 'package:loggy/loggy.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class Utils {
  static String homeDir = '';
  static const tag = 'utils';

  static Future init() async {
    try {
      if (homeDir.isEmpty) {
        homeDir = await _getLocalFolder();
      }
      await createFolder(homeDir);
    } catch (ex) {
      logWarning('$tag: init error [$ex]');
    }
    return null;
  }

  Future writeToFile(ByteData data, String path) async {
    final buffer = data.buffer;
    await File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    return null;
  }

  static Future<String?> getDowloadPath(String name) async {
    Directory? dir;
    if (Platform.isAndroid) {
      dir = Directory('/storage/emulated/0/Download');
    } else {
      dir = await getDownloadsDirectory();
    }
    if (dir == null) return null;
    var path = '${dir.path}/$name';
    return path;
  }

  static Future createFolder(String path) async {
    if (!await Directory(path).exists()) {
      await Directory(path).create(recursive: true);
    }
  }

  static Future deleteFolder(String path) async {
    if (await Directory(path).exists()) {
      await Directory(path).delete(recursive: true);
    }
  }

  static Future<String?> saveFileToDownloads(String path, String name) async {
    // copy the file to download
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      var dir = await getDownloadsDirectory();
      if (dir == null) return null;
      var pathToFile = '${dir.path}/$name';
      await copyFile(path, pathToFile);
      return pathToFile;
    } else {
      var dir = Directory('/storage/emulated/0/Download');
      if (!await dir.exists()) {
        var dir_ = await getExternalStorageDirectory();
        if (dir_ != null) {
          dir = dir_;
        }
      }
      var pathToFile = '${dir.path}/$name';
      await copyFile(path, pathToFile);
      return pathToFile;
    }
  }

  static Future<bool> copyFile(String srcPath, String destPath) async {
    await File(srcPath).copy(destPath);
    return true;
  }

  static Future<File> saveBufToFile(List<int> data, String filePath) async {
    var outFile = await File(filePath).create(recursive: true);
    return await outFile.writeAsBytes(data);
  }

  void shareApp() {
    Share.shareUri(Uri.parse(Constants.appLink));
  }

  static String getFileName(String path) {
    if (Platform.isWindows) {
      path = path.replaceAll('/', '\\');
    }
    File file = File(path);
    var name = file.path.split(Platform.isWindows ? '\\' : '/').last;
    return name;
  }

  static Future<String> _getLocalFolder() async {
    var path = '';
    switch (Platform.operatingSystem) {
      case 'linux':
      case 'macos':
        path = Platform.environment['HOME'] ?? '/';
        path = '$path/${Constants.localFolderName}';
        break;
      case 'windows':
        path = Platform.environment['USERPROFILE'] ?? '/';
        path = '$path/${Constants.localFolderName}';
        break;
      case 'android':
        var dir = await getExternalStorageDirectory();
        path = dir?.path ?? '/';
        break;
      case 'ios':
        var dir = await getApplicationDocumentsDirectory();
        var dirStr = dir.path;
        await Directory(dirStr).create(recursive: true);
        path = dirStr;
        path = '$path/${Constants.localFolderName}';
        break;
      default:
        path = '/';
    }
    return path;
  }
}
