import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/kundali_with_chart_model.dart';
import '../models/chart_data_model.dart';
import '../widgets/kundali_chart_widget.dart';
import '../services/kundali_chart_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// Kundali Chart Detail Screen
/// Displays the birth chart with interactive features
class KundaliChartDetailScreen extends StatefulWidget {
  final KundaliWithChart kundali;

  const KundaliChartDetailScreen({
    Key? key,
    required this.kundali,
  }) : super(key: key);

  @override
  State<KundaliChartDetailScreen> createState() =>
      _KundaliChartDetailScreenState();
}

class _KundaliChartDetailScreenState extends State<KundaliChartDetailScreen> {
  late KundaliWithChart _currentKundali;
  final GlobalKey _chartKey = GlobalKey();
  bool _isChangingStyle = false;

  @override
  void initState() {
    super.initState();
    _currentKundali = widget.kundali;
  }

  Future<void> _toggleChartStyle() async {
    setState(() {
      _isChangingStyle = true;
    });

    try {
      final newStyle = _currentKundali.chartStyle == ChartStyle.northIndian
          ? ChartStyle.southIndian
          : ChartStyle.northIndian;

      await KundaliChartService.instance.updateChartStyle(
        _currentKundali.id,
        newStyle,
      );

      final updatedKundali =
          await KundaliChartService.instance.getKundali(_currentKundali.id);

      if (updatedKundali != null) {
        setState(() {
          _currentKundali = updatedKundali;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to change chart style: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() {
        _isChangingStyle = false;
      });
    }
  }

  Future<void> _shareChart() async {
    try {
      // Capture chart as image
      final boundary = _chartKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not capture chart');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/kundali_chart.png');
      await file.writeAsBytes(pngBytes);

      // Share
      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Kundali Chart for ${_currentKundali.name}\nDate of Birth: ${_currentKundali.dateOfBirth.day}/${_currentKundali.dateOfBirth.month}/${_currentKundali.dateOfBirth.year}\nPlace: ${_currentKundali.placeOfBirth}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share chart: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _currentKundali.name,
          style: AppTypography.h3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.primaryOrange),
            onPressed: _shareChart,
            tooltip: 'Share Chart',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Chart Style Toggle
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chart Style: ${_currentKundali.chartStyleDisplayName}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isChangingStyle ? null : _toggleChartStyle,
                      icon: _isChangingStyle
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.swap_horiz, size: 20),
                      label: const Text('Switch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primaryOrange,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chart Display
              RepaintBoundary(
                key: _chartKey,
                child: Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.all(16),
                  child: KundaliChartWidget(
                    chartData: _currentKundali.chartData,
                    size: MediaQuery.of(context).size.width - 80,
                    showLegend: true,
                    onPlanetTap: (planet) {
                      _showPlanetDetails(planet);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Birth Details Card
              _buildInfoCard(
                title: 'Birth Details',
                icon: Icons.person,
                children: [
                  _buildInfoRow('Name', _currentKundali.name),
                  _buildInfoRow(
                    'Date of Birth',
                    '${_currentKundali.dateOfBirth.day}/${_currentKundali.dateOfBirth.month}/${_currentKundali.dateOfBirth.year}',
                  ),
                  _buildInfoRow('Time of Birth', _currentKundali.timeOfBirth),
                  _buildInfoRow('Place of Birth', _currentKundali.placeOfBirth),
                ],
              ),
              const SizedBox(height: 16),

              // Astrological Details Card
              _buildInfoCard(
                title: 'Astrological Details',
                icon: Icons.stars,
                children: [
                  _buildInfoRow(
                    'Ascendant (Lagna)',
                    '${_currentKundali.chartData.ascendant.toStringAsFixed(2)}° - ${ZodiacSignInfo.getSign(_currentKundali.chartData.ascendant)}',
                  ),
                  if (_currentKundali.data != null) ...[
                    _buildInfoRow('Sun Sign', _currentKundali.data!.sunSign),
                    _buildInfoRow('Moon Sign', _currentKundali.data!.moonSign),
                    _buildInfoRow(
                        'Ascendant Sign', _currentKundali.data!.ascendant),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Planets Card
              _buildInfoCard(
                title: 'Planetary Positions',
                icon: Icons.public,
                children: _currentKundali.chartData.planets.map((planet) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Text(
                          planet.symbol,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            planet.name,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          'House ${planet.house}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          planet.sign,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (planet.isRetrograde) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'R',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Sync Status
              if (_currentKundali.syncStatus != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentKundali.isSynced
                        ? AppColors.success.withValues(alpha: 0.1)
                        : AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _currentKundali.isSynced
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _currentKundali.isSynced
                            ? Icons.cloud_done
                            : Icons.cloud_upload,
                        color: _currentKundali.isSynced
                            ? AppColors.success
                            : AppColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _currentKundali.isSynced
                            ? 'Synced with server'
                            : 'Pending sync',
                        style: AppTypography.bodySmall.copyWith(
                          color: _currentKundali.isSynced
                              ? AppColors.success
                              : AppColors.warning,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryOrange, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.h3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPlanetDetails(ChartPlanet planet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  planet.symbol,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  planet.name,
                  style: AppTypography.h2.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
                if (planet.isRetrograde) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Retrograde',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Sign', planet.sign),
            _buildInfoRow('House', planet.house.toString()),
            _buildInfoRow(
                'Longitude', '${planet.longitude.toStringAsFixed(2)}°'),
            _buildInfoRow(
                'Degree in Sign', '${planet.degree.toStringAsFixed(2)}°'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
