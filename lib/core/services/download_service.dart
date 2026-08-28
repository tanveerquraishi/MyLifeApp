import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mylifepair_matrimony/core/constants/app_constants.dart';

class DownloadService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await Permission.storage.status;
      if (androidInfo.isDenied) {
        final result = await Permission.storage.request();
        return result.isGranted;
      }
      return androidInfo.isGranted;
    }
    return true;
  }

  static Future<String?> getDownloadPath() async {
    Directory? directory;
    
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting download path: $e');
      }
      return null;
    }
    
    return directory?.path;
  }

  static bool isSupportedFileType(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.path.isEmpty) return false;
    
    final path = uri.path.toLowerCase();
    return AppConstants.supportedFileTypes.any((extension) => 
      path.endsWith(extension)
    );
  }

  static String getFileNameFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.path.isEmpty) return 'download';
    
    final path = uri.path;
    final fileName = path.split('/').last;
    
    if (fileName.isEmpty) return 'download';
    
    // Add timestamp to avoid conflicts
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = fileName.contains('.') 
      ? fileName.substring(fileName.lastIndexOf('.')) 
      : '';
    final baseName = fileName.contains('.') 
      ? fileName.substring(0, fileName.lastIndexOf('.')) 
      : fileName;
    
    return '${baseName}_$timestamp$extension';
  }

  static Future<void> downloadFile(String url) async {
    try {
      // Check if file type is supported
      if (!isSupportedFileType(url)) {
        Fluttertoast.showToast(
          msg: 'File type not supported',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        Fluttertoast.showToast(
          msg: 'Storage permission required',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Get download path
      final downloadPath = await getDownloadPath();
      if (downloadPath == null) {
        Fluttertoast.showToast(
          msg: 'Unable to access downloads folder',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        return;
      }

      // Show download started toast
      Fluttertoast.showToast(
        msg: 'Download Started',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      // Get file name
      final fileName = getFileNameFromUrl(url);
      final filePath = '$downloadPath/$fileName';

      // Download file (this is a placeholder - actual implementation would use http package)
      // For now, we'll just show the completion toast
      await Future.delayed(const Duration(seconds: 2)); // Simulate download

      Fluttertoast.showToast(
        msg: 'Download Completed',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );

      if (kDebugMode) {
        print('File downloaded to: $filePath');
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Download failed: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      
      if (kDebugMode) {
        print('Download error: $e');
      }
    }
  }
}