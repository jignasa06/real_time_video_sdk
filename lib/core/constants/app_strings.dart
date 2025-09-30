class AppStrings {
  static const String signInToContinue = 'Sign in to continue';
  static const String email = 'Email';
  static const String enterYourEmail = 'Enter your email';
  static const String password = 'Password';
  static const String enterYourPassword = 'Enter your password';
  static const String login = 'Login';
  static const String testCredentials = 'Test Credentials';
  static const String users = 'Users';
  static const String usersPage = 'Users Page';
  static const String videoCall = 'Video Call';
  static const String videoCallPage = 'Video Call Page';
  static const String pageNotFound = 'Page not found';
  
  static const String emailRequired = 'Email is required';
  static const String validEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String phoneRequired = 'Phone number is required';
  static const String validPhone = 'Please enter a valid phone number';
  static const String nameRequired = 'Name is required';
  static const String nameMinLength = 'Name must be at least 2 characters';
  
  static String fieldRequired(String fieldName) => '$fieldName is required';
  static String emailLabel(String email) => 'Email: $email';
  static String passwordLabel(String password) => 'Password: $password';
}
