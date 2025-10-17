import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class UploadFailedScreen extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback? onRetry;

  const UploadFailedScreen({
    super.key,
    this.errorMessage,
    this.onRetry,
  });

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
                'assets/lottie/error.json', // 👈 add this Lottie file
                repeat: false,
                height: 200,
              ),
              const SizedBox(height: 24),
              Text(
                'Upload Failed!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.redAccent[100] : Colors.redAccent,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage ?? 'Something went wrong. Please try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isDark ? Colors.grey[800] : Colors.grey[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    label: const Text(
                      'Back',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: onRetry ?? () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isDark ? Colors.tealAccent[700] : Colors.indigo,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
