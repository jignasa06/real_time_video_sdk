import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate credentials (mock authentication)
      if (email != 'eve.holt@reqres.in' || password != 'cityslicka') {
        return const Left(ValidationFailure('Invalid email or password'));
      }

      // Generate mock token
      const mockToken = 'QpwL5tke4Pnpja7X4';
      
      // Cache token
      await localDataSource.cacheAuthToken(mockToken);

      // Create mock user model
      final mockUserModel = UserModel(
        id: 2,
        email: email,
        firstName: 'Eve',
        lastName: 'Holt',
        avatar: 'https://reqres.in/img/faces/2-image.jpg',
      );
      
      // Cache user data
      await localDataSource.cacheUserData(mockUserModel);

      return Right(mockUserModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Login failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearAuthData();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to logout: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getUserData();
      return Right(user?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(CacheFailure('Failed to check login status: ${e.toString()}'));
    }
  }
}
