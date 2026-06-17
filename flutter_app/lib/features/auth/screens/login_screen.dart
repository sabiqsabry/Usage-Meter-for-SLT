import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final auth = context.read<AuthProvider>();
    await auth.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    Colors.blue.shade900.withValues(alpha: 0.8),
                    Colors.cyan.shade900.withValues(alpha: 0.8),
                  ]
                : [
                    const Color(0xFF0057B8),
                    const Color(0xFF00AEEF),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(context),
                    const SizedBox(height: 40),
                    _buildLoginCard(context, cs, isDark),
                    const SizedBox(height: 24),
                    _buildDisclaimer(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.speed_rounded, size: 48, color: Colors.white),
        const SizedBox(height: 12),
        Text(
          'Usage Meter for SLT',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Monitor your SLT broadband usage across all your devices',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard(
      BuildContext context, ColorScheme cs, bool isDark) {
    return Card(
      elevation: 8,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, size: 18, color: cs.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodySmall,
                        children: const [
                          TextSpan(
                            text: 'Login with your MySLT credentials',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text:
                                '\nUse the same email & password as myslt.slt.lk',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Email
            Text('Email',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: 'Enter your email',
              ),
            ),
            const SizedBox(height: 16),

            // Password
            Text('Password',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              onSubmitted: (_) => _login(),
              decoration: InputDecoration(
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Error
            Consumer<AuthProvider>(
              builder: (_, auth, __) {
                if (auth.errorMessage == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_rounded,
                          color: Colors.red, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          auth.errorMessage!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Login button
            Consumer<AuthProvider>(
              builder: (_, auth, __) => FilledButton(
                onPressed: auth.isLoading ||
                        _emailController.text.isEmpty ||
                        _passwordController.text.isEmpty
                    ? null
                    : _login,
                child: auth.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),

            const SizedBox(height: 16),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),

            const SizedBox(height: 16),

            // Google Sign-In button
            Consumer<AuthProvider>(
              builder: (_, auth, __) => OutlinedButton(
                onPressed: auth.isLoading ? null : _signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google "G" logo
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: const _GoogleLogo(),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Continue with Google',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    await context.read<AuthProvider>().signInWithGoogle();
  }

  Widget _buildDisclaimer(BuildContext context) {
    return Column(
      children: [
        Text(
          'Usage Meter for SLT is an independent app and is not affiliated with or endorsed by SLT Mobitel.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'No personal data is collected or stored externally.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Renders the Google "G" multicolour logo using a CustomPainter so we don't
/// need an external image asset.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleLogoPainter(),
      size: const Size(20, 20),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    // Blue arc (right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -0.52, 3.14, true, paint);

    // Green arc (bottom-right)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        0.52, 1.05, true, paint);

    // Yellow arc (bottom-left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        2.09, 1.05, true, paint);

    // Red arc (top-left)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        3.14, 1.05, true, paint);

    // White centre cutout
    paint.color = Colors.white;
    canvas.drawCircle(center, r * 0.6, paint);

    // Blue "G" bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.18, r, r * 0.36),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
