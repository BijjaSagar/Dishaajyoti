import 'package:flutter/material.dart';
import '../models/chart_data_model.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Kundali Chart Widget
/// Wrapper for chart visualization with app theming
class KundaliChartWidget extends StatefulWidget {
  final ChartData chartData;
  final double size;
  final bool showLegend;
  final Function(ChartPlanet)? onPlanetTap;

  const KundaliChartWidget({
    Key? key,
    required this.chartData,
    this.size = 300,
    this.showLegend = true,
    this.onPlanetTap,
  }) : super(key: key);

  @override
  State<KundaliChartWidget> createState() => _KundaliChartWidgetState();
}

class _KundaliChartWidgetState extends State<KundaliChartWidget> {
  ChartPlanet? _selectedPlanet;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Chart display
        GestureDetector(
          onTapDown: (details) => _handleTap(details.localPosition),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: widget.chartData.style == ChartStyle.northIndian
                ? _buildNorthIndianChart()
                : _buildSouthIndianChart(),
          ),
        ),

        // Selected planet info
        if (_selectedPlanet != null) ...[
          const SizedBox(height: 12),
          _buildPlanetInfo(_selectedPlanet!),
        ],

        // Legend
        if (widget.showLegend) ...[
          const SizedBox(height: 16),
          _buildLegend(),
        ],
      ],
    );
  }

  void _handleTap(Offset position) {
    // Simple tap detection - find nearest planet
    // In production, implement proper hit testing
    if (widget.onPlanetTap != null && widget.chartData.planets.isNotEmpty) {
      setState(() {
        _selectedPlanet = widget.chartData.planets.first;
      });
      widget.onPlanetTap!(_selectedPlanet!);
    }
  }

  /// Build North Indian style chart (diamond shape)
  Widget _buildNorthIndianChart() {
    return CustomPaint(
      painter: NorthIndianChartPainter(widget.chartData),
      size: Size(widget.size, widget.size),
    );
  }

  /// Build South Indian style chart (square with diagonals)
  Widget _buildSouthIndianChart() {
    return CustomPaint(
      painter: SouthIndianChartPainter(widget.chartData),
      size: Size(widget.size, widget.size),
    );
  }

  /// Build planet info card
  Widget _buildPlanetInfo(ChartPlanet planet) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryOrange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                planet.symbol,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                planet.name,
                style: AppTypography.h3.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              if (planet.isRetrograde) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Sign: ${planet.sign} | House: ${planet.house} | Degree: ${planet.degree.toStringAsFixed(2)}°',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build legend showing planet symbols
  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Planet Legend',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: widget.chartData.planets.map((planet) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlanet = planet;
                  });
                  if (widget.onPlanetTap != null) {
                    widget.onPlanetTap!(planet);
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      planet.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      planet.name,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (planet.isRetrograde)
                      Text(
                        ' (R)',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// North Indian Chart Painter
class NorthIndianChartPainter extends CustomPainter {
  final ChartData chartData;

  NorthIndianChartPainter(this.chartData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    // Draw diamond shape (rotated square)
    final path = Path();
    path.moveTo(center.dx, center.dy - radius); // Top
    path.lineTo(center.dx + radius, center.dy); // Right
    path.lineTo(center.dx, center.dy + radius); // Bottom
    path.lineTo(center.dx - radius, center.dy); // Left
    path.close();

    canvas.drawPath(path, paint);

    // Draw internal divisions (12 houses)
    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      paint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      paint,
    );

    // Draw house numbers and planets
    _drawHousesAndPlanets(canvas, center, radius);
  }

  void _drawHousesAndPlanets(Canvas canvas, Offset center, double radius) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // House positions in North Indian chart (clockwise from top)
    final housePositions = [
      Offset(center.dx, center.dy - radius * 0.7), // 1 - Top
      Offset(center.dx + radius * 0.5, center.dy - radius * 0.5), // 2
      Offset(center.dx + radius * 0.7, center.dy), // 3 - Right
      Offset(center.dx + radius * 0.5, center.dy + radius * 0.5), // 4
      Offset(center.dx, center.dy + radius * 0.7), // 5 - Bottom
      Offset(center.dx - radius * 0.5, center.dy + radius * 0.5), // 6
      Offset(center.dx - radius * 0.7, center.dy), // 7 - Left
      Offset(center.dx - radius * 0.5, center.dy - radius * 0.5), // 8
      Offset(center.dx - radius * 0.3, center.dy - radius * 0.3), // 9
      Offset(center.dx + radius * 0.3, center.dy - radius * 0.3), // 10
      Offset(center.dx + radius * 0.3, center.dy + radius * 0.3), // 11
      Offset(center.dx - radius * 0.3, center.dy + radius * 0.3), // 12
    ];

    for (int i = 0; i < 12; i++) {
      final houseNumber = i + 1;

      // Draw house number
      textPainter.text = TextSpan(
        text: houseNumber.toString(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          housePositions[i].dx - textPainter.width / 2,
          housePositions[i].dy - textPainter.height - 5,
        ),
      );

      // Draw planets in this house
      final planetsInHouse =
          chartData.planets.where((p) => p.house == houseNumber).toList();

      if (planetsInHouse.isNotEmpty) {
        final planetText = planetsInHouse
            .map((p) => p.isRetrograde ? '${p.symbol}R' : p.symbol)
            .join(' ');

        textPainter.text = TextSpan(
          text: planetText,
          style: const TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            housePositions[i].dx - textPainter.width / 2,
            housePositions[i].dy + 5,
          ),
        );
      }
    }

    // Mark ascendant
    textPainter.text = const TextSpan(
      text: 'ASC ↑',
      style: TextStyle(
        color: AppColors.success,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - radius - 25,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// South Indian Chart Painter
class SouthIndianChartPainter extends CustomPainter {
  final ChartData chartData;

  SouthIndianChartPainter(this.chartData);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final padding = 20.0;
    final rect = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );

    // Draw outer square
    canvas.drawRect(rect, paint);

    // Draw diagonals
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.topRight, rect.bottomLeft, paint);

    // Draw middle horizontal and vertical lines
    canvas.drawLine(
      Offset(rect.left, rect.center.dy),
      Offset(rect.right, rect.center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(rect.center.dx, rect.top),
      Offset(rect.center.dx, rect.bottom),
      paint,
    );

    // Draw houses and planets
    _drawHousesAndPlanets(canvas, rect);
  }

  void _drawHousesAndPlanets(Canvas canvas, Rect rect) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate ascendant house position
    final ascendantSignNumber =
        ZodiacSignInfo.getSignNumber(chartData.ascendant);

    // House positions in South Indian chart (fixed signs)
    final housePositions = _getSouthIndianHousePositions(rect);

    for (int i = 0; i < 12; i++) {
      final houseNumber = i + 1;

      // Calculate position based on ascendant
      final positionIndex = (houseNumber + ascendantSignNumber - 2) % 12;
      final position = housePositions[positionIndex];

      // Draw house number
      textPainter.text = TextSpan(
        text: houseNumber.toString(),
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - 15,
        ),
      );

      // Draw planets in this house
      final planetsInHouse =
          chartData.planets.where((p) => p.house == houseNumber).toList();

      if (planetsInHouse.isNotEmpty) {
        final planetText = planetsInHouse
            .map((p) => p.isRetrograde ? '${p.symbol}R' : p.symbol)
            .join(' ');

        textPainter.text = TextSpan(
          text: planetText,
          style: const TextStyle(
            color: AppColors.primaryOrange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            position.dx - textPainter.width / 2,
            position.dy + 5,
          ),
        );
      }
    }
  }

  List<Offset> _getSouthIndianHousePositions(Rect rect) {
    final centerX = rect.center.dx;
    final centerY = rect.center.dy;
    final quarterWidth = rect.width / 4;
    final quarterHeight = rect.height / 4;

    return [
      Offset(centerX - quarterWidth, centerY - quarterHeight), // 1
      Offset(centerX, rect.top + 30), // 2
      Offset(centerX + quarterWidth, centerY - quarterHeight), // 3
      Offset(rect.right - 30, centerY - quarterHeight), // 4
      Offset(rect.right - 30, centerY), // 5
      Offset(rect.right - 30, centerY + quarterHeight), // 6
      Offset(centerX + quarterWidth, centerY + quarterHeight), // 7
      Offset(centerX, rect.bottom - 30), // 8
      Offset(centerX - quarterWidth, centerY + quarterHeight), // 9
      Offset(rect.left + 30, centerY + quarterHeight), // 10
      Offset(rect.left + 30, centerY), // 11
      Offset(rect.left + 30, centerY - quarterHeight), // 12
    ];
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
