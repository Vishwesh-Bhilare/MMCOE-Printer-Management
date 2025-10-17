import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../core/constants/app_constants.dart';
import 'printer_dashboard_screen.dart';

class PrinterLoginScreen extends StatefulWidget {
  const PrinterLoginScreen({super.key});

  @override
  State<PrinterLoginScreen> createState() => _PrinterLoginScreenState();
}

class _PrinterLoginScreenState extends State<PrinterLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _printerIdController = TextEditingController();
  final _passwordController = TextEditingController();

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

              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.print,
                      size: 80,
                      color: isDark ? Colors.tealAccent : Colors.indigo,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${AppConstants.appName} - Printer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Text(
                      'Staff Login',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Error Message
              if (authProvider.error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.red.withOpacity(0.15) : Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: TextStyle(
                        color: isDark ? Colors.red[200] : Colors.red[700]),
                  ),
                ),

              const SizedBox(height: 16),

              // Login Form
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : Colors.grey[100],
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
                      TextFormField(
                        controller: _printerIdController,
                        style: TextStyle(color: isDark ? Colors.white : null),
                        decoration: InputDecoration(
                          labelText: 'Printer ID',
                          prefixIcon: const Icon(Icons.business),
                          hintText: 'printer',
                          labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter printer ID';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : null),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock),
                          hintText: 'print123',
                          labelStyle: TextStyle(
                              color: isDark ? Colors.white70 : Colors.black54),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Login Button
                      if (authProvider.isLoading)
                        const CircularProgressIndicator()
                      else
                        SizedBox(
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
                              if (_formKey.currentState!.validate()) {
                                final success = await authProvider.printerLogin(
                                  _printerIdController.text.trim(),
                                  _passwordController.text.trim(),
                                );

                                if (success && context.mounted) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const PrinterDashboardScreen(),
                                    ),
                                  );
                                }
                              }
                            },
                            child: const Text(
                              'LOGIN AS PRINTER',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Back to student login
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back,
                            color: isDark ? Colors.tealAccent : Colors.indigo),
                        label: Text(
                          'Back to Student Login',
                          style: TextStyle(
                            color: isDark ? Colors.tealAccent : Colors.indigo,
                            fontWeight: FontWeight.w600,
                          ),
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

  @override
  void dispose() {
    _printerIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
