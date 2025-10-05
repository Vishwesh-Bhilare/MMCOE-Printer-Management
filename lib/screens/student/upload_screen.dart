import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../providers/print_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/storage_service.dart';
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
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final StorageService _storageService = StorageService();

  @override
  Widget build(BuildContext context) {
    final printProvider = Provider.of<PrintProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

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

                    // Selected File Display
                    if (_selectedFile != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedFile!.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pages detected: $_pages',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.cloud_upload, size: 48, color: Colors.grey),
                            const SizedBox(height: 8),
                            const Text(
                              'No file selected',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 16),

                    // File Pick Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _isUploading ? null : _pickFile,
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Choose PDF File'),
                      ),
                    ),

                    // Upload Progress
                    if (_isUploading)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 8),
                          Text(
                            'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Print Preferences
            _buildPrintPreferences(),

            const SizedBox(height: 16),

            // Cost Summary
            _buildCostSummary(),

            const SizedBox(height: 24),

            // Submit Button
            if (printProvider.isLoading || _isUploading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedFile == null ? null : () {
                    _submitPrintRequest(printProvider, authProvider);
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

  Widget _buildPrintPreferences() {
    return Card(
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
    );
  }

  Widget _buildCostSummary() {
    return Card(
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

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.extension == 'pdf') {
        setState(() {
          _selectedFile = result.files.single;
          // Simulate page detection - in real app, you'd use a PDF library
          _pages = 5 + (DateTime.now().millisecond % 20); // Random 5-25 pages
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

  void _submitPrintRequest(PrintProvider printProvider, AuthProvider authProvider) async {
    if (_selectedFile == null || authProvider.user == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Simulate file upload
      for (int i = 0; i <= 10; i++) {
        await Future.delayed(const Duration(milliseconds: 200));
        setState(() {
          _uploadProgress = i / 10;
        });
      }

      final preferences = PrintPreferences(
        isColor: _isColor,
        isDuplex: _isDuplex,
        copies: _copies,
        pages: _pages,
      );

      final request = PrintRequest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        studentId: authProvider.user!.studentId,
        printId: '0000', // Will be set by Firestore service
        fileName: _selectedFile!.name,
        fileUrl: 'https://example.com/uploaded-file.pdf', // Will be real URL
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
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}