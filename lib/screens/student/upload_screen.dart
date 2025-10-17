import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdfx/pdfx.dart';

import 'package:student_printing_system/providers/auth_provider.dart';
import 'package:student_printing_system/providers/theme_provider.dart';
import 'package:student_printing_system/providers/print_provider.dart';
import 'package:student_printing_system/models/print_preferences_model.dart';
import 'package:student_printing_system/models/user_model.dart';
import 'package:student_printing_system/screens/settings/settings_screen.dart';
import 'package:student_printing_system/screens/student/upload_success_screen.dart';
import 'package:student_printing_system/screens/student/upload_failed_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  bool _isColor = false;
  bool _isDuplex = true;
  int _copies = 1;
  int _pages = 1;
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation =
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final printProvider = Provider.of<PrintProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo,
        title: const Text(
          'Upload Document',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () => theme.toggleTheme(),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🧾 Title (no Hero)
              Text(
                'Upload Document',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.indigo,
                ),
              ),
              const SizedBox(height: 20),
              _buildFileCard(isDark),
              const SizedBox(height: 16),
              _buildPreferences(isDark),
              const SizedBox(height: 20),
              if (_isUploading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      'Uploading... ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text(
                      'SUBMIT REQUEST',
                      style: TextStyle(fontFamily: 'Poppins'),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor:
                      isDark ? Colors.tealAccent[700] : Colors.indigo,
                    ),
                    onPressed: _selectedFile == null || _isUploading
                        ? null
                        : () => _submit(printProvider, auth),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileCard(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Card(
      color: cardColor,
      elevation: isDark ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Document",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                  isDark ? Colors.teal.withOpacity(0.1) : Colors.green[50],
                  border: Border.all(
                      color: isDark ? Colors.tealAccent : Colors.green),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description,
                        color: isDark ? Colors.tealAccent : Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedFile!.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _isUploading
                          ? null
                          : () => setState(() => _selectedFile = null),
                      child: Icon(Icons.close,
                          color: isDark ? Colors.red[300] : Colors.red),
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text(
                  "Choose PDF File",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                onPressed: _isUploading ? null : _pickFile,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                      color: isDark ? Colors.tealAccent : Colors.indigo),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferences(bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    return Card(
      color: cardColor,
      elevation: isDark ? 1 : 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Print Preferences",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Text(
              "Sides",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    value: false,
                    groupValue: _isDuplex,
                    activeColor: isDark ? Colors.tealAccent : Colors.indigo,
                    title: const Text("Single Sided",
                        style: TextStyle(fontFamily: 'Poppins')),
                    onChanged: (v) => setState(() => _isDuplex = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    value: true,
                    groupValue: _isDuplex,
                    activeColor: isDark ? Colors.tealAccent : Colors.indigo,
                    title: const Text("Double Sided",
                        style: TextStyle(fontFamily: 'Poppins')),
                    onChanged: (v) => setState(() => _isDuplex = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text(
                  "Copies:",
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                Expanded(
                  child: Slider(
                    value: _copies.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _copies.toString(),
                    activeColor: isDark ? Colors.tealAccent : Colors.indigo,
                    onChanged: (val) => setState(() => _copies = val.toInt()),
                  ),
                ),
                Text(
                  '$_copies',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: isDark ? Colors.white70 : Colors.black,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (res != null && res.files.single.path != null) {
        final file = File(res.files.single.path!);
        final pdfDoc = await PdfDocument.openFile(file.path);
        setState(() {
          _selectedFile = res.files.single;
          _pages = pdfDoc.pagesCount;
        });
        await pdfDoc.close();
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  Future<void> _submit(PrintProvider printProvider, AuthProvider auth) async {
    if (_selectedFile == null || _isUploading) return;
    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    final prefs = PrintPreferences(
      isColor: _isColor,
      isDuplex: _isDuplex,
      copies: _copies,
      pages: _pages,
    );

    final user = auth.user as UserModel;

    try {
      await printProvider.uploadPrintRequest(
        file: _selectedFile!,
        preferences: prefs,
        user: user,
        pages: _pages,
        onProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      if (!mounted) return;
      setState(() => _isUploading = false);

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const UploadSuccessScreen(),
          transitionsBuilder: (context, animation, secondary, child) {
            const curve = Curves.easeInOut;
            final tween = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                .chain(CurveTween(curve: curve));
            return FadeTransition(
              opacity: animation,
              child:
              SlideTransition(position: animation.drive(tween), child: child),
            );
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploading = false);
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => UploadFailedScreen(
            errorMessage: e.toString(),
            onRetry: () => Navigator.pop(context),
          ),
          transitionsBuilder: (context, animation, secondary, child) {
            const curve = Curves.easeInOut;
            final tween = Tween(begin: const Offset(0, 0.1), end: Offset.zero)
                .chain(CurveTween(curve: curve));
            return FadeTransition(
              opacity: animation,
              child:
              SlideTransition(position: animation.drive(tween), child: child),
            );
          },
        ),
      );
    }
  }
}
