import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/print_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/print_request_model.dart';

class PrinterHomeScreen extends StatefulWidget {
  const PrinterHomeScreen({super.key});

  @override
  State<PrinterHomeScreen> createState() => _PrinterHomeScreenState();
}

class _PrinterHomeScreenState extends State<PrinterHomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<PrintProvider>(context, listen: false).startListeningToAll();
  }

  @override
  void dispose() {
    Provider.of<PrintProvider>(context, listen: false).stopListening();
    super.dispose();
  }

  Future<void> _refresh(BuildContext context) async {
    final print = Provider.of<PrintProvider>(context, listen: false);
    print.stopListening();
    await Future.delayed(const Duration(milliseconds: 400));
    print.startListeningToAll();
  }

  @override
  Widget build(BuildContext context) {
    final print = Provider.of<PrintProvider>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final isDark = theme.isDarkMode;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6FB);
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.indigo;

    final requests = print.printRequests;
    final pending = requests.where((r) => r.status == 'pending').toList();
    final ready = requests.where((r) => r.status == 'ready').toList();
    final collected = requests.where((r) => r.status == 'collected').toList();
    final totalRevenue =
    requests.fold(0.0, (sum, r) => sum + (r.totalPages * 2));

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Printer Home',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarColor,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: Colors.white,
            ),
            onPressed: () => theme.toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showModalBottomSheet(
            context: context,
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (_) => _BulkActionSheet(isDark: isDark),
          );
        },
        icon: const Icon(Icons.settings),
        label: const Text("Bulk Actions"),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context),
        color: isDark ? Colors.tealAccent : Colors.indigo,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: print.isLoading
              ? const Center(child: CircularProgressIndicator())
              : requests.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset('assets/lottie/empty.json', width: 180),
                const SizedBox(height: 16),
                Text(
                  'No print requests yet',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      color: isDark
                          ? Colors.white70
                          : Colors.black54),
                ),
              ],
            ),
          )
              : ListView(
            children: [
              // 📊 Stats Cards
              Row(
                children: [
                  Expanded(child: _StatCard('Pending', pending.length, Colors.orange, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatCard('Ready', ready.length, Colors.green, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatCard('Collected', collected.length, Colors.blue, isDark)),
                  const SizedBox(width: 8),
                  Expanded(child: _StatCard('Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Colors.purple, isDark)),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Recent Requests',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              const SizedBox(height: 12),
              ...requests.reversed
                  .take(10)
                  .map((r) => _PrintRequestCard(request: r, isDark: isDark))
                  .toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final dynamic value;
  final Color color;
  final bool isDark;
  const _StatCard(this.title, this.value, this.color, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$value',
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(
                  color: isDark ? Colors.white70 : color.withOpacity(0.8),
                  fontFamily: 'Poppins',
                  fontSize: 12)),
        ],
      ),
    );
  }
}

class _PrintRequestCard extends StatelessWidget {
  final PrintRequest request;
  final bool isDark;
  const _PrintRequestCard({required this.request, required this.isDark});

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

  Future<void> _downloadFile(BuildContext ctx, String url) async {
    final dio = Dio();
    try {
      final dir = await getDownloadsDirectory();
      final path = '${dir!.path}/${request.fileName}';
      await dio.download(url, path);
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text('Saved to Downloads: ${request.fileName}'),
        backgroundColor: Colors.green,
      ));
    } catch (_) {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(request.status);
    final provider = Provider.of<PrintProvider>(context, listen: false);
    final student = request.studentId.contains('@')
        ? request.studentId.split('@').first
        : request.studentId;
    final revenue = request.totalPages * 2;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: isDark ? Colors.black26 : Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4))
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(Icons.picture_as_pdf, color: color),
        ),
        title: Text(request.fileName,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87)),
        subtitle: Text(
          'Student: $student\n${request.totalPages} pages • ₹$revenue',
          style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 13,
              height: 1.3),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Text(request.status.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                    onTap: () => _downloadFile(context, request.fileUrl),
                    child: Icon(Icons.download,
                        color: isDark ? Colors.tealAccent : Colors.indigo)),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    await provider.updatePrintStatus(request.id, v);
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Marked as $v')));
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'pending', child: Text('Pending')),
                    PopupMenuItem(value: 'ready', child: Text('Ready')),
                    PopupMenuItem(value: 'collected', child: Text('Collected')),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BulkActionSheet extends StatelessWidget {
  final bool isDark;
  const _BulkActionSheet({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final print = Provider.of<PrintProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bulk Actions',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                  fontFamily: 'Poppins')),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.done_all),
            label: const Text('Mark All Ready'),
            style: ElevatedButton.styleFrom(
                backgroundColor:
                isDark ? Colors.tealAccent[700] : Colors.indigo),
            onPressed: () async {
              await print.markAllAs('ready');
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.archive),
            label: const Text('Mark All Collected'),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600),
            onPressed: () async {
              await print.markAllAs('collected');
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
