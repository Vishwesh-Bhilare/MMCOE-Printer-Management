import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/auth_provider.dart';
import '../../providers/print_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/print_request_model.dart';
import 'print_queue_screen.dart';
import 'package:lottie/lottie.dart';

class PrinterDashboardScreen extends StatefulWidget {
  const PrinterDashboardScreen({super.key});

  @override
  State<PrinterDashboardScreen> createState() => _PrinterDashboardScreenState();
}

class _PrinterDashboardScreenState extends State<PrinterDashboardScreen> {
  DateTime? _lastUpdated;
  Timer? _timer;
  String _timeAgo = "Just now";
  String _selectedFilter = "all";

  @override
  void initState() {
    super.initState();
    final print = Provider.of<PrintProvider>(context, listen: false);
    print.startListeningToAll();
    _lastUpdated = DateTime.now();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    Provider.of<PrintProvider>(context, listen: false).stopListening();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_lastUpdated == null) return;
      final diff = DateTime.now().difference(_lastUpdated!);
      String time;
      if (diff.inSeconds < 10) {
        time = "Just now";
      } else if (diff.inSeconds < 60) {
        time = "${diff.inSeconds}s ago";
      } else if (diff.inMinutes < 60) {
        time = "${diff.inMinutes}m ago";
      } else if (diff.inHours < 24) {
        time = "${diff.inHours}h ago";
      } else {
        time = "${diff.inDays}d ago";
      }
      if (mounted) setState(() => _timeAgo = time);
    });
  }

  Future<void> _refresh(BuildContext context) async {
    final print = Provider.of<PrintProvider>(context, listen: false);
    print.stopListening();
    await Future.delayed(const Duration(milliseconds: 500));
    print.startListeningToAll();
    setState(() => _lastUpdated = DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final print = Provider.of<PrintProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.indigo;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);

    final requests = print.printRequests;
    final filtered = _selectedFilter == "all"
        ? requests
        : requests.where((r) => r.status == _selectedFilter).toList();

    final pending = requests.where((r) => r.status == 'pending').length;
    final ready = requests.where((r) => r.status == 'ready').length;
    final collected = requests.where((r) => r.status == 'collected').length;
    final totalRevenue =
    requests.fold(0.0, (sum, r) => sum + (r.totalPages * 2));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Printer Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: appBarColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
                isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round),
            onPressed: () => theme.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refresh(context),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => auth.logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(26),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              'Last updated: $_timeAgo',
              style:
              const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 650;

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            color: isDark ? Colors.tealAccent : Colors.indigo,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                  horizontal: isWide ? 40 : 16, vertical: 20),
              children: [
                // Welcome header
                Text(
                  'Welcome, ${auth.user?.name ?? 'Printer'}!',
                  style: TextStyle(
                    fontSize: isWide ? 26 : 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.indigo,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Printer Station',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: isWide ? 16 : 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats summary cards (stay in wrap)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _StatCard('Pending', '$pending', Colors.orange,
                        Icons.pending_actions, isDark),
                    _StatCard('Ready', '$ready', Colors.green,
                        Icons.check_circle, isDark),
                    _StatCard('Collected', '$collected', Colors.blue,
                        Icons.archive, isDark),
                    _StatCard('Revenue', '₹${totalRevenue.toStringAsFixed(0)}',
                        Colors.purple, Icons.currency_rupee, isDark),
                  ],
                ),

                const SizedBox(height: 28),

                // Queue button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.queue_play_next),
                    label: const Text('View Full Print Queue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appBarColor,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PrintQueueScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),

                // Recent Activity header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recent Activity",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.filter_list,
                          color: isDark ? Colors.white70 : Colors.indigo),
                      onSelected: (val) =>
                          setState(() => _selectedFilter = val),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'all', child: Text('All')),
                        PopupMenuItem(
                            value: 'pending', child: Text('Pending')),
                        PopupMenuItem(value: 'ready', child: Text('Ready')),
                        PopupMenuItem(
                            value: 'collected', child: Text('Collected')),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Activity section
                if (filtered.isEmpty)
                  Center(
                    child: Column(
                      children: [
                        Lottie.asset('assets/lottie/empty.json', width: 160),
                        const SizedBox(height: 8),
                        Text(
                          'No requests found for "$_selectedFilter"',
                          style: TextStyle(
                            color:
                            isDark ? Colors.white70 : Colors.black54,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filtered.length,
                    gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isWide ? 2 : 1,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 3.2 : 2.8,
                    ),
                    itemBuilder: (context, i) => _RequestTile(
                        request: filtered.reversed.toList()[i],
                        isDark: isDark),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ------------------------ STAT CARD --------------------------
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;
  const _StatCard(
      this.title, this.value, this.color, this.icon, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : color.withOpacity(0.8),
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------- REQUEST TILE --------------------------
class _RequestTile extends StatelessWidget {
  final PrintRequest request;
  final bool isDark;
  const _RequestTile({required this.request, required this.isDark});

  Color _statusColor(String s) {
    switch (s) {
      case 'pending':
        return Colors.orange;
      case 'ready':
        return Colors.green;
      case 'collected':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    final dio = Dio();
    try {
      final dir = await getDownloadsDirectory();
      final path = '${dir!.path}/${request.fileName}';
      await dio.download(url, path);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved: ${request.fileName}'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    final student = request.studentId.contains('@')
        ? request.studentId.split('@').first
        : request.studentId;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.picture_as_pdf, color: color, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Student: $student',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontFamily: 'Poppins',
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Pages: ${request.totalPages} • ₹${request.totalPages * 2}',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _downloadFile(context, request.fileUrl),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Icon(
                    Icons.download,
                    size: 22,
                    color: isDark ? Colors.tealAccent : Colors.indigo,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
