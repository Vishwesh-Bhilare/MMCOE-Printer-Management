import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/print_provider.dart';
import '../../models/print_request_model.dart';
import '../../models/print_preferences_model.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _fileNameController = TextEditingController();
  bool _isColor = false;
  bool _isDuplex = true;
  int _copies = 1;
  int _pages = 1;

  @override
  Widget build(BuildContext context) {
    final printProvider = Provider.of<PrintProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File Upload Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Document',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _fileNameController,
                      decoration: const InputDecoration(
                        labelText: 'File Name',
                        hintText: 'e.g., assignment.pdf',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Simulate file picker
                          _fileNameController.text = 'document_${DateTime.now().millisecondsSinceEpoch}.pdf';
                          setState(() {
                            _pages = 10; // Simulate page detection
                          });
                        },
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Choose PDF File'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Print Preferences
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Print Preferences',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Color/BW Selection
                    const Text('Print Type'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Black & White'),
                            value: false,
                            groupValue: _isColor,
                            onChanged: (value) {
                              setState(() {
                                _isColor = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Color'),
                            value: true,
                            groupValue: _isColor,
                            onChanged: (value) {
                              setState(() {
                                _isColor = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Single/Double Sided
                    const Text('Sides'),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Single Sided'),
                            value: false,
                            groupValue: _isDuplex,
                            onChanged: (value) {
                              setState(() {
                                _isDuplex = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Double Sided'),
                            value: true,
                            groupValue: _isDuplex,
                            onChanged: (value) {
                              setState(() {
                                _isDuplex = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Copies
                    Row(
                      children: [
                        const Text('Copies:'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _copies.toDouble(),
                            min: 1,
                            max: 10,
                            divisions: 9,
                            label: _copies.toString(),
                            onChanged: (value) {
                              setState(() {
                                _copies = value.toInt();
                              });
                            },
                          ),
                        ),
                        Text('$_copies'),
                      ],
                    ),

                    // Pages (read-only, detected from file)
                    Row(
                      children: [
                        const Text('Pages:'),
                        const SizedBox(width: 16),
                        Text('$_pages'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Cost Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cost Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCostRow('Print Type', _isColor ? 'Color' : 'Black & White'),
                    _buildCostRow('Sides', _isDuplex ? 'Double' : 'Single'),
                    _buildCostRow('Copies', '$_copies'),
                    _buildCostRow('Pages', '$_pages'),
                    const Divider(),
                    _buildCostRow(
                      'Total Cost',
                      '₹${_calculateCost().toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            if (printProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _fileNameController.text.isEmpty
                      ? null
                      : () {
                    _submitPrintRequest(printProvider);
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('SUBMIT PRINT REQUEST'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: isBold
                ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                : null,
          ),
        ],
      ),
    );
  }

  double _calculateCost() {
    final preferences = PrintPreferences(
      isColor: _isColor,
      isDuplex: _isDuplex,
      copies: _copies,
      pages: _pages,
    );
    return preferences.calculateCost();
  }

  void _submitPrintRequest(PrintProvider printProvider) async {
    final preferences = PrintPreferences(
      isColor: _isColor,
      isDuplex: _isDuplex,
      copies: _copies,
      pages: _pages,
    );

    final request = PrintRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      studentId: '2023001', // This should come from auth provider
      printId: _generatePrintId(),
      fileName: _fileNameController.text,
      fileUrl: '', // This would be the uploaded file URL
      preferences: preferences,
      status: 'pending',
      createdAt: DateTime.now(),
      totalCost: _calculateCost(),
      totalPages: _pages * _copies,
    );

    await printProvider.submitPrintRequest(request);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Print request submitted successfully!'),
        ),
      );
      Navigator.pop(context);
    }
  }

  String _generatePrintId() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch % 10000}'.padLeft(4, '0');
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}