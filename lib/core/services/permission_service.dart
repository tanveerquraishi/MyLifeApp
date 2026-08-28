import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<bool> isAndroid13OrHigher() async {
    if (!kDebugMode && !isAndroid()) return false;
    
    try {
      final androidInfo = await _deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking Android version: $e');
      }
      return false;
    }
  }

  bool isAndroid() {
    // This would typically check the platform
    // For now, we'll assume Android since this is an Android-only app
    return true;
  }

  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.camera.request();
      if (result.isGranted) {
        return true;
      }
      
      if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Camera');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('Camera');
      return false;
    }
    
    return false;
  }

  Future<bool> requestStoragePermission() async {
    final isAndroid13 = await isAndroid13OrHigher();
    
    if (isAndroid13) {
      // Android 13+ uses media permissions
      return await _requestMediaPermissions();
    } else {
      // Android 12 and below uses storage permission
      return await _requestLegacyStoragePermission();
    }
  }

  Future<bool> _requestMediaPermissions() async {
    final imageStatus = await Permission.photos.status;
    final videoStatus = await Permission.videos.status;
    
    if (imageStatus.isGranted && videoStatus.isGranted) {
      return true;
    }
    
    Map<Permission, PermissionStatus> statuses;
    
    if (imageStatus.isDenied || videoStatus.isDenied) {
      statuses = await [
        Permission.photos,
        Permission.videos,
      ].request();
    } else {
      statuses = {
        Permission.photos: imageStatus,
        Permission.videos: videoStatus,
      };
    }
    
    final allGranted = statuses.values.every((status) => status.isGranted);
    
    if (!allGranted) {
      final anyPermanentlyDenied = statuses.values.any((status) => status.isPermanentlyDenied);
      if (anyPermanentlyDenied) {
        _showPermissionDeniedDialog('Storage/Media');
      }
    }
    
    return allGranted;
  }

  Future<bool> _requestLegacyStoragePermission() async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.storage.request();
      if (result.isGranted) {
        return true;
      }
      
      if (result.isPermanentlyDenied) {
        _showPermissionDeniedDialog('Storage');
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('Storage');
      return false;
    }
    
    return false;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.notification.request();
      return result.isGranted;
    }
    
    return false;
  }

  Future<bool> requestAllPermissions() async {
    final results = await Future.wait([
      requestCameraPermission(),
      requestStoragePermission(),
      requestNotificationPermission(),
    ]);
    
    return results.every((granted) => granted);
  }

  void _showPermissionDeniedDialog(String permissionName) {
    if (kDebugMode) {
      print('$permissionName permission permanently denied. Please enable in app settings.');
    }
  }

  Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }
}