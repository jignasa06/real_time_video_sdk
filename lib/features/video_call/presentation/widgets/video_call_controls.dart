import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class VideoCallControls extends StatelessWidget {
  final bool isMicrophoneMuted;
  final bool isCameraMuted;
<<<<<<< HEAD
  final VoidCallback onToggleMicrophone;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
=======
  final bool isScreenSharing;
  final VoidCallback onToggleMicrophone;
  final VoidCallback onToggleCamera;
  final VoidCallback onSwitchCamera;
  final VoidCallback onToggleScreenShare;
>>>>>>> feature/improve-agora-service
  final VoidCallback onEndCall;

  const VideoCallControls({
    super.key,
    required this.isMicrophoneMuted,
    required this.isCameraMuted,
<<<<<<< HEAD
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onSwitchCamera,
=======
    required this.isScreenSharing,
    required this.onToggleMicrophone,
    required this.onToggleCamera,
    required this.onSwitchCamera,
    required this.onToggleScreenShare,
>>>>>>> feature/improve-agora-service
    required this.onEndCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withOpacity(0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: isMicrophoneMuted ? Icons.mic_off : Icons.mic,
            label: AppStrings.mic,
            onPressed: onToggleMicrophone,
            isActive: !isMicrophoneMuted,
          ),
          _buildControlButton(
            icon: isCameraMuted ? Icons.videocam_off : Icons.videocam,
            label: AppStrings.camera,
            onPressed: onToggleCamera,
            isActive: !isCameraMuted,
          ),
          _buildControlButton(
<<<<<<< HEAD
=======
            icon: Icons.screen_share,
            label: AppStrings.screenShare,
            onPressed: onToggleScreenShare,
            isActive: isScreenSharing,
          ),
          _buildControlButton(
>>>>>>> feature/improve-agora-service
            icon: Icons.flip_camera_ios,
            label: AppStrings.flip,
            onPressed: onSwitchCamera,
            isActive: true,
          ),
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isActive,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEndCallButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            onTap: onEndCall,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.call_end,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.end,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
