import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Palmistry Analysis Display Screen
/// Requirements: 5.2, 5.3, 5.4, 5.5
class PalmistryAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const PalmistryAnalysisScreen({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.palmistry_analysis_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(context),
            const SizedBox(height: 16),
            _buildMajorLinesCard(context),
            const SizedBox(height: 16),
            _buildMountsCard(context),
            const SizedBox(height: 16),
            _buildFingersCard(context),
            const SizedBox(height: 16),
            _buildPredictionsCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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
                  l10n.palmistry_analysis_summary,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              analysisData['summary'] ??
                  'Your palm reveals unique characteristics and potential life paths.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMajorLinesCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final majorLines = analysisData['major_lines'] as Map<String, dynamic>?;

    if (majorLines == null || majorLines.isEmpty) {
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
                  Icons.timeline,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.palmistry_analysis_major_lines,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...majorLines.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildLineItem(
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

  Widget _buildMountsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mounts = analysisData['mounts'] as Map<String, dynamic>?;

    if (mounts == null || mounts.isEmpty) {
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
                  Icons.landscape,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.palmistry_analysis_mounts,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...mounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildMountItem(
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

  Widget _buildFingersCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final fingers = analysisData['finger_analysis'] as Map<String, dynamic>?;

    if (fingers == null || fingers.isEmpty) {
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
                  Icons.back_hand,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.palmistry_analysis_fingers,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              fingers['description'] ??
                  'Your fingers reveal personality traits and capabilities.',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final predictions = analysisData['predictions'] as Map<String, dynamic>?;

    if (predictions == null || predictions.isEmpty) {
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
                  Icons.insights,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.palmistry_analysis_predictions,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (predictions['health'] != null)
              _buildPredictionItem(
                context,
                l10n.palmistry_analysis_health,
                predictions['health'].toString(),
                Icons.favorite,
                Colors.red,
              ),
            if (predictions['career'] != null)
              _buildPredictionItem(
                context,
                l10n.palmistry_analysis_career,
                predictions['career'].toString(),
                Icons.work,
                Colors.blue,
              ),
            if (predictions['relationships'] != null)
              _buildPredictionItem(
                context,
                l10n.palmistry_analysis_relationships,
                predictions['relationships'].toString(),
                Icons.people,
                Colors.purple,
              ),
            if (predictions['longevity'] != null)
              _buildPredictionItem(
                context,
                l10n.palmistry_analysis_longevity,
                predictions['longevity'].toString(),
                Icons.hourglass_bottom,
                Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineItem(String lineName, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatLineName(lineName),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMountItem(String mountName, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatMountName(mountName),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatLineName(String name) {
    return name
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String _formatMountName(String name) {
    if (name.startsWith('mount_')) {
      name = name.substring(6);
    }
    return 'Mount of ${name[0].toUpperCase()}${name.substring(1)}';
  }
}
