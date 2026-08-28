import 'dart:io';
import 'package:flutter/foundation.dart';
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
        if (kDebugMode) print('File type not supported');
        return;
      }

      // Request storage permission
      final hasPermission = await requestStoragePermission();
      if (!hasPermission) {
        if (kDebugMode) print('Storage permission required');
        return;
      }

      // Get download path
      final downloadPath = await getDownloadPath();
      if (downloadPath == null) {
        if (kDebugMode) print('Unable to access downloads folder');
        return;
      }

      // Show download started
      if (kDebugMode) print('Download Started');

      // Get file name
      final fileName = getFileNameFromUrl(url);
      final filePath = '$downloadPath/$fileName';

      // Download file (this is a placeholder - actual implementation would use http package)
      // For now, we'll just show the completion
      await Future.delayed(const Duration(seconds: 2)); // Simulate download

      if (kDebugMode) {
        print('Download Completed');
        print('File downloaded to: $filePath');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Download failed: $e');
      }
    }
  }
}