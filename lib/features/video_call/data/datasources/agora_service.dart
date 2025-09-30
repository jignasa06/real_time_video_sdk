import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isMicrophoneMuted = false;
  bool _isCameraMuted = false;

  RtcEngine? get engine => _engine;
  bool get isInitialized => _isInitialized;
  bool get isMicrophoneMuted => _isMicrophoneMuted;
  bool get isCameraMuted => _isCameraMuted;

  /// Initialize Agora Engine
  Future<void> initialize() async {
    try {
      if (_isInitialized) {
        return;
      }

      // Validate App ID
      if (AppConstants.agoraAppId.isEmpty || AppConstants.agoraAppId == 'YOUR_AGORA_APP_ID') {
        throw ServerException(AppStrings.invalidAgoraAppId);
      }

      // Request permissions
      await _requestPermissions();

      // Create RTC engine
      _engine = createAgoraRtcEngine();
      
      await _engine!.initialize(const RtcEngineContext(
        appId: AppConstants.agoraAppId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // Enable video
      await _engine!.enableVideo();
      await _engine!.enableAudio();

      // Set video configuration
      await _engine!.setVideoEncoderConfiguration(
        const VideoEncoderConfiguration(
          dimensions: VideoDimensions(width: 640, height: 480),
          frameRate: 15,
          bitrate: 0,
        ),
      );

      _isInitialized = true;
    } catch (e) {
      throw ServerException('${AppStrings.failedToInitializeVideoEngine}: ${e.toString()}');
    }
  }

  /// Request camera and microphone permissions
  Future<void> _requestPermissions() async {
    try {
      // Request permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.camera,
        Permission.microphone,
      ].request();

      // Check if permanently denied
      if (statuses[Permission.camera] == PermissionStatus.permanentlyDenied ||
          statuses[Permission.microphone] == PermissionStatus.permanentlyDenied) {
        throw ServerException(AppStrings.permissionsPermanentlyDenied);
      }

      if (statuses[Permission.camera] != PermissionStatus.granted ||
          statuses[Permission.microphone] != PermissionStatus.granted) {
        throw ServerException(AppStrings.permissionsDenied);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Join a channel
  Future<void> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    try {
      if (!_isInitialized || _engine == null) {
        throw ServerException('Engine not initialized');
      }

      await _engine!.joinChannel(
        token: token ?? AppConstants.agoraToken,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

    } catch (e) {
      throw ServerException(AppStrings.failedToJoinVideoCall);
    }
  }

  /// Leave the channel
  Future<void> leaveChannel() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
      }
    } catch (e) {
      throw ServerException(AppStrings.failedToLeaveVideoCall);
    }
  }

  /// Toggle microphone
  Future<void> toggleMicrophone() async {
    try {
      if (_engine == null) {
        throw ServerException(AppStrings.engineNotInitialized);
      }

      _isMicrophoneMuted = !_isMicrophoneMuted;
      await _engine!.muteLocalAudioStream(_isMicrophoneMuted);
      await _engine!.enableLocalAudio(!_isMicrophoneMuted);
    } catch (e) {
      throw ServerException(AppStrings.failedToToggleMicrophone);
    }
  }

  /// Toggle camera
  Future<void> toggleCamera() async {
    try {
      if (_engine == null) {
        throw ServerException(AppStrings.engineNotInitialized);
      }

      _isCameraMuted = !_isCameraMuted;
      await _engine!.muteLocalVideoStream(_isCameraMuted);
      await _engine!.enableLocalVideo(!_isCameraMuted);
    } catch (e) {
      throw ServerException(AppStrings.failedToToggleCamera);
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    try {
      if (_engine == null) {
        throw ServerException(AppStrings.engineNotInitialized);
      }

      await _engine!.switchCamera();
    } catch (e) {
      throw ServerException(AppStrings.failedToSwitchCamera);
    }
  }

  /// Dispose engine
  Future<void> dispose() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
        _isInitialized = false;
      }
    } catch (e) {
      // Silently handle dispose errors
    }
  }
}
