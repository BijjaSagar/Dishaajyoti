import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Numerology Analysis Display Screen
/// Requirements: 6.2, 6.3
class NumerologyAnalysisScreen extends StatelessWidget {
  final Map<String, dynamic> analysisData;

  const NumerologyAnalysisScreen({
    super.key,
    required this.analysisData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.numerology_analysis_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCoreNumbersCard(context),
            const SizedBox(height: 16),
            _buildLifePathCard(context),
            const SizedBox(height: 16),
            _buildDestinyCard(context),
            const SizedBox(height: 16),
            _buildSoulUrgeCard(context),
            const SizedBox(height: 16),
            _buildLuckyElementsCard(context),
            const SizedBox(height: 16),
            _buildCompatibilityCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCoreNumbersCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lifePathNumber = analysisData['life_path_number'] ?? 0;
    final destinyNumber = analysisData['destiny_number'] ?? 0;
    final soulUrgeNumber = analysisData['soul_urge_number'] ?? 0;

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
                  Icons.numbers,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_analysis_core_numbers,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNumberCircle(
                  context,
                  l10n.numerology_analysis_life_path_label,
                  lifePathNumber.toString(),
                  Colors.purple,
                ),
                _buildNumberCircle(
                  context,
                  l10n.numerology_analysis_destiny_label,
                  destinyNumber.toString(),
                  Colors.blue,
                ),
                _buildNumberCircle(
                  context,
                  l10n.numerology_analysis_soul_urge_label,
                  soulUrgeNumber.toString(),
                  Colors.orange,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifePathCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis = analysisData['analysis'] as Map<String, dynamic>?;
    final lifePathAnalysis =
        analysis?['life_path'] ?? l10n.numerology_life_path_desc;

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
                  Icons.route,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_analysis_life_path_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              lifePathAnalysis.toString(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinyCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis = analysisData['analysis'] as Map<String, dynamic>?;
    final destinyAnalysis =
        analysis?['destiny'] ?? l10n.numerology_destiny_desc;

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
                  Icons.star,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_analysis_destiny_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              destinyAnalysis.toString(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoulUrgeCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis = analysisData['analysis'] as Map<String, dynamic>?;
    final soulUrgeAnalysis =
        analysis?['soul_urge'] ?? l10n.numerology_soul_urge_desc;

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
                  Icons.favorite,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_analysis_soul_urge_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              soulUrgeAnalysis.toString(),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyElementsCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final luckyNumbers = analysisData['lucky_numbers'] as List?;
    final luckyColors = analysisData['lucky_colors'] as List?;
    final luckyDays = analysisData['lucky_days'] as List?;

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
                  l10n.numerology_analysis_lucky_elements,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (luckyNumbers != null && luckyNumbers.isNotEmpty)
              _buildLuckyItem(
                context,
                l10n.numerology_analysis_lucky_numbers_label,
                luckyNumbers.join(', '),
                Icons.filter_1,
                Colors.purple,
              ),
            if (luckyColors != null && luckyColors.isNotEmpty)
              _buildLuckyItem(
                context,
                l10n.numerology_analysis_lucky_colors,
                luckyColors.join(', '),
                Icons.palette,
                Colors.blue,
              ),
            if (luckyDays != null && luckyDays.isNotEmpty)
              _buildLuckyItem(
                context,
                l10n.numerology_analysis_lucky_days,
                luckyDays.join(', '),
                Icons.calendar_today,
                Colors.green,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final compatibility =
        analysisData['compatibility'] as Map<String, dynamic>?;

    if (compatibility == null || compatibility.isEmpty) {
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
                  Icons.people,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.numerology_analysis_compatibility_title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (compatibility['best_matches'] != null)
              _buildCompatibilityItem(
                context,
                l10n.numerology_analysis_best_matches,
                compatibility['best_matches'].toString(),
                Colors.green,
              ),
            if (compatibility['challenging_matches'] != null)
              _buildCompatibilityItem(
                context,
                l10n.numerology_analysis_challenging_matches,
                compatibility['challenging_matches'].toString(),
                Colors.orange,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberCircle(
      BuildContext context, String label, String number, Color color) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLuckyItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilityItem(
      BuildContext context, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
