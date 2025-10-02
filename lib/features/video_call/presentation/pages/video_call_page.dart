import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/di/injection.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/datasources/agora_service.dart';
import '../bloc/video_call_bloc.dart';
import '../bloc/video_call_event.dart';
import '../bloc/video_call_state.dart';
import '../widgets/video_call_controls.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final int uid;

  const VideoCallPage({
    super.key,
    required this.channelName,
    required this.uid,
  });

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  late final AgoraService _agoraService;

  @override
  void initState() {
    super.initState();
    _agoraService = getIt<AgoraService>();
    _initializeCall();
  }

  void _initializeCall() {
    context.read<VideoCallBloc>().add(const InitializeEngine());
  }

  @override
  void dispose() {
    // Don't access context in dispose - cleanup is handled by LeaveChannel event
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.read<VideoCallBloc>().add(const LeaveChannel());
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: BlocConsumer<VideoCallBloc, VideoCallState>(
          listener: (context, state) {
            if (state is VideoCallReady) {
              // Auto-join channel after initialization
              context.read<VideoCallBloc>().add(
                    JoinChannel(
                      channelName: widget.channelName,
                      uid: widget.uid,
                    ),
                  );
            } else if (state is VideoCallError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
              // Navigate back on error after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                if (context.mounted && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            } else if (state is VideoCallDisconnected) {
              // Immediately navigate back to users page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.go(AppRoutes.usersRoute);
                }
              });
            }
          },
        builder: (context, state) {
          if (state is VideoCallInitializing || state is VideoCallConnecting) {
            return _buildLoadingView();
          }

          if (state is VideoCallConnected) {
            return _buildVideoView(state);
          }

          if (state is VideoCallError) {
            return _buildErrorView(state.message);
          }

          if (state is VideoCallDisconnected) {
            return _buildDisconnectingView();
          }

          return _buildLoadingView();
        },
      ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text(
            AppStrings.connecting,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectingView() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.call_end, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              AppStrings.callEnded,
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.goBack),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoView(VideoCallConnected state) {
    return Stack(
      children: [
        // Remote user video (full screen)
        if (state.remoteUsers.isNotEmpty)
          _buildRemoteVideo(state.remoteUsers.first.uid)
        else
          _buildWaitingView(),

        // Local user video (small preview)
        Positioned(
          top: 50,
          right: 16,
          child: _buildLocalVideoPreview(),
        ),

        // Top bar with channel info
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopBar(state),
        ),

        // Bottom controls
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoCallControls(
            isMicrophoneMuted: state.isMicrophoneMuted,
            isCameraMuted: state.isCameraMuted,
<<<<<<< HEAD
=======
            isScreenSharing: state.isScreenSharing,
>>>>>>> feature/improve-agora-service
            onToggleMicrophone: () {
              context.read<VideoCallBloc>().add(const ToggleMicrophone());
            },
            onToggleCamera: () {
              context.read<VideoCallBloc>().add(const ToggleCamera());
            },
<<<<<<< HEAD
=======
            onToggleScreenShare: () {
              context.read<VideoCallBloc>().add(const ToggleScreenShare());
            },
>>>>>>> feature/improve-agora-service
            onSwitchCamera: () {
              context.read<VideoCallBloc>().add(const SwitchCamera());
            },
            onEndCall: () {
              context.read<VideoCallBloc>().add(const LeaveChannel());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRemoteVideo(int uid) {
    if (_agoraService.engine == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    
    return SizedBox.expand(
      child: AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _agoraService.engine!,
          canvas: VideoCanvas(uid: uid),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      ),
    );
  }

  Widget _buildLocalVideoPreview() {
    if (_agoraService.engine == null) {
      return Container(
        width: 120,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.black54,
        ),
        child: const Center(
          child: Icon(Icons.person, color: Colors.white54, size: 40),
        ),
      );
    }
    
    return Container(
      width: 120,
      height: 160,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _agoraService.engine!,
            canvas: const VideoCanvas(uid: 0),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingView() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: Colors.white54),
            SizedBox(height: 16),
            Text(
              AppStrings.waitingForOthers,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(VideoCallConnected state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.video_call, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.channelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${state.remoteUsers.length + 1} ${state.remoteUsers.isEmpty ? AppStrings.participant : AppStrings.participants}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
