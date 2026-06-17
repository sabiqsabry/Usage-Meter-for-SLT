import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  // On Android the client is matched by package name + SHA-1 fingerprint
  // registered in Google Cloud Console — no clientId needed in code.
  // On iOS we pass the explicit iOS client ID.
  // serverClientId makes Google issue a token with MySLT's web client as
  // the audience so MySLT's LoginExternal endpoint can verify it.
  final _googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? kGoogleIosClientId
        : null,
    serverClientId: kMySltGoogleClientId,
    scopes: ['email', 'profile'],
  );

  final _api = ApiClient();

  /// Launches the native Google Sign-In flow (opens in Safari on iOS,
  /// which Google approves), then exchanges the token with MySLT.
  /// Returns the MySLT access token on success.
  Future<String> signIn() async {
    // Sign out any previous session so the account picker always shows.
    await _googleSignIn.signOut();

    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw Exception('Google Sign-In was cancelled.');
    }

    final auth = await account.authentication;

    // Prefer the server-audience ID token; fall back to the standard one.
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
          'Could not retrieve a Google ID token. '
          'Make sure the iOS Client ID is configured correctly.');
    }

    final result = await _api.loginExternal(
      idToken: idToken,
      email: account.email,
    );

    return result['accessToken'] as String;
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
