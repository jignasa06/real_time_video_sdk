import 'dart:developer';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';

/// A service class that handles Agora RTC engine operations
class AgoraService {
  // Private members
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isMicrophoneMuted = false;
  bool _isCameraMuted = false;
  bool _isScreenSharing = false;

  // Getters
  RtcEngine? get engine => _engine;
  bool get isInitialized => _isInitialized;
  bool get isMicrophoneMuted => _isMicrophoneMuted;
  bool get isCameraMuted => _isCameraMuted;
  bool get isScreenSharing => _isScreenSharing;

  // Constants
  static const _tag = 'AgoraService';
  static const _defaultVideoConfig = VideoEncoderConfiguration(
    dimensions: VideoDimensions(width: 640, height: 480),
    frameRate: 15,
    bitrate: 0,
  );

  /// Initializes the Agora RTC engine with the provided app ID
  /// 
  /// Throws [ServerException] if initialization fails
  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        log('Agora engine already initialized', name: _tag);
        return;
      }

      _validateAppId();
      await _requestPermissions();
      await _setupEngine();
      
      _isInitialized = true;
      log('Agora engine initialized successfully', name: _tag);
    } catch (e) {
      final errorMsg = '${AppStrings.failedToInitializeVideoEngine}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Validates the Agora App ID
  void _validateAppId() {
    if (AppConstants.agoraAppId.isEmpty || 
        AppConstants.agoraAppId == 'YOUR_AGORA_APP_ID') {
      throw const FormatException('Invalid Agora App ID');
    }
  }

  /// Sets up the Agora RTC engine with default configurations
  Future<void> _setupEngine() async {
    _engine = createAgoraRtcEngine();
    
    await _engine!.initialize(RtcEngineContext(
      appId: AppConstants.agoraAppId,
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await Future.wait([
      _engine!.enableVideo(),
      _engine!.enableAudio(),
      _engine!.setVideoEncoderConfiguration(_defaultVideoConfig),
    ]);
  }

  /// Requests necessary permissions for video/audio calls
  /// 
  /// Throws [ServerException] if permissions are denied
  Future<void> _requestPermissions() async {
    try {
      final statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      _checkPermissionStatuses(statuses);
    } catch (e) {
      log('Permission request failed', name: _tag, error: e);
      rethrow;
    }
  }

  /// Checks if all required permissions are granted
  void _checkPermissionStatuses(Map<Permission, PermissionStatus> statuses) {
    final cameraStatus = statuses[Permission.camera];
    final micStatus = statuses[Permission.microphone];

    if (cameraStatus == PermissionStatus.permanentlyDenied ||
        micStatus == PermissionStatus.permanentlyDenied) {
      throw ServerException(AppStrings.permissionsPermanentlyDenied);
    }

    if (cameraStatus != PermissionStatus.granted ||
        micStatus != PermissionStatus.granted) {
      throw ServerException(AppStrings.permissionsDenied);
    }
  }

  // ====================
  // Channel Management
  // ====================

  /// Joins a channel with the specified parameters
  /// 
  /// [channelName] The name of the channel to join
  /// [uid] The user ID
  /// [token] Optional token for secure access
  /// 
  /// Throws [ServerException] if joining fails
  Future<void> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    try {
      _checkEngineInitialized();
      await _engine!.startPreview();
      
      await _engine!.joinChannel(
        token: token ?? AppConstants.agoraToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
        ),
      );
      
      log('Joined channel: $channelName as UID: $uid', name: _tag);
    } catch (e) {
      final errorMsg = '${AppStrings.failedToJoinVideoCall}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Leaves the current channel
  /// 
  /// Throws [ServerException] if leaving fails
  Future<void> leaveChannel() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        log('Left the channel', name: _tag);
      }
    } catch (e) {
      final errorMsg = '${AppStrings.failedToLeaveVideoCall}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  // ====================
  // Device Controls
  // ====================

  /// Toggles the microphone mute state
  /// 
  /// Throws [ServerException] if operation fails
  Future<void> toggleMicrophone() async {
    try {
      _checkEngineInitialized();
      _isMicrophoneMuted = !_isMicrophoneMuted;
      
      await _engine!.muteLocalAudioStream(_isMicrophoneMuted);
      log('Microphone ${_isMicrophoneMuted ? 'muted' : 'unmuted'}', name: _tag);
    } catch (e) {
      final errorMsg = '${AppStrings.failedToToggleMicrophone}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Toggles the camera on/off
  /// 
  /// Throws [ServerException] if operation fails
  Future<void> toggleCamera() async {
    try {
      _checkEngineInitialized();
      _isCameraMuted = !_isCameraMuted;
      
      await Future.wait([
        _engine!.muteLocalVideoStream(_isCameraMuted),
        _engine!.enableLocalVideo(!_isCameraMuted),
      ]);
      
      log('Camera ${_isCameraMuted ? 'disabled' : 'enabled'}', name: _tag);
    } catch (e) {
      final errorMsg = '${AppStrings.failedToToggleCamera}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Switches between front and back cameras
  /// 
  /// Throws [ServerException] if operation fails
  Future<void> switchCamera() async {
    try {
      _checkEngineInitialized();
      await _engine!.switchCamera();
      log('Camera switched', name: _tag);
    } catch (e) {
      final errorMsg = '${AppStrings.failedToSwitchCamera}: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Checks if the engine is initialized
  /// 
  /// Throws [ServerException] if engine is not initialized
  void _checkEngineInitialized() {
    if (!_isInitialized || _engine == null) {
      throw ServerException(AppStrings.engineNotInitialized);
    }
  }

  // ====================
  // Screen Sharing
  // ====================

  /// Screen sharing configuration
  static const _screenShareConfig = ScreenCaptureParameters2(
    captureAudio: false,  // Disable audio capture for screen sharing
    captureVideo: true,
    videoParams: ScreenVideoParameters(
      dimensions: VideoDimensions(width: 1280, height: 720),
      frameRate: 15,
      bitrate: 1000,
    ),
  );

  /// Starts screen sharing with other participants
  /// 
  /// Throws [ServerException] with specific error messages for different failure cases
  Future<void> startScreenShare() async {
    _checkEngineInitialized();

    if (_isScreenSharing) {
      log('Screen sharing is already active', name: _tag);
      return;
    }

    try {
      log('Starting screen sharing...', name: _tag);
      
      await _stopExistingScreenCapture();
      await _startScreenCapture();
      await _updateForScreenSharing();
      
      _isScreenSharing = true;
      log('Screen sharing started successfully', name: _tag);
      
    } on AgoraRtcException catch (e) {
      final errorMsg = _getScreenShareErrorMessage(e);
      log('Agora RTC Error: ${e.code} - ${e.message}', 
          name: _tag, error: e);
      throw ServerException(errorMsg);
    } catch (e) {
      final errorMsg = 'Failed to start screen sharing: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Stops screen sharing and resumes camera
  /// 
  /// Throws [ServerException] if stopping fails
  Future<void> stopScreenShare() async {
    try {
      _checkEngineInitialized();

      if (!_isScreenSharing) {
        log('Screen sharing is not active', name: _tag);
        return;
      }

      log('Stopping screen sharing...', name: _tag);
      
      await _stopScreenCapture();
      await _resetAfterScreenSharing();
      
      _isScreenSharing = false;
      log('Screen sharing stopped successfully', name: _tag);
      
    } on AgoraRtcException catch (e) {
      final errorMsg = 'Failed to stop screen sharing (${e.code})';
      log('Agora RTC Error: ${e.code} - ${e.message}', 
          name: _tag, error: e);
      throw ServerException(errorMsg);
    } catch (e) {
      final errorMsg = 'Failed to stop screen sharing: ${e.toString()}';
      log(errorMsg, name: _tag, error: e);
      throw ServerException(errorMsg);
    }
  }

  /// Stops any existing screen capture
  Future<void> _stopExistingScreenCapture() async {
    try {
      await _engine!.stopScreenCapture();
    } catch (e) {
      log('No active screen capture to stop', name: _tag);
    }
  }
  
  /// Stops the current screen capture
  Future<void> _stopScreenCapture() async {
    try {
      await _engine!.stopScreenCapture();
    } catch (e) {
      log('Error stopping screen capture', name: _tag, error: e);
      rethrow;
    }
  }

  /// Starts screen capture with configured parameters
  Future<void> _startScreenCapture() async {
    await _engine!.startScreenCapture(_screenShareConfig);
  }

  /// Updates channel configuration for screen sharing
  Future<void> _updateForScreenSharing() async {
    await _engine!.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishScreenTrack: true,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        enableAudioRecordingOrPlayout: true,
      ),
    );
    
    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
      options: const ClientRoleOptions(
        audienceLatencyLevel: AudienceLatencyLevelType.audienceLatencyLevelLowLatency,
      ),
    );
  }

  /// Resets channel configuration after stopping screen sharing
  Future<void> _resetAfterScreenSharing() async {
    await _engine!.updateChannelMediaOptions(
      const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishScreenTrack: false,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        enableAudioRecordingOrPlayout: true,
      ),
    );
    
    await _engine!.setClientRole(
      role: ClientRoleType.clientRoleBroadcaster,
    );
  }

  /// Gets a user-friendly error message for screen sharing errors
  String _getScreenShareErrorMessage(AgoraRtcException e) {
    switch (e.code) {
      case -2: return 'Screen sharing not supported on this device';
      case -3: return 'Screen sharing permission was denied';
      case -4: return 'Failed to start screen sharing';
      case -7: return 'Screen sharing is already active';
      default: return 'Failed to start screen sharing (${e.code})';
    }
  }

  // ====================
  // Cleanup
  // ====================

  /// Disposes of resources and cleans up the Agora engine
  /// 
  /// This method should be called when the service is no longer needed
  Future<void> dispose() async {
    try {
      if (_engine != null) {
        log('Disposing Agora engine...', name: _tag);
        
        if (_isScreenSharing) {
          await stopScreenShare().catchError((_) {/* Ignore errors during dispose */});
        }
        
        await _engine!.leaveChannel();
        await _engine!.release();
        
        _engine = null;
        _isInitialized = false;
        
        log('Agora engine disposed successfully', name: _tag);
      }
    } catch (e) {
      log('Error disposing Agora engine', name: _tag, error: e);
      // Continue with cleanup even if there's an error
    }
  }
}
