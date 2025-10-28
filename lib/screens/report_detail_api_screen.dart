import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';

/// Report Detail Screen with API Integration
/// Requirements: 8.3, 8.4, 8.5
class ReportDetailApiScreen extends StatefulWidget {
  final int reportId;

  const ReportDetailApiScreen({
    super.key,
    required this.reportId,
  });

  @override
  State<ReportDetailApiScreen> createState() => _ReportDetailApiScreenState();
}

class _ReportDetailApiScreenState extends State<ReportDetailApiScreen> {
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _loadReportDetails();
  }

  Future<void> _loadReportDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.getReport(widget.reportId);

      if (response.data['success'] == true) {
        setState(() {
          _reportData = response.data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ErrorHandler.showError(
            context,
            title: 'Failed to load report',
            message: response.data['message'] ?? 'Unknown error',
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: 'Failed to load report',
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _downloadReport() async {
    try {
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        if (mounted) {
          ErrorHandler.showError(
            context,
            title: 'Permission Required',
            message: 'Storage permission is required to download the report',
          );
        }
        return;
      }

      setState(() {
        _isDownloading = true;
      });

      final apiService = context.read<ApiService>();
      final response = await apiService.downloadReport(widget.reportId);

      final directory = await _getDownloadDirectory();
      if (directory == null) {
        throw Exception('Could not access download directory');
      }

      final fileName =
          'report_${widget.reportId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        _isDownloading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report downloaded to: $filePath'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: 'Download Failed',
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _shareReport() async {
    try {
      setState(() {
        _isDownloading = true;
      });

      final apiService = context.read<ApiService>();
      final response = await apiService.downloadReport(widget.reportId);

      final directory = await getTemporaryDirectory();
      final fileName = 'report_${widget.reportId}.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.data);

      setState(() {
        _isDownloading = false;
      });

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: _reportData?['title'] ?? 'Astrology Report',
      );
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      if (mounted) {
        ErrorHandler.showError(
          context,
          title: 'Share Failed',
          message: e.toString(),
        );
      }
    }
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }
      final status = await Permission.storage.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  Future<Directory?> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final downloadDir = Directory('${directory.path}/Downloads');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }
        return downloadDir;
      }
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Details'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _reportData != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label: 'Download PDF',
                  onPressed: _downloadReport,
                  isLoading: _isDownloading,
                  icon: Icons.download,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_reportData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load report',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReportDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportInfoCard(),
          const SizedBox(height: 16),
          _buildReportContentCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildReportInfoCard() {
    final title = _reportData!['title'] ?? 'Untitled Report';
    final reportNumber = _reportData!['report_number'] ?? 'N/A';
    final createdAt = _reportData!['created_at'] ?? '';
    final status = _reportData!['status'] ?? 'completed';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Report #$reportNumber',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Status',
                    _formatStatus(status),
                    Icons.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Created',
                    _formatDate(createdAt),
                    Icons.calendar_today,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContentCard() {
    final metadata = _reportData!['metadata'] as Map<String, dynamic>?;

    if (metadata == null || metadata.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Report Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...metadata.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        _formatKey(entry.key),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatStatus(String status) {
    return status[0].toUpperCase() + status.substring(1);
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatKey(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
