import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../providers/language_provider.dart';
import '../l10n/app_localizations.dart';

/// Settings screen for user preferences
///
/// Requirements: 5.5
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'English';
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value ? 'Notifications enabled' : 'Notifications disabled',
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _saveLanguageSetting(String language) async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    // Map display name to language code
    final Map<String, String> languageMap = {
      'English': 'en',
      'हिंदी': 'hi',
      'मराठी': 'mr',
      'தமிழ்': 'ta',
      'తెలుగు': 'te',
      'ಕನ್ನಡ': 'kn',
    };

    final languageCode = languageMap[language] ?? 'en';
    await languageProvider.setLanguage(languageCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', language);
    setState(() {
      _selectedLanguage = language;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Language changed to $language'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.settings_title,
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
            const SizedBox(height: 24),
            _buildLegalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            AppLocalizations.of(context)!.settings_preferences,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNotificationToggle(),
              const Divider(
                height: 1,
                color: AppColors.lightGray,
                indent: 16,
                endIndent: 16,
              ),
              _buildLanguageSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationToggle() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Receive updates and alerts',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
            activeThumbColor: AppColors.primaryOrange,
            activeTrackColor: AppColors.primaryOrange.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return InkWell(
      onTap: _showLanguageDialog,
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(16),
        bottomRight: Radius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.language,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Language',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _selectedLanguage,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = [
      'English',
      'हिंदी',
      'मराठी',
      'தமிழ்',
      'తెలుగు',
      'ಕನ್ನಡ',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Select Language',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
          content: SizedBox(
            width: double.maxFinite,
            height: 400, // Fixed height to ensure all languages are visible
            child: ListView.separated(
              shrinkWrap: false,
              physics: const BouncingScrollPhysics(),
              itemCount: languages.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                return _buildLanguageOption(languages[index]);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language) {
    final isSelected = _selectedLanguage == language;

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _saveLanguageSetting(language);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                language,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primaryOrange,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'About',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.info_outline,
                title: 'About DishaAjyoti',
                subtitle: 'Learn more about our app',
                onTap: _showAboutDialog,
              ),
              const Divider(
                height: 1,
                color: AppColors.lightGray,
                indent: 16,
                endIndent: 16,
              ),
              _buildSettingsItem(
                icon: Icons.star_outline,
                title: 'Version',
                subtitle: '1.0.0',
                onTap: null,
                showChevron: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Legal',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.description_outlined,
                title: 'Terms & Conditions',
                subtitle: 'Read our terms of service',
                onTap: _showTermsAndConditions,
              ),
              const Divider(
                height: 1,
                color: AppColors.lightGray,
                indent: 16,
                endIndent: 16,
              ),
              _buildSettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                subtitle: 'How we handle your data',
                onTap: _showPrivacyPolicy,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (showChevron)
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'About DishaAjyoti',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DishaAjyoti is your trusted companion for career and life guidance through ancient wisdom and modern technology.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Our Services:',
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAboutListItem('✋ Palmistry Reading'),
                _buildAboutListItem('⭐ Vedic Jyotish Analysis'),
                _buildAboutListItem('🔢 Numerology Reports'),
                const SizedBox(height: 16),
                Text(
                  'Version 1.0.0',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Close',
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAboutListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        text,
        style: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    _showLegalDialog(
      title: 'Terms & Conditions',
      content: '''
Welcome to DishaAjyoti. By using our app, you agree to these terms and conditions.

1. Service Usage
You agree to use our services for lawful purposes only. Our palmistry, Vedic Jyotish, and numerology services are provided for guidance and entertainment purposes.

2. User Accounts
You are responsible for maintaining the confidentiality of your account credentials. You must provide accurate information during registration.

3. Payments
All payments are processed securely through our payment gateway. Prices are displayed in Indian Rupees (INR) and are subject to change.

4. Reports
Generated reports are for personal use only. You may not redistribute or resell the reports without permission.

5. Intellectual Property
All content, including reports, designs, and text, is owned by DishaAjyoti and protected by copyright laws.

6. Limitation of Liability
Our services are provided "as is" without warranties. We are not liable for any decisions made based on our reports.

7. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of modified terms.

8. Contact
For questions about these terms, please contact us at support@dishaajyoti.com.

Last updated: October 2024
''',
    );
  }

  void _showPrivacyPolicy() {
    _showLegalDialog(
      title: 'Privacy Policy',
      content: '''
DishaAjyoti is committed to protecting your privacy. This policy explains how we collect, use, and safeguard your information.

1. Information We Collect
- Personal information (name, email, phone number)
- Birth details (date, time, place of birth)
- Career information and goals
- Payment information (processed securely)
- Device information and usage data

2. How We Use Your Information
- To provide palmistry, Vedic Jyotish, and numerology services
- To generate personalized reports
- To process payments
- To send notifications about your reports
- To improve our services

3. Data Security
We use industry-standard encryption to protect your data. Payment information is processed through secure payment gateways and is not stored on our servers.

4. Data Sharing
We do not sell or share your personal information with third parties except:
- Payment processors for transaction processing
- AI services for report generation
- As required by law

5. Your Rights
You have the right to:
- Access your personal data
- Request data correction or deletion
- Opt-out of notifications
- Export your data

6. Data Retention
We retain your data for as long as your account is active. You may request account deletion at any time.

7. Cookies and Tracking
We use cookies and similar technologies to improve user experience and analyze app usage.

8. Children's Privacy
Our services are not intended for users under 18 years of age.

9. Changes to Privacy Policy
We may update this policy periodically. We will notify you of significant changes.

10. Contact Us
For privacy concerns, contact us at privacy@dishaajyoti.com.

Last updated: October 2024
''',
    );
  }

  void _showLegalDialog({
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Text(
                content,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Close',
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
