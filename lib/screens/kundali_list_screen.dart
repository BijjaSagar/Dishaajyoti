import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:io';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/kundali_model.dart';
import '../services/database_helper.dart';

/// Screen to display list of generated Kundalis
class KundaliListScreen extends StatefulWidget {
  const KundaliListScreen({super.key});

  @override
  State<KundaliListScreen> createState() => _KundaliListScreenState();
}

class _KundaliListScreenState extends State<KundaliListScreen> {
  List<Kundali> _kundalis = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKundalis();
  }

  Future<void> _loadKundalis() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final kundalis = await DatabaseHelper.instance
          .getKundalis('user123'); // TODO: Get from auth
      setState(() {
        _kundalis = kundalis;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load Kundalis: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _viewPdf(Kundali kundali) async {
    if (kundali.pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final file = File(kundali.pdfPath!);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        await Printing.layoutPdf(
          onLayout: (format) async => bytes,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF file not found'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open PDF: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteKundali(Kundali kundali) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Kundali'),
        content:
            Text('Are you sure you want to delete ${kundali.name}\'s Kundali?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deleteKundali(kundali.id);

        // Delete PDF file
        if (kundali.pdfPath != null) {
          final file = File(kundali.pdfPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }

        _loadKundalis();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kundali deleted successfully'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Kundalis',
          style: AppTypography.h3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _kundalis.isEmpty
              ? _buildEmptyState()
              : _buildKundaliList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Kundalis Yet',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate your first free Kundali from the services section',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKundaliList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _kundalis.length,
      itemBuilder: (context, index) {
        final kundali = _kundalis[index];
        return _buildKundaliCard(kundali);
      },
    );
  }

  Widget _buildKundaliCard(Kundali kundali) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewPdf(kundali),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          kundali.name,
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generated on ${kundali.createdAt.day}/${kundali.createdAt.month}/${kundali.createdAt.year}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppColors.error,
                    onPressed: () => _deleteKundali(kundali),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.calendar_today, 'DOB',
                  '${kundali.dateOfBirth.day}/${kundali.dateOfBirth.month}/${kundali.dateOfBirth.year}'),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.access_time, 'Time', kundali.timeOfBirth),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.location_on, 'Place', kundali.placeOfBirth),
              if (kundali.data != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge('Sun: ${kundali.data!.sunSign}'),
                    const SizedBox(width: 8),
                    _buildBadge('Moon: ${kundali.data!.moonSign}'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.primaryOrange,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
