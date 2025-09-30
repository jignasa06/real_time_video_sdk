import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/video_call/presentation/pages/video_call_page.dart' as video_call;
import '../../features/video_call/presentation/bloc/video_call_bloc.dart';
import '../di/injection.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      context.read<AuthBloc>().add(const CheckAuthStatus());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.usersRoute);
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.loginRoute);
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.video_call_rounded,
                size: 100,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

class UsersPage extends StatelessWidget {
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.users),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutRequested());
              context.go(AppRoutes.loginRoute);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.video_call_rounded,
              size: 100,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              AppStrings.readyToStartVideoCall,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                final channelName = 'test-room-${DateTime.now().millisecondsSinceEpoch}';
                final uid = DateTime.now().millisecondsSinceEpoch % 100000;
                context.go('${AppRoutes.videoCallRoute}?channel=$channelName&uid=$uid');
              },
              icon: const Icon(Icons.videocam),
              label: const Text(AppStrings.startVideoCall),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                _showJoinRoomDialog(context);
              },
              icon: const Icon(Icons.meeting_room),
              label: const Text(AppStrings.joinExistingRoom),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinRoomDialog(BuildContext context) {
    final channelController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.joinRoom),
        content: TextField(
          controller: channelController,
          decoration: const InputDecoration(
            labelText: AppStrings.roomName,
            hintText: AppStrings.enterRoomName,
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (channelController.text.isNotEmpty) {
                final uid = DateTime.now().millisecondsSinceEpoch % 100000;
                Navigator.pop(dialogContext);
                context.go('${AppRoutes.videoCallRoute}?channel=${channelController.text}&uid=$uid');
              }
            },
            child: const Text(AppStrings.join),
          ),
        ],
      ),
    );
  }
}

class VideoCallPage extends StatelessWidget {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.videoCall)),
      body: const Center(
        child: Text(AppStrings.videoCallPage),
      ),
    );
  }
}

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splashRoute,
    routes: [
      GoRoute(
        path: AppRoutes.splashRoute,
        name: AppRoutes.splashRouteName,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.loginRoute,
        name: AppRoutes.loginRouteName,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.usersRoute,
        name: AppRoutes.usersRouteName,
        builder: (context, state) => const UsersPage(),
      ),
      GoRoute(
        path: AppRoutes.videoCallRoute,
        name: AppRoutes.videoCallRouteName,
        builder: (context, state) {
          final channelName = state.uri.queryParameters['channel'] ?? 'test-room';
          final uid = int.tryParse(state.uri.queryParameters['uid'] ?? '0') ?? 0;
          
          return BlocProvider(
            create: (context) => getIt<VideoCallBloc>(),
            child: video_call.VideoCallPage(
              channelName: channelName,
              uid: uid,
            ),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('${AppStrings.pageNotFound}: ${state.uri}'),
      ),
    ),
  );
}
