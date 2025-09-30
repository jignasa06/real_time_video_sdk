class ApiEndpoints {
  // Auth
  static const String login = '/login';
  static const String register = '/register';
  
  // Users
  static const String users = '/users';
  static String userById(int id) => '/users/$id';
}
