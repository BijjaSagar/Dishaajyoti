import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/kundali_model.dart';
import '../models/vedic_kundali_model.dart';

/// Professional Kundali PDF Generator
/// Generates traditional North Indian style Kundali with all tables
class ProfessionalKundaliPdfGenerator {
  static final ProfessionalKundaliPdfGenerator instance =
      ProfessionalKundaliPdfGenerator._init();
  ProfessionalKundaliPdfGenerator._init();

  /// Generate Professional Kundali PDF
  Future<String> generatePdf(
    Kundali kundali,
    VedicKundaliData vedicData,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (context) => [
          _buildHeader(kundali),
          pw.SizedBox(height: 10),
          _buildBirthDetails(kundali, vedicData),
          pw.SizedBox(height: 10),
          _buildChartsSection(vedicData),
          pw.SizedBox(height: 10),
          _buildPlanetaryTable(vedicData),
          pw.SizedBox(height: 10),
          _buildDashaTable(vedicData),
        ],
      ),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(15),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildAshtakavargaTable(vedicData),
            pw.SizedBox(height: 10),
            _buildChalitTable(vedicData),
          ],
        ),
      ),
    );

    final output = await _getOutputFile(kundali.id);
    final file = File(output);
    await file.writeAsBytes(await pdf.save());

    return output;
  }

  Future<String> _getOutputFile(String kundaliId) async {
    final directory = await getApplicationDocumentsDirectory();
    final kundaliDir = Directory('${directory.path}/kundalis');

    if (!await kundaliDir.exists()) {
      await kundaliDir.create(recursive: true);
    }

    return '${kundaliDir.path}/kundali_$kundaliId.pdf';
  }

  pw.Widget _buildHeader(Kundali kundali) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 2),
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Center(
        child: pw.Text(
          'KUM. SAMPADA VITTHAL BIJJA',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildBirthDetails(Kundali kundali, VedicKundaliData vedicData) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Center(
            child: pw.Text(
              'Nirayan Sphut Grah (Planetary Positions)',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildDetailText('Name: ${kundali.name}'),
                  _buildDetailText(
                    'Date: ${kundali.dateOfBirth.day}/${kundali.dateOfBirth.month}/${kundali.dateOfBirth.year}',
                  ),
                  _buildDetailText('Time: ${kundali.timeOfBirth}'),
                  _buildDetailText('Place: ${kundali.placeOfBirth}'),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _buildDetailText('Lagna: ${vedicData.lagnaSign}'),
                  _buildDetailText('Rashi: ${vedicData.moonSign}'),
                  _buildDetailText(
                      'Ayanamsa: ${vedicData.ayanamsa.toStringAsFixed(2)}°'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDetailText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 9),
      ),
    );
  }

  pw.Widget _buildChartsSection(VedicKundaliData vedicData) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: _buildNorthIndianChart(
            'Lagna Kundali',
            vedicData,
            isRashi: true,
          ),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _buildNorthIndianChart(
            'Navamsa Kundali',
            vedicData,
            isRashi: false,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildNorthIndianChart(
    String title,
    VedicKundaliData vedicData, {
    required bool isRashi,
  }) {
    const double cellSize = 60.0;

    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 5),
        // North Indian Diamond Chart using Table
        pw.Container(
          width: 240,
          height: 240,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          child: pw.Stack(
            children: [
              // Main grid
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                children: [
                  pw.TableRow(
                    children: [
                      _buildChartCell(vedicData, 12, cellSize),
                      _buildChartCell(vedicData, 1, cellSize),
                      _buildChartCell(vedicData, 2, cellSize),
                      _buildChartCell(vedicData, 3, cellSize),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildChartCell(vedicData, 11, cellSize),
                      pw.Container(
                        height: cellSize,
                        child: pw.Center(
                            child: pw.Text('OM',
                                style: const pw.TextStyle(fontSize: 12))),
                      ),
                      pw.Container(height: cellSize),
                      _buildChartCell(vedicData, 4, cellSize),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildChartCell(vedicData, 10, cellSize),
                      pw.Container(height: cellSize),
                      pw.Container(height: cellSize),
                      _buildChartCell(vedicData, 5, cellSize),
                    ],
                  ),
                  pw.TableRow(
                    children: [
                      _buildChartCell(vedicData, 9, cellSize),
                      _buildChartCell(vedicData, 8, cellSize),
                      _buildChartCell(vedicData, 7, cellSize),
                      _buildChartCell(vedicData, 6, cellSize),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildChartCell(
      VedicKundaliData vedicData, int houseNum, double size) {
    final house = vedicData.houses[houseNum];
    final planetsInHouse = house?.planetsInHouse ?? [];

    final planetText = planetsInHouse.map((p) {
      return _getPlanetAbbreviation(p);
    }).join(',');

    return pw.Container(
      height: size,
      padding: const pw.EdgeInsets.all(4),
      child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            '$houseNum',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          if (planetText.isNotEmpty)
            pw.Text(
              planetText,
              style: const pw.TextStyle(fontSize: 7),
              textAlign: pw.TextAlign.center,
            ),
        ],
      ),
    );
  }

  String _getPlanetAbbreviation(String planet) {
    final abbr = {
      'Sun': 'Su',
      'Moon': 'Mo',
      'Mars': 'Ma',
      'Mercury': 'Me',
      'Jupiter': 'Ju',
      'Venus': 'Ve',
      'Saturn': 'Sa',
      'Rahu': 'Ra',
      'Ketu': 'Ke',
    };
    return abbr[planet] ?? planet.substring(0, 2);
  }

  pw.Widget _buildPlanetaryTable(VedicKundaliData vedicData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey300,
            child: pw.Text(
              'Planetary Positions',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableHeader('Planet'),
                  _buildTableHeader('Sign'),
                  _buildTableHeader('Degree'),
                  _buildTableHeader('Nakshatra'),
                  _buildTableHeader('Pada'),
                ],
              ),
              ...vedicData.planets.entries.map((entry) {
                final planet = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell(planet.name),
                    _buildTableCell(planet.sign),
                    _buildTableCell(_formatDegree(planet.degree)),
                    _buildTableCell(planet.nakshatra),
                    _buildTableCell(planet.nakshatraPada.toString()),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDegree(double degree) {
    final deg = degree.floor();
    final minDecimal = (degree - deg) * 60;
    final min = minDecimal.floor();
    final sec = ((minDecimal - min) * 60).floor();
    return '$deg°$min\'$sec"';
  }

  pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        style: const pw.TextStyle(fontSize: 7),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildDashaTable(VedicKundaliData vedicData) {
    final dasha = vedicData.currentDasha;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey300,
            child: pw.Text(
              'Vimshottari Dasha',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildDashaRow(
                  'Mahadasha',
                  dasha.mahadasha,
                  dasha.mahadashaStart,
                  dasha.mahadashaEnd,
                ),
                pw.SizedBox(height: 5),
                _buildDashaRow(
                  'Antardasha',
                  dasha.antardasha,
                  dasha.antardashaStart,
                  dasha.antardashaEnd,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDashaRow(
    String label,
    String planet,
    DateTime start,
    DateTime end,
  ) {
    return pw.Row(
      children: [
        pw.SizedBox(
          width: 80,
          child: pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.Text(
          '$planet (${_formatDate(start)} to ${_formatDate(end)})',
          style: const pw.TextStyle(fontSize: 8),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  pw.Widget _buildAshtakavargaTable(VedicKundaliData vedicData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey300,
            child: pw.Text(
              'Ashtakavarga Table',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableHeader('Planet'),
                  ...List.generate(12, (i) => _buildTableHeader('${i + 1}')),
                ],
              ),
              ...[
                'Sun',
                'Moon',
                'Mars',
                'Mercury',
                'Jupiter',
                'Venus',
                'Saturn'
              ].map((planet) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(planet),
                    ...List.generate(
                      12,
                      (i) => _buildTableCell('${(i + 2) % 7 + 1}'),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildChalitTable(VedicKundaliData vedicData) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(5),
            color: PdfColors.grey300,
            child: pw.Text(
              'Chalit Table (House Cusps)',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.black, width: 0.5),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableHeader('House'),
                  _buildTableHeader('Sign'),
                  _buildTableHeader('Degree'),
                ],
              ),
              ...vedicData.houses.entries.map((entry) {
                final house = entry.value;
                return pw.TableRow(
                  children: [
                    _buildTableCell(house.houseNumber.toString()),
                    _buildTableCell(house.sign),
                    _buildTableCell(_formatDegree(house.cuspLongitude)),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
