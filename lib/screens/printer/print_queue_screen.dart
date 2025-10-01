import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/print_provider.dart';
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

    // Filter requests based on selected status
    List<PrintRequest> filteredRequests = printProvider.printRequests.where((request) {
      if (_filterStatus == 'all') return true;
      return request.status == _filterStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Print Queue'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                _FilterChip(
                  label: 'All',
                  value: 'all',
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Pending',
                  value: 'pending',
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Ready',
                  value: 'ready',
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
                _FilterChip(
                  label: 'Collected',
                  value: 'collected',
                  groupValue: _filterStatus,
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Print Queue List
          Expanded(
            child: filteredRequests.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No print requests',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredRequests.length,
              itemBuilder: (context, index) {
                final request = filteredRequests[index];
                return _PrintQueueItem(request: request);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final Function(String) onChanged;

  const _FilterChip({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: groupValue == value,
      onSelected: (selected) {
        onChanged(value);
      },
    );
  }
}

class _PrintQueueItem extends StatelessWidget {
  final PrintRequest request;

  const _PrintQueueItem({required this.request});

  @override
  Widget build(BuildContext context) {
    final printProvider = Provider.of<PrintProvider>(context, listen: false);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.fileName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Print ID: ${request.printId}'),
            Text('Student ID: ${request.studentId}'),
            Text('Pages: ${request.totalPages} • Copies: ${request.preferences.copies}'),
            Text('Type: ${request.preferences.isColor ? 'Color' : 'B/W'} • Sides: ${request.preferences.isDuplex ? 'Double' : 'Single'}'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹${request.totalCost.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _formatDate(request.createdAt),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Action Buttons
            if (request.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await printProvider.updatePrintStatus(request.id, 'ready');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marked as ready for collection'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text('MARK AS READY'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await printProvider.updatePrintStatus(request.id, 'collected');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Marked as collected'),
                          ),
                        );
                      },
                      child: const Text('MARK COLLECTED'),
                    ),
                  ),
                ],
              ),

            if (request.status == 'ready')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await printProvider.updatePrintStatus(request.id, 'collected');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Marked as collected'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('MARK AS COLLECTED'),
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}