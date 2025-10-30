import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/service_model.dart';
import '../models/report_model.dart';
import '../widgets/cards/service_card.dart';
import '../widgets/cards/report_card.dart';
import '../providers/notification_provider.dart';
import '../services/firebase/firebase_service_manager.dart';
import 'notifications_screen.dart';
import 'settings_screen.dart';
import 'kundali_list_screen.dart';
import 'kundali_options_screen.dart';
import 'order_confirmation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedBottomNav = 0;

  // Mock data for featured services
  final List<Service> _featuredServices = [
    Service(
      id: '0',
      name: 'Free Kundali',
      description:
          'Get your complete Vedic birth chart with planetary positions and basic predictions',
      category: 'Astrology',
      price: 0,
      currency: 'INR',
      icon: '🌟',
      features: [
        'Complete birth chart (Rashi)',
        'Planetary positions in houses',
        'Vimshottari Dasha periods',
        'Basic life predictions',
        'Lagna and Moon sign analysis',
      ],
      estimatedTime: 'Instant',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '1',
      name: 'AI Kundali Analysis',
      description:
          'Comprehensive AI-powered Vedic astrology report with detailed predictions and remedies',
      category: 'Astrology',
      price: 0, // FREE FOR TESTING (normally 499)
      currency: 'INR',
      icon: '⭐',
      features: [
        'Detailed birth chart analysis',
        'Career, marriage & health predictions',
        'Planetary yogas identification',
        'Personalized remedies & gemstones',
        'Professional PDF report',
      ],
      estimatedTime: '24-48 hours',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '2',
      name: 'Palmistry Reading',
      description: 'AI-powered palm reading analysis from your hand images',
      category: 'Palmistry',
      price: 0, // FREE FOR TESTING (normally 299)
      currency: 'INR',
      icon: '✋',
      features: [
        'Major palm lines analysis',
        'Mount and finger interpretation',
        'Health & longevity insights',
        'Career and relationship guidance',
        'Detailed PDF report',
      ],
      estimatedTime: '24 hours',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '3',
      name: 'Numerology Report',
      description:
          'Discover your life path and destiny through the power of numbers',
      category: 'Numerology',
      price: 0, // FREE FOR TESTING (normally 199)
      currency: 'INR',
      icon: '🔢',
      features: [
        'Life path number calculation',
        'Destiny & soul urge numbers',
        'Lucky numbers and colors',
        'Name compatibility analysis',
        'Personalized recommendations',
      ],
      estimatedTime: '12 hours',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Service(
      id: '4',
      name: 'Marriage Compatibility',
      description: 'Check Ashtakoot matching and compatibility for marriage',
      category: 'Compatibility',
      price: 0, // FREE FOR TESTING (normally 399)
      currency: 'INR',
      icon: '💑',
      features: [
        'Ashtakoot matching (36 points)',
        'Mangal Dosha analysis',
        'Mental & physical compatibility',
        'Relationship predictions',
        'Remedies for low compatibility',
      ],
      estimatedTime: '24 hours',
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];

  // User data from Firebase Auth
  String _userName = 'User';
  String _userEmail = '';
  String _userPhone = '';
  final int _reportsCount = 3;
  final int _amountSpent = 997;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = FirebaseServiceManager.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? user.email?.split('@')[0] ?? 'User';
        _userEmail = user.email ?? '';
        _userPhone = user.phoneNumber ?? '';
      });
    }
  }

  // Mock reports data
  final List<Report> _reports = [
    Report(
      id: '1',
      userId: 'user123',
      serviceId: '1',
      paymentId: 'pay123',
      fileName: 'palmistry_report_2024.pdf',
      fileUrl: 'https://example.com/reports/palmistry_report_2024.pdf',
      fileSize: 2457600, // 2.4 MB
      status: ReportStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Report(
      id: '2',
      userId: 'user123',
      serviceId: '2',
      paymentId: 'pay124',
      fileName: 'vedic_jyotish_report_2024.pdf',
      fileUrl: 'https://example.com/reports/vedic_jyotish_report_2024.pdf',
      fileSize: 3145728, // 3 MB
      status: ReportStatus.ready,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Report(
      id: '3',
      userId: 'user123',
      serviceId: '3',
      paymentId: 'pay125',
      fileName: 'numerology_report_2024.pdf',
      fileUrl: 'https://example.com/reports/numerology_report_2024.pdf',
      fileSize: 1572864, // 1.5 MB
      status: ReportStatus.generating,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: Text(
        'DishaAjyoti',
        style: AppTypography.h3.copyWith(
          color: AppColors.primaryBlue,
        ),
      ),
      actions: [
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, child) {
            final unreadCount = notificationProvider.unreadCount;

            return Semantics(
              button: true,
              label: unreadCount > 0
                  ? 'Notifications, $unreadCount unread'
                  : 'Notifications',
              hint: 'Double tap to view notifications',
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                      // Reload unread count after returning from notifications screen
                      notificationProvider.loadUnreadCount();
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Semantics(
                        label: '$unreadCount unread notifications',
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unreadCount > 99 ? '99+' : unreadCount.toString(),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedBottomNav) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildServicesTab();
      case 2:
        return _buildReportsTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeBanner(),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildFeaturedServices(),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userName,
            style: AppTypography.h1.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedBottomNav = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'Explore Services',
                style: AppTypography.button.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.description,
            label: 'Reports',
            value: _reportsCount.toString(),
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.currency_rupee,
            label: 'Spent',
            value: '₹$_amountSpent',
            color: AppColors.primaryOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.h2.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedServices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Services',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedBottomNav = 1;
                });
              },
              child: Text(
                'View All',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Optimized: Use ListView.builder with lazy loading
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _featuredServices.length,
          itemBuilder: (context, index) {
            final service = _featuredServices[index];
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < _featuredServices.length - 1 ? 16 : 0),
              child: ServiceCard(
                key: ValueKey(service.id),
                service: service,
                onTap: () {
                  _handleServiceSelection(service);
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildServicesTab() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Our Services',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose the service that best fits your needs',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Optimized: Use SliverList for better performance with lazy loading
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final service = _featuredServices[index];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < _featuredServices.length - 1 ? 16 : 0),
                  child: ServiceCard(
                    key: ValueKey(service.id),
                    service: service,
                    onTap: () {
                      _handleServiceSelection(service);
                    },
                  ),
                );
              },
              childCount: _featuredServices.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  void _handleServiceSelection(Service service) {
    // In testing mode, bypass payment for all services
    if (Service.testingMode || service.isFree) {
      // Navigate directly to service screens for testing
      switch (service.id) {
        case '0': // Free Kundali
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KundaliOptionsScreen(service: service),
            ),
          );
          break;
        case '1': // AI Kundali Analysis
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => KundaliOptionsScreen(service: service),
            ),
          );
          break;
        case '2': // Palmistry Reading
          // TODO: Navigate to palmistry upload screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Palmistry service - Coming soon!'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          break;
        case '3': // Numerology Report
          // TODO: Navigate to numerology input screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Numerology service - Coming soon!'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          break;
        case '4': // Marriage Compatibility
          // TODO: Navigate to compatibility check screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compatibility service - Coming soon!'),
              backgroundColor: AppColors.primaryOrange,
            ),
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service not yet implemented'),
              backgroundColor: AppColors.warning,
            ),
          );
      }
    } else {
      // Production mode - navigate to payment
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(service: service),
        ),
      );
    }
  }

  Widget _buildReportsTab() {
    if (_reports.isEmpty) {
      return _buildEmptyReportsState();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Reports',
                  style: AppTypography.h1.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'View and download your generated reports',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        // Optimized: Use SliverList for better performance with lazy loading
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final report = _reports[index];
                final serviceName = _getServiceName(report.serviceId);
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: index < _reports.length - 1 ? 16 : 0),
                  child: ReportCard(
                    key: ValueKey(report.id),
                    report: report,
                    serviceName: serviceName,
                    onTap: () {
                      _handleReportSelection(report);
                    },
                  ),
                );
              },
              childCount: _reports.length,
            ),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 16)),
      ],
    );
  }

  Widget _buildEmptyReportsState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: AppColors.lightGray,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.description_outlined,
                size: 80,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Reports Yet',
              style: AppTypography.h2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You haven\'t generated any reports yet.\nExplore our services to get started!',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedBottomNav = 1;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Browse Services',
                  style: AppTypography.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getServiceName(String serviceId) {
    final service = _featuredServices.firstWhere(
      (s) => s.id == serviceId,
      orElse: () => _featuredServices[0],
    );
    return service.name;
  }

  void _handleReportSelection(Report report) {
    if (report.status == ReportStatus.ready) {
      // TODO: Navigate to report detail screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening report: ${report.fileName}'),
          backgroundColor: AppColors.primaryBlue,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.white,
            onPressed: () {},
          ),
        ),
      );
    } else if (report.status == ReportStatus.generating) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Report is still being generated. Please check back later.',
          ),
          backgroundColor: AppColors.primaryOrange,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (report.status == ReportStatus.failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text('Report generation failed. Please contact support.'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'OK',
            textColor: AppColors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildProfileInfo(),
          const SizedBox(height: 24),
          _buildSettingsSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                _userName[0].toUpperCase(),
                style: AppTypography.h1.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 36,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userName,
            style: AppTypography.h2.copyWith(
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Information',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: _userEmail,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: _userPhone,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.description_outlined,
            label: 'Total Reports',
            value: _reportsCount.toString(),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.currency_rupee,
            label: 'Total Spent',
            value: '₹$_amountSpent',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
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
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return Container(
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
            icon: Icons.auto_awesome,
            title: 'My Kundalis',
            subtitle: 'View your generated Kundalis',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const KundaliListScreen(),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            color: AppColors.lightGray,
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            subtitle: 'Manage your preferences',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            color: AppColors.lightGray,
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get help with your account',
            onTap: () {
              // TODO: Navigate to help screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help & Support coming soon'),
                  backgroundColor: AppColors.primaryBlue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            color: AppColors.lightGray,
            indent: 16,
            endIndent: 16,
          ),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Learn more about DishaAjyoti',
            onTap: () {
              // TODO: Navigate to about screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('About screen coming soon'),
                  backgroundColor: AppColors.primaryBlue,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
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

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _showLogoutDialog,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout, size: 20),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: AppTypography.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
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
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppColors.error,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Logout',
                style: AppTypography.h3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to logout from your account?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Logout',
                style: AppTypography.button,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    try {
      // Sign out from Firebase
      await FirebaseServiceManager.instance.signOut();

      if (mounted) {
        // Navigate to login screen and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildBottomNavItem(
                icon: Icons.grid_view_outlined,
                selectedIcon: Icons.grid_view,
                label: 'Services',
                index: 1,
              ),
              _buildBottomNavItem(
                icon: Icons.description_outlined,
                selectedIcon: Icons.description,
                label: 'Reports',
                index: 2,
              ),
              _buildBottomNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedBottomNav == index;

    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      hint: isSelected
          ? '$label tab, currently selected'
          : 'Double tap to switch to $label tab',
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBottomNav = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? AppColors.primaryOrange
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: isSelected
                      ? AppColors.primaryOrange
                      : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
