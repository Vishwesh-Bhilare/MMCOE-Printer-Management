import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UploadSuccessScreen extends StatefulWidget {
  const UploadSuccessScreen({super.key});

  @override
  State<UploadSuccessScreen> createState() => _UploadSuccessScreenState();
}

class _UploadSuccessScreenState extends State<UploadSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);

    // Auto-return to Home after 3.5s
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Hero(
          tag: 'uploadHero',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/lottie/success.json',
                controller: _controller,
                repeat: false,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Successful!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.tealAccent : Colors.indigo,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your document has been added to the print queue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.tealAccent[700] : Colors.indigo,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text(
                  'Back to Home',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
