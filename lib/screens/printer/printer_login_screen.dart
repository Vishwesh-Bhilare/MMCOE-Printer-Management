import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
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

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              // Header
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.print,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${AppConstants.appName} - Printer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Staff Login',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
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
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Text(
                    authProvider.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),

              const SizedBox(height: 16),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _printerIdController,
                      decoration: const InputDecoration(
                        labelText: 'Printer ID',
                        prefixIcon: Icon(Icons.business),
                        hintText: 'printer',
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
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        hintText: 'print123',
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final success = await authProvider.printerLogin(
                                _printerIdController.text,
                                _passwordController.text,
                              );

                              if (success && context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PrinterDashboardScreen(),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('LOGIN AS PRINTER'),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Back to student login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('← Back to Student Login'),
                    ),
                  ],
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