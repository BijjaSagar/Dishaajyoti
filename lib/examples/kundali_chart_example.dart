/// Example usage of kundali_chart package
/// This file demonstrates the package API and available widgets
///
/// Package: kundali_chart ^0.0.2
/// Purpose: Visualize Vedic astrology birth charts
///
/// Key Features:
/// - North Indian and South Indian chart styles
/// - Planet positioning in houses
/// - Customizable colors and styling
/// - Responsive sizing
///
/// Usage Notes:
/// - The package requires chart data in specific format
/// - Planet positions should be in degrees (0-360)
/// - Houses are numbered 1-12
/// - Supports both tropical and sidereal systems

import 'package:flutter/material.dart';
import 'package:kundali_chart/kundali_chart.dart';

/// Example demonstrating kundali_chart package usage
class KundaliChartExample extends StatelessWidget {
  const KundaliChartExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample chart data for demonstration
    // In production, this data comes from VedicKundaliCalculator

    final samplePlanets = [
      ChartPlanet(
        name: 'Sun',
        longitude: 45.5, // Degrees in zodiac
        house: 2,
        isRetrograde: false,
      ),
      ChartPlanet(
        name: 'Moon',
        longitude: 120.3,
        house: 5,
        isRetrograde: false,
      ),
      ChartPlanet(
        name: 'Mars',
        longitude: 200.7,
        house: 8,
        isRetrograde: true,
      ),
      // Add more planets as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kundali Chart Example'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // North Indian Style Chart
            const Text(
              'North Indian Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: KundaliChart(
                planets: samplePlanets,
                ascendant: 30.0, // Lagna at 30 degrees
                style: ChartStyle.northIndian,
                size: 280,
              ),
            ),
            const SizedBox(height: 32),

            // South Indian Style Chart
            const Text(
              'South Indian Style',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: KundaliChart(
                planets: samplePlanets,
                ascendant: 30.0,
                style: ChartStyle.southIndian,
                size: 280,
              ),
            ),
            const SizedBox(height: 32),

            // Package Capabilities
            const Text(
              'Package Capabilities:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '✓ North Indian diamond-shaped chart\n'
              '✓ South Indian square chart with diagonals\n'
              '✓ Automatic planet positioning\n'
              '✓ Retrograde indicators\n'
              '✓ Customizable colors and sizing\n'
              '✓ Responsive layout\n'
              '✓ House numbering\n'
              '✓ Sign placement',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 32),

            // Limitations
            const Text(
              'Known Limitations:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Requires manual planet position calculation\n'
              '• Limited customization of planet symbols\n'
              '• No built-in aspect lines\n'
              '• No interactive tooltips (need custom implementation)\n'
              '• Fixed layout structure',
              style: TextStyle(fontSize: 14, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sample ChartPlanet class structure
/// (Actual implementation may vary based on package version)
class ChartPlanet {
  final String name;
  final double longitude;
  final int house;
  final bool isRetrograde;

  ChartPlanet({
    required this.name,
    required this.longitude,
    required this.house,
    this.isRetrograde = false,
  });
}

/// Sample ChartStyle enum
/// (Actual implementation may vary based on package version)
enum ChartStyle {
  northIndian,
  southIndian,
}

/// Sample KundaliChart widget signature
/// (Actual implementation from package)
class KundaliChart extends StatelessWidget {
  final List<ChartPlanet> planets;
  final double ascendant;
  final ChartStyle style;
  final double size;

  const KundaliChart({
    Key? key,
    required this.planets,
    required this.ascendant,
    required this.style,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is a placeholder - actual implementation comes from package
    return Center(
      child: Text(
        'Kundali Chart\n${style.name}\nAscendant: ${ascendant}°',
        textAlign: TextAlign.center,
      ),
    );
  }
}
