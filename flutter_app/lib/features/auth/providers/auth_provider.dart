import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../services/google_sign_in_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient();
  final _storage = SecureStorage();
  final _google = GoogleSignInService();

  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> checkAuth() async {
    final token = await _storage.getAccessToken();
    _status =
        token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.login(username, password);
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.statusCode == 401 || e.statusCode == 403
          ? 'Invalid credentials. Please check your email and password.'
          : e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _google.signIn();
      _status = AuthStatus.authenticated;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('cancelled')) {
        _errorMessage = null; // silent cancel, no error shown
      } else {
        _errorMessage = msg.replaceFirst('Exception: ', '');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Called after a successful WebView-based login where tokens are already
  /// persisted in SecureStorage by the WebViewLoginScreen.
  void markAuthenticated() {
    _errorMessage = null;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    await _api.logout();
    await _google.signOut();
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
