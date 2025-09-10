import "package:shared_preferences/shared_preferences.dart";

class AuthService {
  factory AuthService() => _instance;
  AuthService._internal();

  static final AuthService _instance = AuthService._internal();
  static const String _guestModeKey = 'guest_mode';
  static const String _userIdKey = 'user_id';

  bool _isGuestMode = true;
  String _guestUserId = 'guest_user';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuestMode = prefs.getBool(_guestModeKey) ?? true;
    _guestUserId = prefs.getString(_userIdKey) ?? 'guest_user';
  }

  Future<bool> signInAsGuest() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuestMode = true;
      _guestUserId = 'guest_user_${DateTime.now().millisecondsSinceEpoch}';
      
      await prefs.setBool(_guestModeKey, true);
      await prefs.setString(_userIdKey, _guestUserId);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  bool isAuthenticated() {
    return _isGuestMode;
  }

  String? getUserId() {
    return _isGuestMode ? _guestUserId : null;
  }

  String? getUserDisplayName() {
    return _isGuestMode ? 'Guest User' : null;
  }

  String? getUserEmail() {
    return _isGuestMode ? 'guest@local.app' : null;
  }

  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestModeKey);
      await prefs.remove(_userIdKey);
      _isGuestMode = false;
      _guestUserId = '';
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> deleteAccount() async {
    await signOut();
  }
}