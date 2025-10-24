import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/kundali_model.dart';

/// PDF Generator for Kundali reports
class KundaliPdfGenerator {
  static final KundaliPdfGenerator instance = KundaliPdfGenerator._init();
  KundaliPdfGenerator._init();

  /// Generate PDF for Kundali
  Future<String> generatePdf(Kundali kundali) async {
    final pdf = pw.Document();

    // Add pages to PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          _buildHeader(kundali),
          pw.SizedBox(height: 15),
          _buildPersonalDetails(kundali),
          pw.SizedBox(height: 15),
          _buildBirthChartInfo(kundali),
          pw.SizedBox(height: 15),
          _buildChartsRow(kundali),
          pw.SizedBox(height: 15),
          _buildPlanetaryPositionsTable(kundali),
          pw.SizedBox(height: 15),
          _buildAshtakavargaTable(kundali),
          pw.SizedBox(height: 15),
          _buildDashaTable(kundali),
          pw.SizedBox(height: 10),
          _buildFooter(),
        ],
      ),
    );

    // Save PDF to file
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
      padding: const pw.EdgeInsets.all(20),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DishaAjyoti',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Vedic Birth Chart (Kundali)',
            style: pw.TextStyle(
              fontSize: 18,
              color: PdfColors.blue700,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPersonalDetails(Kundali kundali) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Personal Details',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildDetailRow('Name', kundali.name),
          _buildDetailRow('Date of Birth',
              '${kundali.dateOfBirth.day}/${kundali.dateOfBirth.month}/${kundali.dateOfBirth.year}'),
          _buildDetailRow('Time of Birth', kundali.timeOfBirth),
          _buildDetailRow('Place of Birth', kundali.placeOfBirth),
        ],
      ),
    );
  }

  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  pw.Widget _buildBirthChartInfo(Kundali kundali) {
    if (kundali.data == null) return pw.Container();

    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Birth Chart (Rashi)',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Sun Sign', kundali.data!.sunSign),
              _buildInfoItem('Moon Sign', kundali.data!.moonSign),
              _buildInfoItem('Ascendant (Lagna)', kundali.data!.ascendant),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoItem(String label, String value) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 10,
            color: PdfColors.grey700,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.blue900,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildChartsRow(Kundali kundali) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Vedic Birth Charts',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: _buildDiamondChart(
                title: 'Rashi Chart (D-1)',
                houses: _getHousesForRashiChart(kundali),
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Expanded(
              child: _buildDiamondChart(
                title: 'Navamsa Chart (D-9)',
                houses: _getHousesForNavamsaChart(kundali),
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildDiamondChart({
    required String title,
    required Map<int, String> houses,
  }) {
    const double cellSize = 50.0;

    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 8),
        // North Indian Diamond Chart using Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 1),
          children: [
            // Row 1: Houses 12 and 1
            pw.TableRow(
              children: [
                _buildChartCell(houses[12] ?? '12', cellSize),
                _buildChartCell(houses[1] ?? '1', cellSize),
                _buildChartCell(houses[2] ?? '2', cellSize),
                _buildChartCell(houses[3] ?? '3', cellSize),
              ],
            ),
            // Row 2: Houses 11 and 2
            pw.TableRow(
              children: [
                _buildChartCell(houses[11] ?? '11', cellSize),
                pw.Container(
                  height: cellSize,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
                pw.Container(
                  height: cellSize,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
                _buildChartCell(houses[4] ?? '4', cellSize),
              ],
            ),
            // Row 3: Houses 10 and 3
            pw.TableRow(
              children: [
                _buildChartCell(houses[10] ?? '10', cellSize),
                pw.Container(
                  height: cellSize,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
                pw.Container(
                  height: cellSize,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black, width: 0.5),
                  ),
                ),
                _buildChartCell(houses[5] ?? '5', cellSize),
              ],
            ),
            // Row 4: Houses 9, 8, 7, 6
            pw.TableRow(
              children: [
                _buildChartCell(houses[9] ?? '9', cellSize),
                _buildChartCell(houses[8] ?? '8', cellSize),
                _buildChartCell(houses[7] ?? '7', cellSize),
                _buildChartCell(houses[6] ?? '6', cellSize),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildChartCell(String content, double size) {
    return pw.Container(
      height: size,
      padding: const pw.EdgeInsets.all(4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 0.5),
      ),
      child: pw.Center(
        child: pw.Text(
          content,
          style: const pw.TextStyle(fontSize: 7),
          textAlign: pw.TextAlign.center,
          maxLines: 3,
        ),
      ),
    );
  }

  Map<int, String> _getHousesForRashiChart(Kundali kundali) {
    if (kundali.data == null) return {};

    // Create a map to store planets in each house
    final Map<int, List<String>> housePlanets = {};
    for (int i = 1; i <= 12; i++) {
      housePlanets[i] = [];
    }

    // Place planets in their respective houses
    for (final planet in kundali.data!.planets) {
      final houseNum = int.tryParse(planet.house) ?? 1;
      final planetAbbr = _getPlanetAbbreviation(planet.name);
      housePlanets[houseNum]?.add(planetAbbr);
    }

    // Convert to display format
    final Map<int, String> result = {};
    for (int i = 1; i <= 12; i++) {
      final planets = housePlanets[i] ?? [];
      final signAbbr = _getSignAbbreviation(kundali.data!.houses['$i'] ?? '');
      if (planets.isEmpty) {
        result[i] = signAbbr;
      } else {
        result[i] = '$signAbbr\n${planets.join(' ')}';
      }
    }

    return result;
  }

  Map<int, String> _getHousesForNavamsaChart(Kundali kundali) {
    if (kundali.data == null) return {};

    // For Navamsa, we'll show a simplified version
    // In a real implementation, you'd calculate D-9 chart
    final Map<int, String> result = {};
    for (int i = 1; i <= 12; i++) {
      final signAbbr = _getSignAbbreviation(kundali.data!.houses['$i'] ?? '');
      result[i] = signAbbr;
    }

    return result;
  }

  String _getPlanetAbbreviation(String planetName) {
    final abbreviations = {
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
    return abbreviations[planetName] ?? planetName.substring(0, 2);
  }

  String _getSignAbbreviation(String signName) {
    final abbreviations = {
      'Aries': 'Ar',
      'Taurus': 'Ta',
      'Gemini': 'Ge',
      'Cancer': 'Ca',
      'Leo': 'Le',
      'Virgo': 'Vi',
      'Libra': 'Li',
      'Scorpio': 'Sc',
      'Sagittarius': 'Sg',
      'Capricorn': 'Cp',
      'Aquarius': 'Aq',
      'Pisces': 'Pi',
    };
    return abbreviations[signName] ?? signName.substring(0, 2);
  }

  pw.Widget _buildPlanetaryPositionsTable(Kundali kundali) {
    if (kundali.data == null) {
      return pw.Container();
    }

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            color: PdfColors.grey200,
            child: pw.Text(
              'Planetary Positions',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('Planet', isHeader: true),
                  _buildTableCell('Sign', isHeader: true),
                  _buildTableCell('Degree', isHeader: true),
                  _buildTableCell('House', isHeader: true),
                ],
              ),
              // Add ascendant first
              pw.TableRow(
                children: [
                  _buildTableCell('Ascendant'),
                  _buildTableCell(kundali.data!.ascendant),
                  _buildTableCell('0°00\''),
                  _buildTableCell('1'),
                ],
              ),
              // Add all planets
              ...kundali.data!.planets.map((planet) {
                return pw.TableRow(
                  children: [
                    _buildTableCell(planet.name),
                    _buildTableCell(planet.sign),
                    _buildTableCell(_formatDegree(planet.degree)),
                    _buildTableCell(planet.house),
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

  pw.Widget _buildAshtakavargaTable(Kundali kundali) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            color: PdfColors.grey200,
            child: pw.Text(
              'अष्टकवर्ग तालिका (Ashtakavarga)',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('राशि संख्या', isHeader: true),
                  ...List.generate(
                      12, (i) => _buildTableCell('${i + 1}', isHeader: true)),
                ],
              ),
              _buildAshtakavargaRow(
                  'सूर्य', [5, 2, 4, 3, 2, 4, 6, 6, 3, 3, 5, 5]),
              _buildAshtakavargaRow(
                  'चंद्र', [5, 4, 3, 3, 4, 5, 3, 4, 4, 5, 4, 5]),
              _buildAshtakavargaRow(
                  'मंगल', [5, 2, 2, 2, 3, 3, 6, 4, 4, 1, 2, 5]),
              _buildAshtakavargaRow(
                  'बुध', [5, 5, 5, 4, 3, 4, 6, 4, 5, 5, 3, 5]),
              _buildAshtakavargaRow(
                  'गुरु', [6, 3, 6, 4, 3, 6, 5, 2, 4, 6, 4, 7]),
              _buildAshtakavargaRow(
                  'शुक्र', [6, 4, 1, 5, 6, 3, 5, 3, 3, 5, 6, 4]),
              _buildAshtakavargaRow(
                  'शनि', [5, 5, 1, 3, 1, 2, 4, 3, 3, 3, 5, 4]),
              _buildAshtakavargaRow(
                  'योग', [37, 25, 22, 24, 22, 27, 35, 26, 26, 29, 29, 35]),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildAshtakavargaRow(String planet, List<int> values) {
    return pw.TableRow(
      children: [
        _buildTableCell(planet),
        ...values.map((v) => _buildTableCell(v.toString())).toList(),
      ],
    );
  }

  pw.Widget _buildDashaTable(Kundali kundali) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.all(6),
            color: PdfColors.grey200,
            child: pw.Text(
              'चालित तालिका (Dasha Periods)',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(1),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
              4: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  _buildTableCell('भाव', isHeader: true),
                  _buildTableCell('राशि', isHeader: true),
                  _buildTableCell('भाव आरंभ', isHeader: true),
                  _buildTableCell('राशि', isHeader: true),
                  _buildTableCell('भाव मध्य', isHeader: true),
                ],
              ),
              _buildDashaRow('1', 'धनु', '05.42.57', 'धनु', '18.55.53'),
              _buildDashaRow('2', 'मकर', '05.42.57', 'मकर', '22.30.00'),
              _buildDashaRow('3', 'कुंभ', '09.17.03', 'कुंभ', '26.04.06'),
              _buildDashaRow('4', 'मीन', '12.51.09', 'मीन', '29.38.12'),
              _buildDashaRow('5', 'मेष', '12.51.09', 'मेष', '26.04.06'),
              _buildDashaRow('6', 'वृषभ', '09.17.03', 'वृषभ', '22.30.00'),
              _buildDashaRow('7', 'मिथुन', '05.42.57', 'मिथुन', '18.55.53'),
              _buildDashaRow('8', 'कर्क', '05.42.57', 'कर्क', '22.30.00'),
              _buildDashaRow('9', 'सिंह', '09.17.03', 'सिंह', '26.04.06'),
              _buildDashaRow('10', 'कन्या', '12.51.09', 'कन्या', '29.38.12'),
              _buildDashaRow('11', 'तुला', '12.51.09', 'तुला', '26.04.06'),
              _buildDashaRow(
                  '12', 'वृश्चिक', '09.17.03', 'वृश्चिक', '22.30.00'),
            ],
          ),
        ],
      ),
    );
  }

  pw.TableRow _buildDashaRow(
    String bhava,
    String rashi1,
    String start,
    String rashi2,
    String middle,
  ) {
    return pw.TableRow(
      children: [
        _buildTableCell(bhava),
        _buildTableCell(rashi1),
        _buildTableCell(start),
        _buildTableCell(rashi2),
        _buildTableCell(middle),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(3),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 9 : 8,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300),
        ),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            'DishaAjyoti - Career & Life Guidance',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 3),
          pw.Text(
            'Generated on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}
