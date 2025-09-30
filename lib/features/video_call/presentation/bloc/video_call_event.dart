import 'package:equatable/equatable.dart';

abstract class VideoCallEvent extends Equatable {
  const VideoCallEvent();

  @override
  List<Object?> get props => [];
}

class InitializeEngine extends VideoCallEvent {
  const InitializeEngine();
}

class JoinChannel extends VideoCallEvent {
  final String channelName;
  final int uid;
  final String? token;

  const JoinChannel({
    required this.channelName,
    required this.uid,
    this.token,
  });

  @override
  List<Object?> get props => [channelName, uid, token];
}

class LeaveChannel extends VideoCallEvent {
  const LeaveChannel();
}

class ToggleMicrophone extends VideoCallEvent {
  const ToggleMicrophone();
}

class ToggleCamera extends VideoCallEvent {
  const ToggleCamera();
}

class SwitchCamera extends VideoCallEvent {
  const SwitchCamera();
}

class ToggleScreenShare extends VideoCallEvent {
  const ToggleScreenShare();
}

class UserJoined extends VideoCallEvent {
  final int uid;

  const UserJoined(this.uid);

  @override
  List<Object?> get props => [uid];
}

class UserLeft extends VideoCallEvent {
  final int uid;

  const UserLeft(this.uid);

  @override
  List<Object?> get props => [uid];
}

class DisposeEngine extends VideoCallEvent {
  const DisposeEngine();
}
