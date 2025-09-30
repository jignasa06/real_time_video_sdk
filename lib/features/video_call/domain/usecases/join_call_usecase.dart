import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/video_call_repository.dart';

class JoinCallUseCase {
  final VideoCallRepository repository;

  JoinCallUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    return await repository.joinChannel(
      channelName: channelName,
      uid: uid,
      token: token,
    );
  }
}
