import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/call_participant.dart';
import '../../domain/repositories/video_call_repository.dart';
import 'video_call_event.dart';
import 'video_call_state.dart';

class VideoCallBloc extends Bloc<VideoCallEvent, VideoCallState> {
  final VideoCallRepository repository;

  VideoCallBloc({required this.repository}) : super(const VideoCallInitial()) {
    on<InitializeEngine>(_onInitializeEngine);
    on<JoinChannel>(_onJoinChannel);
    on<LeaveChannel>(_onLeaveChannel);
    on<ToggleMicrophone>(_onToggleMicrophone);
    on<ToggleCamera>(_onToggleCamera);
    on<SwitchCamera>(_onSwitchCamera);
    on<UserJoined>(_onUserJoined);
    on<UserLeft>(_onUserLeft);
    on<DisposeEngine>(_onDisposeEngine);
  }

  Future<void> _onInitializeEngine(
    InitializeEngine event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(const VideoCallInitializing());

    final result = await repository.initializeEngine();

    result.fold(
      (failure) => emit(VideoCallError(failure.message)),
      (_) => emit(const VideoCallReady()),
    );
  }

  Future<void> _onJoinChannel(
    JoinChannel event,
    Emitter<VideoCallState> emit,
  ) async {
    emit(const VideoCallConnecting());

    final result = await repository.joinChannel(
      channelName: event.channelName,
      uid: event.uid,
      token: event.token,
    );

    result.fold(
      (failure) => emit(VideoCallError(failure.message)),
      (_) => emit(VideoCallConnected(
        channelName: event.channelName,
        localUid: event.uid,
      )),
    );
  }

  Future<void> _onLeaveChannel(
    LeaveChannel event,
    Emitter<VideoCallState> emit,
  ) async {
    final result = await repository.leaveChannel();

    result.fold(
      (failure) => emit(VideoCallError(failure.message)),
      (_) => emit(const VideoCallDisconnected()),
    );
  }

  Future<void> _onToggleMicrophone(
    ToggleMicrophone event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final result = await repository.toggleMicrophone();

      result.fold(
        (failure) => emit(VideoCallError(failure.message)),
        (_) => emit(currentState.copyWith(
          isMicrophoneMuted: !currentState.isMicrophoneMuted,
        )),
      );
    }
  }

  Future<void> _onToggleCamera(
    ToggleCamera event,
    Emitter<VideoCallState> emit,
  ) async {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final result = await repository.toggleCamera();

      result.fold(
        (failure) => emit(VideoCallError(failure.message)),
        (_) => emit(currentState.copyWith(
          isCameraMuted: !currentState.isCameraMuted,
        )),
      );
    }
  }

  Future<void> _onSwitchCamera(
    SwitchCamera event,
    Emitter<VideoCallState> emit,
  ) async {
    final result = await repository.switchCamera();

    result.fold(
      (failure) => emit(VideoCallError(failure.message)),
      (_) {}, // No state change needed
    );
  }

  void _onUserJoined(
    UserJoined event,
    Emitter<VideoCallState> emit,
  ) {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final updatedUsers = List<CallParticipant>.from(currentState.remoteUsers)
        ..add(CallParticipant(uid: event.uid));

      emit(currentState.copyWith(remoteUsers: updatedUsers));
    }
  }

  void _onUserLeft(
    UserLeft event,
    Emitter<VideoCallState> emit,
  ) {
    if (state is VideoCallConnected) {
      final currentState = state as VideoCallConnected;
      final updatedUsers = currentState.remoteUsers
          .where((user) => user.uid != event.uid)
          .toList();

      emit(currentState.copyWith(remoteUsers: updatedUsers));
    }
  }

  Future<void> _onDisposeEngine(
    DisposeEngine event,
    Emitter<VideoCallState> emit,
  ) async {
    await repository.dispose();
    emit(const VideoCallInitial());
  }
}
