import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/print_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/print_request_model.dart';

class PrintQueueScreen extends StatefulWidget {
  const PrintQueueScreen({super.key});

  @override
  State<PrintQueueScreen> createState() => _PrintQueueScreenState();
}

class _PrintQueueScreenState extends State<PrintQueueScreen> {
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final printProvider = Provider.of<PrintProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final allRequests = printProvider.printRequests;
    final filteredRequests = allRequests.where((r) {
      if (_filterStatus == 'all') return true;
      return r.status == _filterStatus;
    }).toList();

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF6F8FB);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final accent = isDark ? Colors.tealAccent : Colors.indigo;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.indigo,
        elevation: 0,
        title: const Text('Print Queue', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: Colors.white,
            ),
            tooltip: 'Toggle Theme',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', 'all', accent),
                _buildFilterChip('Pending', 'pending', Colors.orange),
                _buildFilterChip('Ready', 'ready', Colors.green),
                _buildFilterChip('Collected', 'collected', Colors.blue),
              ],
            ),
          ),

          // Request list
          Expanded(
            child: printProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredRequests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[500]),
                  const SizedBox(height: 12),
                  Text(
                    'No print requests found',
                    style: TextStyle(
                        color: isDark ? Colors.white54 : Colors.grey[700]),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                return _PrintQueueItem(
                  request: filteredRequests[index],
                  cardColor: cardColor,
                  isDark: isDark,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, Color color) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final selected = _filterStatus == value;
    final textColor =
    selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87);

    return ChoiceChip(
      label: Text(label, style: TextStyle(color: textColor)),
      selected: selected,
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[200],
      selectedColor: color,
      onSelected: (_) => setState(() => _filterStatus = value),
      pressElevation: 0,
    );
  }
}

class _PrintQueueItem extends StatelessWidget {
  final PrintRequest request;
  final Color cardColor;
  final bool isDark;

  const _PrintQueueItem({
    required this.request,
    required this.cardColor,
    required this.isDark,
  });

  Color _getStatusColor(String status) {
    switch (status) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _downloadFile(BuildContext context, String url) async {
    final dio = Dio();

    try {
      final downloadsDir = await getDownloadsDirectory();
      final savePath = '${downloadsDir!.path}/${request.studentId}_${request.fileName}';

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...'), duration: Duration(seconds: 2)),
      );

      await dio.download(url, savePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to Downloads: ${request.fileName}'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Open',
            textColor: Colors.white,
            onPressed: () async {
              final file = File(savePath);
              if (await file.exists()) {
                await launchUrl(Uri.file(savePath));
              }
            },
          ),
        ),
      );
    } catch (e) {
      try {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(request.status);
    final studentId = request.studentId.contains('@')
        ? request.studentId.split('@').first
        : request.studentId;
    final revenue = request.totalPages * 2;
    final printProvider = Provider.of<PrintProvider>(context, listen: false);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  request.fileName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  request.status.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Text('Student: $studentId',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          Text('Pages: ${request.totalPages} | Copies: ${request.preferences.copies}',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
          Text(
            '${request.preferences.isColor ? 'Color' : 'B/W'} • ${request.preferences.isDuplex ? 'Double' : 'Single'}',
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[700]),
          ),
          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('₹$revenue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.tealAccent : Colors.indigo,
                  )),
              Text(
                _formatDate(request.createdAt),
                style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[600], fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              InkWell(
                onTap: () => _downloadFile(context, request.fileUrl),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: isDark ? Colors.tealAccent : Colors.indigo),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.download,
                          color: isDark ? Colors.tealAccent : Colors.indigo, size: 18),
                      const SizedBox(width: 6),
                      Text('Download',
                          style: TextStyle(
                              color: isDark ? Colors.tealAccent : Colors.indigo,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.black87),
                onSelected: (value) async {
                  await printProvider.updatePrintStatus(request.id, value);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked as $value'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'pending', child: Text('Mark Pending')),
                  PopupMenuItem(value: 'ready', child: Text('Mark Ready')),
                  PopupMenuItem(value: 'collected', child: Text('Mark Collected')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
