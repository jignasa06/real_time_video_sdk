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
  
  // Video Call
  static const String startVideoCall = 'Start Video Call';
  static const String joinExistingRoom = 'Join Existing Room';
  static const String readyToStartVideoCall = 'Ready to start a video call?';
  static const String joinRoom = 'Join Room';
  static const String roomName = 'Room Name';
  static const String enterRoomName = 'Enter room name';
  static const String cancel = 'Cancel';
  static const String join = 'Join';
  static const String connecting = 'Connecting...';
  static const String callEnded = 'Call Ended';
  static const String goBack = 'Go Back';
  static const String waitingForOthers = 'Waiting for others to join...';
  static const String mic = 'Mic';
  static const String camera = 'Camera';
  static const String flip = 'Flip';
  static const String end = 'End';
  static const String participant = 'participant';
  static const String participants = 'participants';
  
  // Agora Error Messages
  static const String invalidAgoraAppId = 'Invalid Agora App ID. Please configure your App ID in app_constants.dart';
  static const String failedToInitializeVideoEngine = 'Failed to initialize video engine';
  static const String permissionsPermanentlyDenied = 'Permissions permanently denied. Please enable Camera and Microphone in app settings.';
  static const String permissionsDenied = 'Camera or microphone permission denied. Please grant permissions to use video call.';
  static const String failedToGetPermissions = 'Failed to get required permissions';
  static const String engineNotInitialized = 'Engine not initialized';
  static const String failedToJoinVideoCall = 'Failed to join video call';
  static const String failedToLeaveVideoCall = 'Failed to leave video call';
  static const String failedToToggleMicrophone = 'Failed to toggle microphone';
  static const String failedToToggleCamera = 'Failed to toggle camera';
  static const String failedToSwitchCamera = 'Failed to switch camera';
  static const String failedToJoinChannel = 'Failed to join channel';
  static const String failedToLeaveChannel = 'Failed to leave channel';
  static const String failedToDisposeEngine = 'Failed to dispose engine';
  static const String failedToStartScreenShare = 'Failed to start screen share';
  static const String failedToStopScreenShare = 'Failed to stop screen share';
  static const String screenShare = 'Screen';
  static const String sharingScreen = 'Sharing Screen...';
  
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
