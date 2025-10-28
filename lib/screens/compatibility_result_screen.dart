import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../l10n/app_localizations.dart';

/// Compatibility Result Screen
/// Requirements: 7.1, 7.2, 7.3, 7.4
class CompatibilityResultScreen extends StatelessWidget {
  final Map<String, dynamic> compatibilityData;

  const CompatibilityResultScreen({
    super.key,
    required this.compatibilityData,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final ashtakootScore = compatibilityData['ashtakoot_score'] ?? 0;
    final detailedScores =
        compatibilityData['detailed_scores'] as Map<String, dynamic>?;
    final mangalDoshaPerson1 =
        compatibilityData['mangal_dosha_person1'] ?? false;
    final mangalDoshaPerson2 =
        compatibilityData['mangal_dosha_person2'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.compatibility_result_title),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScoreCard(context, ashtakootScore),
            const SizedBox(height: 16),
            _buildDetailedScoresCard(context, detailedScores),
            const SizedBox(height: 16),
            _buildMangalDoshaCard(
                context, mangalDoshaPerson1, mangalDoshaPerson2),
            const SizedBox(height: 16),
            _buildCompatibilityAnalysisCard(context),
            const SizedBox(height: 16),
            _buildRemediesCard(context),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(BuildContext context, int score) {
    final l10n = AppLocalizations.of(context)!;
    final percentage = (score / 36 * 100).round();
    final color = _getScoreColor(score);
    final interpretation = _getScoreInterpretation(context, score);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              l10n.compatibility_result_ashtakoot_score,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CustomPaint(
                    painter: _CircularScorePainter(
                      score: score,
                      maxScore: 36,
                      color: color,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      l10n.compatibility_result_out_of,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                interpretation,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedScoresCard(
      BuildContext context, Map<String, dynamic>? scores) {
    final l10n = AppLocalizations.of(context)!;

    if (scores == null || scores.isEmpty) {
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
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.compatibility_result_detailed_analysis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildKootItem(context, l10n.compatibility_result_varna,
                scores['varna'] ?? 0, 1, l10n.compatibility_result_varna_desc),
            _buildKootItem(
                context,
                l10n.compatibility_result_vashya,
                scores['vashya'] ?? 0,
                2,
                l10n.compatibility_result_vashya_desc),
            _buildKootItem(context, l10n.compatibility_result_tara,
                scores['tara'] ?? 0, 3, l10n.compatibility_result_tara_desc),
            _buildKootItem(context, l10n.compatibility_result_yoni,
                scores['yoni'] ?? 0, 4, l10n.compatibility_result_yoni_desc),
            _buildKootItem(
                context,
                l10n.compatibility_result_graha_maitri,
                scores['graha_maitri'] ?? 0,
                5,
                l10n.compatibility_result_graha_maitri_desc),
            _buildKootItem(context, l10n.compatibility_result_gana,
                scores['gana'] ?? 0, 6, l10n.compatibility_result_gana_desc),
            _buildKootItem(
                context,
                l10n.compatibility_result_bhakoot,
                scores['bhakoot'] ?? 0,
                7,
                l10n.compatibility_result_bhakoot_desc),
            _buildKootItem(context, l10n.compatibility_result_nadi,
                scores['nadi'] ?? 0, 8, l10n.compatibility_result_nadi_desc),
          ],
        ),
      ),
    );
  }

  Widget _buildMangalDoshaCard(
      BuildContext context, bool person1, bool person2) {
    final l10n = AppLocalizations.of(context)!;

    if (!person1 && !person2) {
      return Card(
        elevation: 2,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.compatibility_result_no_mangal_dosha,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.compatibility_result_no_mangal_dosha_desc,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      color: Colors.orange.shade50,
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
                Icon(Icons.warning, color: Colors.orange.shade700, size: 28),
                const SizedBox(width: 12),
                Text(
                  l10n.compatibility_result_mangal_dosha,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (person1)
              _buildDoshaItem(l10n.compatibility_result_person1_dosha),
            if (person2)
              _buildDoshaItem(l10n.compatibility_result_person2_dosha),
            const SizedBox(height: 8),
            Text(
              person1 && person2
                  ? l10n.compatibility_result_both_dosha
                  : l10n.compatibility_result_remedies_recommended,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityAnalysisCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final analysis =
        compatibilityData['compatibility_analysis'] as Map<String, dynamic>?;

    if (analysis == null || analysis.isEmpty) {
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
                  l10n.compatibility_result_analysis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (analysis['mental'] != null)
              _buildAnalysisItem(
                  l10n.compatibility_result_mental_harmony,
                  analysis['mental'].toString(),
                  Icons.psychology,
                  Colors.purple),
            if (analysis['physical'] != null)
              _buildAnalysisItem(l10n.compatibility_result_physical_harmony,
                  analysis['physical'].toString(), Icons.favorite, Colors.red),
            if (analysis['emotional'] != null)
              _buildAnalysisItem(l10n.compatibility_result_emotional_harmony,
                  analysis['emotional'].toString(), Icons.mood, Colors.blue),
            if (analysis['spiritual'] != null)
              _buildAnalysisItem(
                  l10n.compatibility_result_spiritual_harmony,
                  analysis['spiritual'].toString(),
                  Icons.self_improvement,
                  Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildRemediesCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remedies = compatibilityData['remedies'] as List?;

    if (remedies == null || remedies.isEmpty) {
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
                  Icons.healing,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.compatibility_result_remedies,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...remedies.map((remedy) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        remedy.toString(),
                        style: const TextStyle(fontSize: 14, height: 1.4),
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

  Widget _buildKootItem(BuildContext context, String name, int score,
      int maxScore, String description) {
    final percentage = (score / maxScore * 100).round();
    final color = percentage >= 70
        ? Colors.green
        : (percentage >= 40 ? Colors.orange : Colors.red);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '$score/$maxScore',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / maxScore,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoshaItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisItem(
      String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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

  Color _getScoreColor(int score) {
    if (score >= 24) return Colors.green;
    if (score >= 18) return Colors.lightGreen;
    if (score >= 12) return Colors.orange;
    return Colors.red;
  }

  String _getScoreInterpretation(BuildContext context, int score) {
    final l10n = AppLocalizations.of(context)!;
    if (score >= 28) return l10n.compatibility_result_excellent;
    if (score >= 24) return l10n.compatibility_result_very_good;
    if (score >= 18) return l10n.compatibility_result_good;
    if (score >= 12) return l10n.compatibility_result_average;
    return l10n.compatibility_result_challenging;
  }
}

class _CircularScorePainter extends CustomPainter {
  final int score;
  final int maxScore;
  final Color color;

  _CircularScorePainter({
    required this.score,
    required this.maxScore,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 12.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (score / maxScore) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
