import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

part 'auth_remote_datasource.g.dart';

@RestApi()
abstract class AuthRemoteDataSource {
  factory AuthRemoteDataSource(Dio dio, {String baseUrl}) = _AuthRemoteDataSource;

  @POST('/login')
  Future<LoginResponseModel> login(@Body() LoginRequestModel request);

  @GET('/users/2')
  Future<UserResponse> getUserData();
}

// Response wrapper for user data
class UserResponse {
  final UserModel data;

  UserResponse({required this.data});

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      data: UserModel.fromJson(json['data'] as Map<String, dynamic>),
    );
  }
}
