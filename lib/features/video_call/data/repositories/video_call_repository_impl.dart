import 'package:dartz/dartz.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/repositories/video_call_repository.dart';
import '../datasources/agora_service.dart';

class VideoCallRepositoryImpl implements VideoCallRepository {
  final AgoraService agoraService;

  VideoCallRepositoryImpl({required this.agoraService});

  @override
  Future<Either<Failure, void>> initializeEngine() async {
    try {
      await agoraService.initialize();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToInitializeVideoEngine}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    try {
      await agoraService.joinChannel(
        channelName: channelName,
        uid: uid,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToJoinChannel}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> leaveChannel() async {
    try {
      await agoraService.leaveChannel();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToLeaveChannel}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleMicrophone() async {
    try {
      await agoraService.toggleMicrophone();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToToggleMicrophone}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCamera() async {
    try {
      await agoraService.toggleCamera();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToToggleCamera}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> switchCamera() async {
    try {
      await agoraService.switchCamera();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToSwitchCamera}: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> dispose() async {
    try {
      await agoraService.dispose();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('${AppStrings.failedToDisposeEngine}: ${e.toString()}'));
    }
  }
}
