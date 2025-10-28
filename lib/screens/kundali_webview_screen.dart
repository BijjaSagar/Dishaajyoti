import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../l10n/app_localizations.dart';

/// WebView screen to generate Kundali using online services
/// Uses popular Kundali generators like AstroSage, mPanchang, etc.
class KundaliWebViewScreen extends StatefulWidget {
  final String name;
  final DateTime dateOfBirth;
  final String timeOfBirth;
  final String placeOfBirth;

  const KundaliWebViewScreen({
    super.key,
    required this.name,
    required this.dateOfBirth,
    required this.timeOfBirth,
    required this.placeOfBirth,
  });

  @override
  State<KundaliWebViewScreen> createState() => _KundaliWebViewScreenState();
}

class _KundaliWebViewScreenState extends State<KundaliWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _selectedService = 'astrosage';

  final Map<String, String> _services = {
    'astrosage': 'https://www.astrosage.com/free-kundli.asp',
    'mpanchang': 'https://www.mpanchang.com/freekundali/',
    'ganeshaspeaks': 'https://www.ganeshaspeaks.com/astrology/free-kundli/',
    'clickastro': 'https://www.clickastro.com/free-horoscope/',
  };

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
            _autoFillForm();
          },
        ),
      )
      ..loadRequest(Uri.parse(_services[_selectedService]!));
  }

  void _autoFillForm() {
    // Auto-fill the form with user's birth details
    final script = '''
      // Try to find and fill common form fields
      var nameField = document.querySelector('input[name*="name"], input[id*="name"]');
      if (nameField) nameField.value = "${widget.name}";
      
      var dayField = document.querySelector('select[name*="day"], input[name*="day"]');
      if (dayField) dayField.value = "${widget.dateOfBirth.day}";
      
      var monthField = document.querySelector('select[name*="month"], input[name*="month"]');
      if (monthField) monthField.value = "${widget.dateOfBirth.month}";
      
      var yearField = document.querySelector('select[name*="year"], input[name*="year"]');
      if (yearField) yearField.value = "${widget.dateOfBirth.year}";
      
      var placeField = document.querySelector('input[name*="place"], input[name*="city"]');
      if (placeField) placeField.value = "${widget.placeOfBirth}";
    ''';

    _controller.runJavaScript(script);
  }

  void _changeService(String service) {
    setState(() {
      _selectedService = service;
      _isLoading = true;
    });
    _controller.loadRequest(Uri.parse(_services[service]!));
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
          l10n.kundali_webview_title,
          style: AppTypography.h3.copyWith(
            color: AppColors.primaryBlue,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.primaryBlue),
            onSelected: _changeService,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'astrosage',
                child: Text(l10n.kundali_webview_astrosage),
              ),
              PopupMenuItem(
                value: 'mpanchang',
                child: Text(l10n.kundali_webview_mpanchang),
              ),
              PopupMenuItem(
                value: 'ganeshaspeaks',
                child: Text(l10n.kundali_webview_ganeshaspeaks),
              ),
              PopupMenuItem(
                value: 'clickastro',
                child: Text(l10n.kundali_webview_clickastro),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryOrange,
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.kundali_webview_fill_details,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.kundali_webview_download_pdf,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
