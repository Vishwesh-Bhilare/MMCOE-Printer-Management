import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/print_provider.dart';
import '../../core/constants/app_constants.dart';
import 'print_queue_screen.dart';
import '../../models/print_request_model.dart'; // Add this import

class PrinterDashboardScreen extends StatelessWidget {
  const PrinterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final printProvider = Provider.of<PrintProvider>(context);

    // Get stats
    final pendingCount = printProvider.printRequests
        .where((request) => request.status == 'pending')
        .length;
    final readyCount = printProvider.printRequests
        .where((request) => request.status == 'ready')
        .length;
    final totalRevenue = printProvider.printRequests
        .where((request) => request.status == 'ready' || request.status == 'collected')
        .fold(0.0, (sum, request) => sum + request.totalCost);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${authProvider.user?.name ?? 'Printer'}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Printer Station',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Stats Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pending',
                    value: pendingCount.toString(),
                    color: Colors.orange,
                    icon: Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Ready',
                    value: readyCount.toString(),
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Revenue',
                    value: '₹${totalRevenue.toStringAsFixed(2)}',
                    color: Colors.blue,
                    icon: Icons.attach_money,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrintQueueScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View Print Queue'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent Activity
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 16),

          // Recent Print Requests
          Expanded(
            child: printProvider.printRequests.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.print, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No print requests yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: printProvider.printRequests.take(5).length,
              itemBuilder: (context, index) {
                final request = printProvider.printRequests[index];
                return _PrintRequestItem(request: request);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrintRequestItem extends StatelessWidget {
  final PrintRequest request;

  const _PrintRequestItem({required this.request});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(request.status),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(request.fileName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Print ID: ${request.printId}'),
            Text('Student: ${request.studentId}'),
            Text('Pages: ${request.totalPages} • ${request.preferences.isColor ? 'Color' : 'B/W'}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '₹${request.totalCost.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(request.status),
                borderRadius: BorderRadius.circular(12),
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
          ],
        ),
      ),
    );
  }

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
}