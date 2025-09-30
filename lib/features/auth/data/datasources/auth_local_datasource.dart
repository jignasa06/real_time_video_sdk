import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'dart:convert';

class AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSource(this.sharedPreferences);

  Future<void> cacheAuthToken(String token) async {
    await sharedPreferences.setString(AppConstants.authTokenKey, token);
  }

  Future<String?> getAuthToken() async {
    return sharedPreferences.getString(AppConstants.authTokenKey);
  }

  Future<void> cacheUserData(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.userDataKey,
      json.encode(user.toJson()),
    );
  }

  Future<UserModel?> getUserData() async {
    final jsonString = sharedPreferences.getString(AppConstants.userDataKey);
    if (jsonString != null) {
      return UserModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  Future<void> clearAuthData() async {
    await sharedPreferences.remove(AppConstants.authTokenKey);
    await sharedPreferences.remove(AppConstants.userDataKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }
}
