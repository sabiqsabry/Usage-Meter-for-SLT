import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  // iOS uses explicit client ID; Android is matched by package name + SHA-1.
  // We do NOT set serverClientId because Google blocks cross-project token
  // requests. Instead we send our own ID token to MySLT — their backend
  // verifies the signature and extracts the email without checking the audience.
  final _googleSignIn = GoogleSignIn(
    clientId: defaultTargetPlatform == TargetPlatform.iOS
        ? kGoogleIosClientId
        : null,
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

    // Try ID token first, fall back to access token.
    // MySLT's backend verifies the Google signature and extracts the email —
    // the token just needs to be a valid Google-issued credential.
    final idToken = auth.idToken;
    final accessToken = auth.accessToken;

    final tokenToSend = (idToken != null && idToken.isNotEmpty)
        ? idToken
        : accessToken;

    if (tokenToSend == null || tokenToSend.isEmpty) {
      throw Exception(
          'Could not retrieve a Google token. '
          'Make sure the iOS Client ID is configured correctly in '
          'Google Cloud Console.');
    }

    final result = await _api.loginExternal(
      idToken: tokenToSend,
      email: account.email,
    );

    return result['accessToken'] as String;
  }

  Future<void> signOut() => _googleSignIn.signOut();
}
