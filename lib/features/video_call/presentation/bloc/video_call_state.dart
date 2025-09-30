import 'package:equatable/equatable.dart';
import '../../domain/entities/call_participant.dart';

abstract class VideoCallState extends Equatable {
  const VideoCallState();

  @override
  List<Object?> get props => [];
}

class VideoCallInitial extends VideoCallState {
  const VideoCallInitial();
}

class VideoCallInitializing extends VideoCallState {
  const VideoCallInitializing();
}

class VideoCallReady extends VideoCallState {
  const VideoCallReady();
}

class VideoCallConnecting extends VideoCallState {
  const VideoCallConnecting();
}

class VideoCallConnected extends VideoCallState {
  final String channelName;
  final int localUid;
  final List<CallParticipant> remoteUsers;
  final bool isMicrophoneMuted;
  final bool isCameraMuted;

  const VideoCallConnected({
    required this.channelName,
    required this.localUid,
    this.remoteUsers = const [],
    this.isMicrophoneMuted = false,
    this.isCameraMuted = false,
  });

  VideoCallConnected copyWith({
    String? channelName,
    int? localUid,
    List<CallParticipant>? remoteUsers,
    bool? isMicrophoneMuted,
    bool? isCameraMuted,
  }) {
    return VideoCallConnected(
      channelName: channelName ?? this.channelName,
      localUid: localUid ?? this.localUid,
      remoteUsers: remoteUsers ?? this.remoteUsers,
      isMicrophoneMuted: isMicrophoneMuted ?? this.isMicrophoneMuted,
      isCameraMuted: isCameraMuted ?? this.isCameraMuted,
    );
  }

  @override
  List<Object?> get props => [
        channelName,
        localUid,
        remoteUsers,
        isMicrophoneMuted,
        isCameraMuted,
      ];
}

class VideoCallDisconnected extends VideoCallState {
  const VideoCallDisconnected();
}

class VideoCallError extends VideoCallState {
  final String message;

  const VideoCallError(this.message);

  @override
  List<Object?> get props => [message];
}
