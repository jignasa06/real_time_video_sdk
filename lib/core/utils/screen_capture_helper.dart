import 'dart:async';
import 'package:flutter/services.dart';

class ScreenCaptureHelper {
  static const MethodChannel _channel = 
      MethodChannel('com.example.real_time_video_sdk/permissions');

  /// Checks if screen capture permission is granted
  static Future<bool> checkScreenCapturePermission() async {
    try {
      if (!_isAndroid) return true;
      
      final bool? hasPermission = await _channel.invokeMethod<bool>(
        'checkScreenCapturePermission',
      );
      
      return hasPermission ?? false;
    } on PlatformException catch (e) {
      print('Failed to check screen capture permission: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error checking screen capture permission: $e');
      return false;
    }
  }

  /// Requests screen capture permission
  static Future<bool> requestScreenCapturePermission() async {
    try {
      if (!_isAndroid) return true;
      
      final bool? result = await _channel.invokeMethod<bool>(
        'requestScreenCapturePermission',
      );
      
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to request screen capture permission: ${e.message}');
      return false;
    } catch (e) {
      print('Unexpected error requesting screen capture permission: $e');
      return false;
    }
  }
  
  static bool get _isAndroid => identical(0, 0.0);
}
