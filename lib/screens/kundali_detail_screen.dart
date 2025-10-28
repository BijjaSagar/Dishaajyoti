import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../utils/error_handler.dart';
import '../widgets/buttons/primary_button.dart';
import '../l10n/app_localizations.dart';

/// Kundali Detail View Screen
/// Requirements: 1.2, 8.3
class KundaliDetailScreen extends StatefulWidget {
  final int kundaliId;

  const KundaliDetailScreen({
    super.key,
    required this.kundaliId,
  });

  @override
  State<KundaliDetailScreen> createState() => _KundaliDetailScreenState();
}

class _KundaliDetailScreenState extends State<KundaliDetailScreen> {
  Map<String, dynamic>? _kundaliData;
  bool _isLoading = false;
  bool _isGeneratingReport = false;

  @override
  void initState() {
    super.initState();
    _loadKundaliDetails();
  }

  Future<void> _loadKundaliDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.getKundali(widget.kundaliId);

      if (response.data['success'] == true) {
        setState(() {
          _kundaliData = response.data['data'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ErrorHandler.showError(
            context,
            title: l10n.kundali_detail_failed_to_load,
            message: response.data['message'] ?? l10n.error_unknown,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.kundali_detail_failed_to_load,
          message: e.toString(),
        );
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() {
      _isGeneratingReport = true;
    });

    try {
      final apiService = context.read<ApiService>();
      final response = await apiService.generateKundaliReport(widget.kundaliId);

      setState(() {
        _isGeneratingReport = false;
      });

      if (response.data['success'] == true) {
        final reportId = response.data['data']['report_id'];

        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.kundali_detail_report_generated),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to report detail screen
          Navigator.pushNamed(
            context,
            '/report-detail',
            arguments: reportId,
          );
        }
      } else {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ErrorHandler.showError(
            context,
            title: l10n.kundali_detail_report_failed,
            message: response.data['message'] ?? l10n.error_unknown,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isGeneratingReport = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ErrorHandler.showError(
          context,
          title: l10n.kundali_detail_report_failed,
          message: e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.kundali_detail_title),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar: _kundaliData != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label: l10n.kundali_detail_generate_report,
                  onPressed: _generateReport,
                  isLoading: _isGeneratingReport,
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

    if (_kundaliData == null) {
      final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.kundali_detail_failed_to_load,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadKundaliDetails,
              child: Text(l10n.common_retry),
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
          _buildBasicInfoCard(),
          const SizedBox(height: 16),
          _buildAstrologicalInfoCard(),
          const SizedBox(height: 16),
          _buildPlanetaryPositionsCard(),
          const SizedBox(height: 16),
          _buildHousesCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final name = _kundaliData!['name'] ?? 'Unknown';
    final dateOfBirth = _kundaliData!['date_of_birth'] ?? '';
    final timeOfBirth = _kundaliData!['time_of_birth'] ?? '';
    final placeOfBirth = _kundaliData!['place_of_birth'] ?? '';

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
                  Icons.person,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.kundali_detail_basic_info,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow(l10n.kundali_detail_name, name),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.kundali_detail_dob, dateOfBirth),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.kundali_detail_time, timeOfBirth),
            const SizedBox(height: 12),
            _buildInfoRow(l10n.kundali_detail_place, placeOfBirth),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologicalInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final lagna = _kundaliData!['lagna'] ?? 'N/A';
    final moonSign = _kundaliData!['moon_sign'] ?? 'N/A';
    final sunSign = _kundaliData!['sun_sign'] ?? 'N/A';
    final nakshatra = _kundaliData!['birth_nakshatra'] ?? 'N/A';

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
                  Icons.auto_awesome,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.kundali_detail_astrological_info,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildAstroChip(
                    l10n.kundali_detail_lagna_label,
                    lagna,
                    Icons.star,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAstroChip(
                    l10n.kundali_detail_moon_sign,
                    moonSign,
                    Icons.nightlight,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildAstroChip(
                    l10n.kundali_detail_sun_sign,
                    sunSign,
                    Icons.wb_sunny,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAstroChip(
                    l10n.kundali_detail_nakshatra,
                    nakshatra,
                    Icons.stars,
                    Colors.indigo,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanetaryPositionsCard() {
    final l10n = AppLocalizations.of(context)!;
    final planetaryPositions = _kundaliData!['planetary_positions'];

    if (planetaryPositions == null) {
      return const SizedBox.shrink();
    }

    final positions = planetaryPositions is Map ? planetaryPositions : {};

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
                  Icons.public,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.kundali_detail_planetary_positions,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (positions.isEmpty)
              Text(
                l10n.kundali_detail_no_planetary_data,
                style: const TextStyle(color: Colors.grey),
              )
            else
              ...positions.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildPlanetRow(
                    entry.key,
                    entry.value.toString(),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHousesCard() {
    final l10n = AppLocalizations.of(context)!;
    final houses = _kundaliData!['houses'];

    if (houses == null) {
      return const SizedBox.shrink();
    }

    final housesMap = houses is Map ? houses : {};

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
                  Icons.home,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.kundali_detail_houses,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (housesMap.isEmpty)
              Text(
                l10n.kundali_detail_no_house_data,
                style: const TextStyle(color: Colors.grey),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: housesMap.entries.map((entry) {
                  return _buildHouseChip(entry.key, entry.value.toString());
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAstroChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetRow(String planet, String position) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            planet,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            position,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHouseChip(String house, String sign) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Text(
        l10n.kundali_detail_house_label(house, sign),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
