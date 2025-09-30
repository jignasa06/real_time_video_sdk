import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';

abstract class VideoCallRepository {
  Future<Either<Failure, void>> initializeEngine();
  Future<Either<Failure, void>> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  });
  Future<Either<Failure, void>> leaveChannel();
  Future<Either<Failure, void>> toggleMicrophone();
  Future<Either<Failure, void>> toggleCamera();
  Future<Either<Failure, void>> switchCamera();
  Future<Either<Failure, void>> dispose();
}
