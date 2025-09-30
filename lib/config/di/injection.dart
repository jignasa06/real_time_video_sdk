import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/network/dio_client.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/video_call/data/datasources/agora_service.dart';
import '../../features/video_call/data/repositories/video_call_repository_impl.dart';
import '../../features/video_call/domain/repositories/video_call_repository.dart';
import '../../features/video_call/presentation/bloc/video_call_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  
  // Core
  getIt.registerLazySingleton<DioClient>(() => DioClient());
  
  // Auth Feature
  // Data sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSource(getIt<SharedPreferences>()),
  );
  
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>().dio),
  );
  
  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );
  
  // Use cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );
  
  // BLoC
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );
  
  // Video Call Feature
  // Data sources
  getIt.registerLazySingleton<AgoraService>(() => AgoraService());
  
  // Repository
  getIt.registerLazySingleton<VideoCallRepository>(
    () => VideoCallRepositoryImpl(agoraService: getIt<AgoraService>()),
  );
  
  // BLoC
  getIt.registerFactory<VideoCallBloc>(
    () => VideoCallBloc(repository: getIt<VideoCallRepository>()),
  );
}
