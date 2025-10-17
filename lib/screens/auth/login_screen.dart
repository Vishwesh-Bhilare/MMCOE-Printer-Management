import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import '../student/home_screen.dart';
import '../printer/printer_login_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isSignup = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: isDark ? Colors.white : Colors.indigo,
            ),
            tooltip: "Toggle Theme",
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.print,
                        size: 80,
                        color: isDark ? Colors.tealAccent : Colors.indigo),
                    const SizedBox(height: 16),
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      AppConstants.universityName,
                      style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    if (!_isSignup)
                      const Text(
                        'Hint: Your student ID is the first part of your email before @mmcoe.edu.in',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (_isSignup) ...[
                        _buildField(_nameController, "Full Name",
                            Icons.person, isDark),
                        const SizedBox(height: 16),
                        _buildField(_emailController, "College Email",
                            Icons.email, isDark, email: true),
                        const SizedBox(height: 16),
                      ],
                      _buildField(_studentIdController, "Student ID",
                          Icons.badge, isDark),
                      const SizedBox(height: 16),
                      _buildField(_phoneController, "Phone Number", Icons.phone,
                          isDark,
                          phone: true),
                      const SizedBox(height: 16),
                      _buildField(_passwordController, "Password", Icons.lock,
                          isDark,
                          password: true),
                      const SizedBox(height: 24),

                      if (authProvider.isLoading)
                        const CircularProgressIndicator()
                      else
                        _buildMainButton(isDark, authProvider),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () =>
                            setState(() => _isSignup = !_isSignup),
                        child: Text(
                          _isSignup
                              ? 'Already have an account? Login'
                              : 'Don\'t have an account? Sign up',
                          style: TextStyle(
                              color: isDark
                                  ? Colors.tealAccent
                                  : Colors.indigo),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextButton.icon(
                        icon: const Icon(Icons.mail_outline),
                        label: const Text("For issues, contact us"),
                        onPressed: _launchEmail,
                        style: TextButton.styleFrom(
                          foregroundColor:
                          isDark ? Colors.tealAccent : Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Divider(
                          color: isDark ? Colors.white24 : Colors.grey[300]),
                      const SizedBox(height: 10),

                      OutlinedButton.icon(
                        icon: Icon(Icons.print,
                            color:
                            isDark ? Colors.tealAccent : Colors.indigo),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const PrinterLoginScreen()),
                          );
                        },
                        label: Text('LOGIN AS PRINTER',
                            style: TextStyle(
                                color: isDark
                                    ? Colors.tealAccent
                                    : Colors.indigo,
                                fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color:
                              isDark ? Colors.tealAccent : Colors.indigo),
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      IconData icon, bool isDark,
      {bool email = false, bool phone = false, bool password = false}) {
    return TextFormField(
      controller: controller,
      obscureText: password,
      keyboardType:
      phone ? TextInputType.phone : (email ? TextInputType.emailAddress : null),
      style: TextStyle(color: isDark ? Colors.white : null),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        labelStyle:
        TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter $label';
        if (email && !value.endsWith('@mmcoe.edu.in')) {
          return 'Email must end with @mmcoe.edu.in';
        }
        if (phone && value.length < 10) return 'Enter valid phone number';
        if (password && value.length < 6) return 'Password too short';
        return null;
      },
    );
  }

  Widget _buildMainButton(bool isDark, AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isDark ? Colors.tealAccent[700] : Colors.indigo,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;

          bool success;
          if (_isSignup) {
            success = await auth.signup(
              '${_studentIdController.text.trim()}@mmcoe.edu.in',
              _passwordController.text.trim(),
              _nameController.text.trim(),
              _phoneController.text.trim(),
              _studentIdController.text.trim(),
            );
          } else {
            final email =
                '${_studentIdController.text.trim()}@mmcoe.edu.in';
            success = await auth.login(
              email,
              _passwordController.text.trim(),
              phone: _phoneController.text.trim(),
            );
          }

          if (!success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(auth.error ?? 'Login/Signup failed'),
              behavior: SnackBarBehavior.floating,
            ));
          }

          if (success && context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          }
        },
        child: Text(
          _isSignup ? 'SIGN UP' : 'LOGIN',
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'bhilarevishwesh@gmail.com',
      query: Uri.encodeFull(
        'subject=App Support: MMCOE Printer Management',
      ),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Opening email app...'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Unable to open email app.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
