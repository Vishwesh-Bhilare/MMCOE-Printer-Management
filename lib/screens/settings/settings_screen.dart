import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() => _appVersion = info.version);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;

    return Scaffold(
      backgroundColor:
      isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo,
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                color: Colors.white),
            tooltip: "Toggle Theme",
            onPressed: () => theme.toggleTheme(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle("Appearance"),
          SwitchListTile(
            title: const Text("Dark Mode",
                style: TextStyle(fontFamily: 'Poppins')),
            subtitle: const Text("Toggle between light and dark themes",
                style: TextStyle(fontSize: 13)),
            value: isDark,
            onChanged: (_) => theme.toggleTheme(),
            activeColor: Colors.tealAccent,
          ),
          const Divider(),

          _SectionTitle("About"),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("App Version",
                style: TextStyle(fontFamily: 'Poppins')),
            subtitle:
            Text(_appVersion, style: const TextStyle(fontSize: 13)),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text("View Source on GitHub",
                style: TextStyle(fontFamily: 'Poppins')),
            subtitle: const Text("MMCOE Printer Management"),
            onTap: () => _launchURL(
                "https://github.com/Vishwesh-Bhilare/MMCOE-Printer-Management"),
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text("Credits",
                style: TextStyle(fontFamily: 'Poppins')),
            subtitle: const Text("Made by Vishwesh Bhilare",
                style: TextStyle(fontSize: 13)),
          ),
          const SizedBox(height: 20),

          Center(
            child: Text(
              "© ${DateTime.now().year} Student Printing System",
              style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Opening GitHub page...'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ));
        }
      } else {
        throw Exception('Cannot launch $url');
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not open link'),
          behavior: SnackBarBehavior.floating,
        ));
      }
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          color: isDark ? Colors.tealAccent : Colors.indigo,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
