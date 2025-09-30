class AppConstants {
  static const String appName = 'Video Call';
  static const String appVersion = '1.0.0';

  static const String baseUrl = 'https://reqres.in/api';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';

  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  static const String mockEmail = 'eve.holt@reqres.in';
  static const String mockPassword = 'cityslicka';
  
  // Agora Configuration
  static const String agoraAppId = '6ea7e8a98ace40a096a12ded8417ba3d'; // Replace with your Agora App ID
  static const String agoraToken = ''; // Optional: Add token for production
}
