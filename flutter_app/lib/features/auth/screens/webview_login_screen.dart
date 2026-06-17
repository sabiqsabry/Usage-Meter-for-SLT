import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../core/storage/secure_storage.dart';

/// Loads the real myslt.slt.lk login page inside a WebView.
/// Supports all login methods available on the portal, including Google Sign-In.
/// After a successful login the portal stores tokens in localStorage —
/// we detect that and hand them back to the caller.
class WebViewLoginScreen extends StatefulWidget {
  /// Called when tokens have been successfully extracted from the portal.
  final void Function(String accessToken, String refreshToken, String username)
      onLoginSuccess;

  const WebViewLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<WebViewLoginScreen> createState() => _WebViewLoginScreenState();
}

class _WebViewLoginScreenState extends State<WebViewLoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  // JavaScript injected after every page navigation.
  // It polls localStorage for the MySLT tokens and — if found — sends them
  // back to Flutter via the TokenChannel JavaScriptChannel.
  static const String _tokenPollerJs = r'''
    (function startPolling() {
      var maxAttempts = 120;   // poll for up to ~60 s
      var attempts = 0;

      function tryExtract() {
        attempts++;
        if (attempts > maxAttempts) return;

        var at  = localStorage.getItem('accessToken')
               || localStorage.getItem('access_token')
               || localStorage.getItem('token');
        var rt  = localStorage.getItem('refreshToken')
               || localStorage.getItem('refresh_token');
        var usr = localStorage.getItem('username')
               || localStorage.getItem('email')
               || localStorage.getItem('user');

        if (at && at.length > 10) {
          TokenChannel.postMessage(JSON.stringify({
            accessToken:  at,
            refreshToken: rt  || '',
            username:     usr || ''
          }));
          return;   // stop polling once found
        }
        setTimeout(tryExtract, 500);
      }

      tryExtract();
    })();
  ''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _isLoading = true),
        onPageFinished: (url) {
          setState(() => _isLoading = false);
          // Inject token poller on every page load so we catch the moment
          // the portal writes the tokens regardless of how login completed.
          _controller.runJavaScript(_tokenPollerJs);
        },
        onWebResourceError: (err) {
          if (err.isForMainFrame == true) {
            setState(() {
              _error = 'Could not load the MySLT portal (${err.description}).';
              _isLoading = false;
            });
          }
        },
      ))
      ..addJavaScriptChannel(
        'TokenChannel',
        onMessageReceived: _onTokenReceived,
      )
      ..loadRequest(Uri.parse('https://myslt.slt.lk'));
  }

  void _onTokenReceived(JavaScriptMessage message) async {
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final accessToken = data['accessToken'] as String? ?? '';
      final refreshToken = data['refreshToken'] as String? ?? '';
      final username = data['username'] as String? ?? '';

      if (accessToken.isEmpty) return;

      // Persist tokens locally using the same keys as the API client.
      final storage = SecureStorage();
      await storage.saveAccessToken(accessToken);
      if (refreshToken.isNotEmpty) await storage.saveRefreshToken(refreshToken);
      if (username.isNotEmpty) await storage.saveUsername(username);

      if (mounted) {
        widget.onLoginSuccess(accessToken, refreshToken, username);
      }
    } catch (_) {
      // Malformed message — ignore and keep polling.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in to MySLT'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _controller.reload(),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48,
                        color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 12),
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() => _error = null);
                        _controller.loadRequest(
                            Uri.parse('https://myslt.slt.lk'));
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            const LinearProgressIndicator(minHeight: 3),
        ],
      ),
    );
  }
}
