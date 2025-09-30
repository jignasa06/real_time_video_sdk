import 'package:equatable/equatable.dart';

class CallParticipant extends Equatable {
  final int uid;
  final String? name;
  final bool isAudioMuted;
  final bool isVideoMuted;

  const CallParticipant({
    required this.uid,
    this.name,
    this.isAudioMuted = false,
    this.isVideoMuted = false,
  });

  CallParticipant copyWith({
    int? uid,
    String? name,
    bool? isAudioMuted,
    bool? isVideoMuted,
  }) {
    return CallParticipant(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
    );
  }

  @override
  List<Object?> get props => [uid, name, isAudioMuted, isVideoMuted];
}
