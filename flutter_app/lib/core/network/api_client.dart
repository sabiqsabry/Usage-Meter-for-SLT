import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? rawResponse;

  ApiException(this.message, {this.statusCode, this.rawResponse});

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = SecureStorage();
  final _client = http.Client();

  static const _timeout = Duration(seconds: 60);

  Map<String, String> _baseHeaders({bool urlEncoded = false}) => {
        'X-Ibm-Client-Id': kClientId,
        if (urlEncoded)
          'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
      };

  Map<String, String> _authHeaders(String token) => {
        ..._baseHeaders(),
        'authorization': 'bearer $token',
      };

  String _percentEncode(String value) => Uri.encodeQueryComponent(value);

  String _toInternationalFormat(String number) {
    final cleaned = number.replaceAll(' ', '').replaceAll('-', '');
    if (RegExp(r'[a-zA-Z]').hasMatch(cleaned)) return cleaned;
    if (cleaned.startsWith('0')) return '94${cleaned.substring(1)}';
    if (cleaned.startsWith('94')) return cleaned;
    return '94$cleaned';
  }

  /// Sign in via an external provider (e.g. Google).
  /// [idToken] is the Google ID token returned by google_sign_in.
  /// [email] is the user's email, saved locally for future API calls.
  Future<Map<String, dynamic>> loginExternal({
    required String idToken,
    required String email,
  }) async {
    final body = 'provider=Google'
        '&externalAccessToken=${_percentEncode(idToken)}'
        '&externalAccessToken2='
        '&firebaseId=123123123'
        '&appVersion=1'
        '&osType=iOS'
        '&channelID=WEB';

    final response = await _client
        .post(
          Uri.parse(ApiEndpoints.loginExternal),
          headers: _baseHeaders(urlEncoded: true),
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.saveAccessToken(data['accessToken'] as String);
      await _storage.saveRefreshToken(data['refreshToken'] as String);
      await _storage.saveUsername(email);
      return data;
    }

    throw ApiException(
      'Google login failed (${response.statusCode})',
      statusCode: response.statusCode,
      rawResponse: response.body,
    );
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final body = 'username=${_percentEncode(username)}'
        '&password=${_percentEncode(password)}'
        '&channelID=WEB';

    final response = await _client
        .post(
          Uri.parse(ApiEndpoints.login),
          headers: _baseHeaders(urlEncoded: true),
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.saveAccessToken(data['accessToken'] as String);
      await _storage.saveRefreshToken(data['refreshToken'] as String);
      await _storage.saveUsername(username);
      return data;
    }

    throw ApiException(
      'Login failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> refreshToken() async {
    final storedRefresh = await _storage.getRefreshToken();
    final storedUsername = await _storage.getUsername();

    if (storedRefresh == null || storedUsername == null) {
      throw ApiException('No credentials stored', statusCode: 401);
    }

    final body = 'username=${_percentEncode(storedUsername)}'
        '&refreshToken=${_percentEncode(storedRefresh)}'
        '&channelID=WEB';

    final response = await _client
        .post(
          Uri.parse(ApiEndpoints.refreshToken),
          headers: _baseHeaders(urlEncoded: true),
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storage.saveAccessToken(data['accessToken'] as String);
      await _storage.saveRefreshToken(data['refreshToken'] as String);
      return data;
    }

    throw ApiException(
      'Token refresh failed (${response.statusCode})',
      statusCode: response.statusCode,
    );
  }

  Future<Map<String, dynamic>> _get(String url) async {
    final token = await _storage.getAccessToken();
    if (token == null) throw ApiException('Not authenticated', statusCode: 401);

    final response = await _client
        .get(Uri.parse(url), headers: _authHeaders(token))
        .timeout(_timeout);

    if (response.statusCode == 401 || response.statusCode == 403) {
      // Attempt token refresh then retry once
      try {
        await refreshToken();
        final newToken = await _storage.getAccessToken();
        final retried = await _client
            .get(Uri.parse(url), headers: _authHeaders(newToken!))
            .timeout(_timeout);
        if (retried.statusCode == 200) {
          return jsonDecode(retried.body) as Map<String, dynamic>;
        }
        throw ApiException(
          'Request failed after token refresh (${retried.statusCode})',
          statusCode: retried.statusCode,
        );
      } catch (_) {
        await logout();
        throw ApiException('Session expired. Please log in again.', statusCode: 401);
      }
    }

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        throw ApiException(
          'Failed to parse response',
          rawResponse: response.body,
        );
      }
    }

    throw ApiException(
      'Request failed (${response.statusCode})',
      statusCode: response.statusCode,
      rawResponse: response.body,
    );
  }

  Future<List<dynamic>> fetchAccounts() async {
    final username = await _storage.getUsername();
    if (username == null) throw ApiException('No username stored');
    final data = await _get(ApiEndpoints.accountDetail(username));
    return (data['dataBundle'] as List?) ?? [];
  }

  Future<Map<String, dynamic>?> fetchServiceDetails(String telephoneNo) async {
    final data = await _get(ApiEndpoints.serviceDetail(telephoneNo));
    return data['dataBundle'] as Map<String, dynamic>?;
  }

  Future<Map<String, dynamic>?> fetchUsageSummary(String subscriberId) async {
    final intlNumber = _toInternationalFormat(subscriberId);
    final data = await _get(ApiEndpoints.usageSummary(intlNumber));
    return data['dataBundle'] as Map<String, dynamic>?;
  }

  Future<List<dynamic>> fetchVasBundles(String subscriberId) async {
    final intlNumber = _toInternationalFormat(subscriberId);
    final data = await _get(ApiEndpoints.vasBundles(intlNumber));
    final bundle = data['dataBundle'] as Map<String, dynamic>?;
    return (bundle?['usageDetails'] as List?) ?? [];
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }
}
