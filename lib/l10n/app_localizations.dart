import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('kn'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DishaAjyoti'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Career & Life Guidance'**
  String get appTagline;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get common_submit;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get common_error;

  /// No description provided for @common_success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get common_success;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get nav_services;

  /// No description provided for @nav_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get nav_reports;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @home_welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get home_welcome;

  /// No description provided for @home_explore_services.
  ///
  /// In en, this message translates to:
  /// **'Explore Services'**
  String get home_explore_services;

  /// No description provided for @home_reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get home_reports;

  /// No description provided for @home_spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get home_spent;

  /// No description provided for @home_featured_services.
  ///
  /// In en, this message translates to:
  /// **'Featured Services'**
  String get home_featured_services;

  /// No description provided for @home_view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get home_view_all;

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @settings_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_preferences;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_notifications_desc.
  ///
  /// In en, this message translates to:
  /// **'Receive updates and alerts'**
  String get settings_notifications_desc;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_select_language.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get settings_select_language;

  /// No description provided for @settings_language_changed.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String settings_language_changed(String language);

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_about_dishaajyoti.
  ///
  /// In en, this message translates to:
  /// **'About DishaAjyoti'**
  String get settings_about_dishaajyoti;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settings_version;

  /// No description provided for @settings_legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get settings_legal;

  /// No description provided for @settings_terms.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get settings_terms;

  /// No description provided for @settings_terms_desc.
  ///
  /// In en, this message translates to:
  /// **'Read our terms of service'**
  String get settings_terms_desc;

  /// No description provided for @settings_privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacy;

  /// No description provided for @settings_privacy_desc.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get settings_privacy_desc;

  /// No description provided for @settings_notifications_enabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled'**
  String get settings_notifications_enabled;

  /// No description provided for @settings_notifications_disabled.
  ///
  /// In en, this message translates to:
  /// **'Notifications disabled'**
  String get settings_notifications_disabled;

  /// No description provided for @service_free_kundali.
  ///
  /// In en, this message translates to:
  /// **'Free Kundali'**
  String get service_free_kundali;

  /// No description provided for @service_ai_kundali.
  ///
  /// In en, this message translates to:
  /// **'AI Kundali Analysis'**
  String get service_ai_kundali;

  /// No description provided for @service_palmistry.
  ///
  /// In en, this message translates to:
  /// **'Palmistry Reading'**
  String get service_palmistry;

  /// No description provided for @service_numerology.
  ///
  /// In en, this message translates to:
  /// **'Numerology Report'**
  String get service_numerology;

  /// No description provided for @service_compatibility.
  ///
  /// In en, this message translates to:
  /// **'Marriage Compatibility'**
  String get service_compatibility;

  /// No description provided for @service_free_kundali_desc.
  ///
  /// In en, this message translates to:
  /// **'Get your complete Vedic birth chart with planetary positions and basic predictions'**
  String get service_free_kundali_desc;

  /// No description provided for @service_ai_kundali_desc.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive AI-powered Vedic astrology report with detailed predictions and remedies'**
  String get service_ai_kundali_desc;

  /// No description provided for @service_palmistry_desc.
  ///
  /// In en, this message translates to:
  /// **'AI-powered palm reading analysis from your hand images'**
  String get service_palmistry_desc;

  /// No description provided for @service_numerology_desc.
  ///
  /// In en, this message translates to:
  /// **'Discover your life path and destiny through the power of numbers'**
  String get service_numerology_desc;

  /// No description provided for @service_compatibility_desc.
  ///
  /// In en, this message translates to:
  /// **'Check Ashtakoot matching and compatibility for marriage'**
  String get service_compatibility_desc;

  /// No description provided for @kundali_choose_method.
  ///
  /// In en, this message translates to:
  /// **'Choose Kundali Method'**
  String get kundali_choose_method;

  /// No description provided for @kundali_free_generation.
  ///
  /// In en, this message translates to:
  /// **'Free Kundali Generation'**
  String get kundali_free_generation;

  /// No description provided for @kundali_choose_preferred.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred method below'**
  String get kundali_choose_preferred;

  /// No description provided for @kundali_quick_generate.
  ///
  /// In en, this message translates to:
  /// **'Quick Generate'**
  String get kundali_quick_generate;

  /// No description provided for @kundali_quick_desc.
  ///
  /// In en, this message translates to:
  /// **'Generate instantly using our system'**
  String get kundali_quick_desc;

  /// No description provided for @kundali_professional.
  ///
  /// In en, this message translates to:
  /// **'Professional Kundali'**
  String get kundali_professional;

  /// No description provided for @kundali_professional_desc.
  ///
  /// In en, this message translates to:
  /// **'Use trusted online services'**
  String get kundali_professional_desc;

  /// No description provided for @kundali_instant_generation.
  ///
  /// In en, this message translates to:
  /// **'Instant generation'**
  String get kundali_instant_generation;

  /// No description provided for @kundali_stored_locally.
  ///
  /// In en, this message translates to:
  /// **'Stored locally on device'**
  String get kundali_stored_locally;

  /// No description provided for @kundali_basic_calculations.
  ///
  /// In en, this message translates to:
  /// **'Basic calculations'**
  String get kundali_basic_calculations;

  /// No description provided for @kundali_simple_pdf.
  ///
  /// In en, this message translates to:
  /// **'Simple PDF format'**
  String get kundali_simple_pdf;

  /// No description provided for @kundali_accurate_calculations.
  ///
  /// In en, this message translates to:
  /// **'Highly accurate calculations'**
  String get kundali_accurate_calculations;

  /// No description provided for @kundali_professional_format.
  ///
  /// In en, this message translates to:
  /// **'Professional format'**
  String get kundali_professional_format;

  /// No description provided for @kundali_detailed_predictions.
  ///
  /// In en, this message translates to:
  /// **'Detailed predictions & insights'**
  String get kundali_detailed_predictions;

  /// No description provided for @kundali_download_pdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF anytime'**
  String get kundali_download_pdf;

  /// No description provided for @kundali_generate_now.
  ///
  /// In en, this message translates to:
  /// **'Generate Now'**
  String get kundali_generate_now;

  /// No description provided for @kundali_get_professional.
  ///
  /// In en, this message translates to:
  /// **'Get Professional'**
  String get kundali_get_professional;

  /// No description provided for @kundali_recommended.
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get kundali_recommended;

  /// No description provided for @kundali_both_free.
  ///
  /// In en, this message translates to:
  /// **'Both methods are 100% free'**
  String get kundali_both_free;

  /// No description provided for @kundali_professional_info.
  ///
  /// In en, this message translates to:
  /// **'Professional Kundali uses trusted online services for more accurate and detailed results.'**
  String get kundali_professional_info;

  /// No description provided for @kundali_my_kundalis.
  ///
  /// In en, this message translates to:
  /// **'My Kundalis'**
  String get kundali_my_kundalis;

  /// No description provided for @kundali_no_kundalis.
  ///
  /// In en, this message translates to:
  /// **'No Kundalis Yet'**
  String get kundali_no_kundalis;

  /// No description provided for @kundali_create_first.
  ///
  /// In en, this message translates to:
  /// **'Create your first Kundali to get started'**
  String get kundali_create_first;

  /// No description provided for @kundali_new_kundali.
  ///
  /// In en, this message translates to:
  /// **'New Kundali'**
  String get kundali_new_kundali;

  /// No description provided for @kundali_create_kundali.
  ///
  /// In en, this message translates to:
  /// **'Create Kundali'**
  String get kundali_create_kundali;

  /// No description provided for @kundali_delete_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this Kundali?'**
  String get kundali_delete_confirm;

  /// No description provided for @kundali_deleted_success.
  ///
  /// In en, this message translates to:
  /// **'Kundali deleted successfully'**
  String get kundali_deleted_success;

  /// No description provided for @kundali_failed_to_delete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete Kundali'**
  String get kundali_failed_to_delete;

  /// No description provided for @kundali_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Kundali list'**
  String get kundali_failed_to_load;

  /// No description provided for @kundali_lagna.
  ///
  /// In en, this message translates to:
  /// **'Lagna: {sign}'**
  String kundali_lagna(String sign);

  /// No description provided for @kundali_moon.
  ///
  /// In en, this message translates to:
  /// **'Moon: {sign}'**
  String kundali_moon(String sign);

  /// No description provided for @auth_login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// No description provided for @auth_signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get auth_signup;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_confirm_password.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get auth_confirm_password;

  /// No description provided for @auth_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get auth_full_name;

  /// No description provided for @auth_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phone;

  /// No description provided for @auth_forgot_password.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get auth_forgot_password;

  /// No description provided for @auth_dont_have_account.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get auth_dont_have_account;

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get auth_already_have_account;

  /// No description provided for @auth_login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get auth_login_success;

  /// No description provided for @auth_signup_success.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get auth_signup_success;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// No description provided for @auth_logout_confirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout from your account?'**
  String get auth_logout_confirm;

  /// No description provided for @order_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get order_confirm;

  /// No description provided for @order_service_details.
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get order_service_details;

  /// No description provided for @order_summary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get order_summary;

  /// No description provided for @order_service_price.
  ///
  /// In en, this message translates to:
  /// **'Service Price'**
  String get order_service_price;

  /// No description provided for @order_tax_fees.
  ///
  /// In en, this message translates to:
  /// **'Tax & Fees'**
  String get order_tax_fees;

  /// No description provided for @order_included.
  ///
  /// In en, this message translates to:
  /// **'Included'**
  String get order_included;

  /// No description provided for @order_total_amount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get order_total_amount;

  /// No description provided for @order_what_you_get.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Get'**
  String get order_what_you_get;

  /// No description provided for @order_important_info.
  ///
  /// In en, this message translates to:
  /// **'Important Information'**
  String get order_important_info;

  /// No description provided for @order_delivery_time.
  ///
  /// In en, this message translates to:
  /// **'Delivery: {time}'**
  String order_delivery_time(String time);

  /// No description provided for @order_report_generated.
  ///
  /// In en, this message translates to:
  /// **'Report will be generated within {time}'**
  String order_report_generated(String time);

  /// No description provided for @order_notification_ready.
  ///
  /// In en, this message translates to:
  /// **'You will receive a notification when ready'**
  String get order_notification_ready;

  /// No description provided for @order_download_pdf.
  ///
  /// In en, this message translates to:
  /// **'Report can be downloaded as PDF'**
  String get order_download_pdf;

  /// No description provided for @order_refund_available.
  ///
  /// In en, this message translates to:
  /// **'Refund available if not satisfied'**
  String get order_refund_available;

  /// No description provided for @order_proceed_payment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get order_proceed_payment;

  /// No description provided for @order_tracking.
  ///
  /// In en, this message translates to:
  /// **'Order Tracking'**
  String get order_tracking;

  /// No description provided for @order_status.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get order_status;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @payment_title.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment_title;

  /// No description provided for @payment_methods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get payment_methods;

  /// No description provided for @payment_accept_all.
  ///
  /// In en, this message translates to:
  /// **'We accept all major payment methods including:'**
  String get payment_accept_all;

  /// No description provided for @payment_credit_card.
  ///
  /// In en, this message translates to:
  /// **'Credit Card'**
  String get payment_credit_card;

  /// No description provided for @payment_debit_card.
  ///
  /// In en, this message translates to:
  /// **'Debit Card'**
  String get payment_debit_card;

  /// No description provided for @payment_upi.
  ///
  /// In en, this message translates to:
  /// **'UPI'**
  String get payment_upi;

  /// No description provided for @payment_net_banking.
  ///
  /// In en, this message translates to:
  /// **'Net Banking'**
  String get payment_net_banking;

  /// No description provided for @payment_wallets.
  ///
  /// In en, this message translates to:
  /// **'Wallets'**
  String get payment_wallets;

  /// No description provided for @payment_secure.
  ///
  /// In en, this message translates to:
  /// **'Your payment is secure and encrypted. We do not store your card details.'**
  String get payment_secure;

  /// No description provided for @payment_total.
  ///
  /// In en, this message translates to:
  /// **'Total:'**
  String get payment_total;

  /// No description provided for @payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get payment_success;

  /// No description provided for @payment_report_generating.
  ///
  /// In en, this message translates to:
  /// **'Your report is being generated'**
  String get payment_report_generating;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get payment_failed;

  /// No description provided for @payment_view_status.
  ///
  /// In en, this message translates to:
  /// **'View Report Status'**
  String get payment_view_status;

  /// No description provided for @payment_pay_now.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payment_pay_now;

  /// No description provided for @report_title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get report_title;

  /// No description provided for @report_my_reports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get report_my_reports;

  /// No description provided for @report_no_reports.
  ///
  /// In en, this message translates to:
  /// **'No Reports Yet'**
  String get report_no_reports;

  /// No description provided for @report_generate_first.
  ///
  /// In en, this message translates to:
  /// **'Generate your first report to get started'**
  String get report_generate_first;

  /// No description provided for @report_view_report.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get report_view_report;

  /// No description provided for @report_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get report_download;

  /// No description provided for @report_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get report_share;

  /// No description provided for @report_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing Report'**
  String get report_processing;

  /// No description provided for @report_generating.
  ///
  /// In en, this message translates to:
  /// **'Your report is being generated'**
  String get report_generating;

  /// No description provided for @report_please_wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we prepare your personalized report'**
  String get report_please_wait;

  /// No description provided for @report_estimated_time.
  ///
  /// In en, this message translates to:
  /// **'Estimated time: {time}'**
  String report_estimated_time(String time);

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_information.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profile_information;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profile_phone;

  /// No description provided for @profile_total_reports.
  ///
  /// In en, this message translates to:
  /// **'Total Reports'**
  String get profile_total_reports;

  /// No description provided for @profile_total_spent.
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get profile_total_spent;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_settings_desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences'**
  String get profile_settings_desc;

  /// No description provided for @profile_help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get profile_help_support;

  /// No description provided for @profile_help_desc.
  ///
  /// In en, this message translates to:
  /// **'Get help with your account'**
  String get profile_help_desc;

  /// No description provided for @profile_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get profile_about;

  /// No description provided for @profile_about_desc.
  ///
  /// In en, this message translates to:
  /// **'Learn more about DishaAjyoti'**
  String get profile_about_desc;

  /// No description provided for @profile_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_edit;

  /// No description provided for @profile_update_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profile_update_success;

  /// No description provided for @palmistry_title.
  ///
  /// In en, this message translates to:
  /// **'Palmistry Analysis'**
  String get palmistry_title;

  /// No description provided for @palmistry_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload Palm Images'**
  String get palmistry_upload;

  /// No description provided for @palmistry_left_hand.
  ///
  /// In en, this message translates to:
  /// **'Left Hand'**
  String get palmistry_left_hand;

  /// No description provided for @palmistry_right_hand.
  ///
  /// In en, this message translates to:
  /// **'Right Hand'**
  String get palmistry_right_hand;

  /// No description provided for @palmistry_capture.
  ///
  /// In en, this message translates to:
  /// **'Capture Image'**
  String get palmistry_capture;

  /// No description provided for @palmistry_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get palmistry_gallery;

  /// No description provided for @palmistry_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get palmistry_analyze;

  /// No description provided for @palmistry_analysis.
  ///
  /// In en, this message translates to:
  /// **'Palm Analysis'**
  String get palmistry_analysis;

  /// No description provided for @palmistry_life_line.
  ///
  /// In en, this message translates to:
  /// **'Life Line'**
  String get palmistry_life_line;

  /// No description provided for @palmistry_heart_line.
  ///
  /// In en, this message translates to:
  /// **'Heart Line'**
  String get palmistry_heart_line;

  /// No description provided for @palmistry_head_line.
  ///
  /// In en, this message translates to:
  /// **'Head Line'**
  String get palmistry_head_line;

  /// No description provided for @palmistry_fate_line.
  ///
  /// In en, this message translates to:
  /// **'Fate Line'**
  String get palmistry_fate_line;

  /// No description provided for @numerology_title.
  ///
  /// In en, this message translates to:
  /// **'Numerology Analysis'**
  String get numerology_title;

  /// No description provided for @numerology_input.
  ///
  /// In en, this message translates to:
  /// **'Enter Details'**
  String get numerology_input;

  /// No description provided for @numerology_full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get numerology_full_name;

  /// No description provided for @numerology_date_of_birth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get numerology_date_of_birth;

  /// No description provided for @numerology_calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get numerology_calculate;

  /// No description provided for @numerology_analysis.
  ///
  /// In en, this message translates to:
  /// **'Numerology Analysis'**
  String get numerology_analysis;

  /// No description provided for @numerology_life_path.
  ///
  /// In en, this message translates to:
  /// **'Life Path Number'**
  String get numerology_life_path;

  /// No description provided for @numerology_destiny.
  ///
  /// In en, this message translates to:
  /// **'Destiny Number'**
  String get numerology_destiny;

  /// No description provided for @numerology_soul_urge.
  ///
  /// In en, this message translates to:
  /// **'Soul Urge Number'**
  String get numerology_soul_urge;

  /// No description provided for @compatibility_title.
  ///
  /// In en, this message translates to:
  /// **'Marriage Compatibility'**
  String get compatibility_title;

  /// No description provided for @compatibility_check.
  ///
  /// In en, this message translates to:
  /// **'Check Compatibility'**
  String get compatibility_check;

  /// No description provided for @compatibility_person1.
  ///
  /// In en, this message translates to:
  /// **'Person 1'**
  String get compatibility_person1;

  /// No description provided for @compatibility_person2.
  ///
  /// In en, this message translates to:
  /// **'Person 2'**
  String get compatibility_person2;

  /// No description provided for @compatibility_result.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Result'**
  String get compatibility_result;

  /// No description provided for @compatibility_score.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Score'**
  String get compatibility_score;

  /// No description provided for @compatibility_ashtakoot.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoot Score'**
  String get compatibility_ashtakoot;

  /// No description provided for @compatibility_out_of.
  ///
  /// In en, this message translates to:
  /// **'out of 36'**
  String get compatibility_out_of;

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_no_notifications.
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notifications_no_notifications;

  /// No description provided for @notifications_all_caught_up.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notifications_all_caught_up;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_get_started;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection and try again.'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_server;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get error_unknown;

  /// No description provided for @error_session_expired.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please log in again.'**
  String get error_session_expired;

  /// No description provided for @error_invalid_input.
  ///
  /// In en, this message translates to:
  /// **'Please enter valid information.'**
  String get error_invalid_input;

  /// No description provided for @error_required_field.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get error_required_field;

  /// No description provided for @success_operation.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully!'**
  String get success_operation;

  /// No description provided for @success_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully!'**
  String get success_saved;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @forgot_password_title.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgot_password_title;

  /// No description provided for @forgot_password_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password'**
  String get forgot_password_subtitle;

  /// No description provided for @forgot_password_email_sent_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your email for reset instructions'**
  String get forgot_password_email_sent_subtitle;

  /// No description provided for @forgot_password_email_label.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get forgot_password_email_label;

  /// No description provided for @forgot_password_email_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get forgot_password_email_hint;

  /// No description provided for @forgot_password_send_reset_link.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get forgot_password_send_reset_link;

  /// No description provided for @forgot_password_email_sent.
  ///
  /// In en, this message translates to:
  /// **'Email Sent!'**
  String get forgot_password_email_sent;

  /// No description provided for @forgot_password_email_sent_message.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a password reset link to {email}'**
  String forgot_password_email_sent_message(String email);

  /// No description provided for @forgot_password_check_spam.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the email? Check your spam folder or try again in a few minutes.'**
  String get forgot_password_check_spam;

  /// No description provided for @forgot_password_remember.
  ///
  /// In en, this message translates to:
  /// **'Remember your password? '**
  String get forgot_password_remember;

  /// No description provided for @forgot_password_back_to_login.
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get forgot_password_back_to_login;

  /// No description provided for @forgot_password_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link: {error}'**
  String forgot_password_failed(String error);

  /// No description provided for @profile_setup_title.
  ///
  /// In en, this message translates to:
  /// **'Complete Your Profile'**
  String get profile_setup_title;

  /// No description provided for @profile_setup_step_of.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String profile_setup_step_of(int current, int total);

  /// No description provided for @profile_setup_birth_details.
  ///
  /// In en, this message translates to:
  /// **'Birth Details'**
  String get profile_setup_birth_details;

  /// No description provided for @profile_setup_birth_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us understand your astrological profile'**
  String get profile_setup_birth_subtitle;

  /// No description provided for @profile_setup_dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get profile_setup_dob_label;

  /// No description provided for @profile_setup_dob_hint.
  ///
  /// In en, this message translates to:
  /// **'DD/MM/YYYY'**
  String get profile_setup_dob_hint;

  /// No description provided for @profile_setup_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get profile_setup_time_label;

  /// No description provided for @profile_setup_time_hint.
  ///
  /// In en, this message translates to:
  /// **'HH:MM AM/PM'**
  String get profile_setup_time_hint;

  /// No description provided for @profile_setup_place_label.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get profile_setup_place_label;

  /// No description provided for @profile_setup_place_hint.
  ///
  /// In en, this message translates to:
  /// **'City, State, Country'**
  String get profile_setup_place_hint;

  /// No description provided for @profile_setup_career_info.
  ///
  /// In en, this message translates to:
  /// **'Career Information'**
  String get profile_setup_career_info;

  /// No description provided for @profile_setup_career_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your professional journey'**
  String get profile_setup_career_subtitle;

  /// No description provided for @profile_setup_career_label.
  ///
  /// In en, this message translates to:
  /// **'Current/Past Career'**
  String get profile_setup_career_label;

  /// No description provided for @profile_setup_career_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Software Engineer, Teacher, Business Owner'**
  String get profile_setup_career_hint;

  /// No description provided for @profile_setup_goals_label.
  ///
  /// In en, this message translates to:
  /// **'Career Goals'**
  String get profile_setup_goals_label;

  /// No description provided for @profile_setup_goals_hint.
  ///
  /// In en, this message translates to:
  /// **'What are your professional aspirations?'**
  String get profile_setup_goals_hint;

  /// No description provided for @profile_setup_challenges.
  ///
  /// In en, this message translates to:
  /// **'Your Challenges'**
  String get profile_setup_challenges;

  /// No description provided for @profile_setup_challenges_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Share what you\'re currently facing'**
  String get profile_setup_challenges_subtitle;

  /// No description provided for @profile_setup_challenges_label.
  ///
  /// In en, this message translates to:
  /// **'Current Challenges'**
  String get profile_setup_challenges_label;

  /// No description provided for @profile_setup_challenges_hint.
  ///
  /// In en, this message translates to:
  /// **'What obstacles or difficulties are you experiencing?'**
  String get profile_setup_challenges_hint;

  /// No description provided for @profile_setup_privacy_note.
  ///
  /// In en, this message translates to:
  /// **'Your information is kept private and secure. We use it only to provide personalized guidance.'**
  String get profile_setup_privacy_note;

  /// No description provided for @profile_setup_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get profile_setup_back;

  /// No description provided for @profile_setup_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get profile_setup_next;

  /// No description provided for @profile_setup_complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get profile_setup_complete;

  /// No description provided for @profile_setup_success.
  ///
  /// In en, this message translates to:
  /// **'Profile setup completed successfully!'**
  String get profile_setup_success;

  /// No description provided for @language_select_title.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language_select_title;

  /// No description provided for @language_choose_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get language_choose_title;

  /// No description provided for @language_choose_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language for the app'**
  String get language_choose_subtitle;

  /// No description provided for @language_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_continue;

  /// No description provided for @language_changed_to.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}'**
  String language_changed_to(String language);

  /// No description provided for @kundali_detail_title.
  ///
  /// In en, this message translates to:
  /// **'Kundali Details'**
  String get kundali_detail_title;

  /// No description provided for @kundali_detail_generate_report.
  ///
  /// In en, this message translates to:
  /// **'Generate Detailed Report'**
  String get kundali_detail_generate_report;

  /// No description provided for @kundali_detail_basic_info.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get kundali_detail_basic_info;

  /// No description provided for @kundali_detail_name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get kundali_detail_name;

  /// No description provided for @kundali_detail_dob.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get kundali_detail_dob;

  /// No description provided for @kundali_detail_time.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get kundali_detail_time;

  /// No description provided for @kundali_detail_place.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get kundali_detail_place;

  /// No description provided for @kundali_detail_astrological_info.
  ///
  /// In en, this message translates to:
  /// **'Astrological Information'**
  String get kundali_detail_astrological_info;

  /// No description provided for @kundali_detail_lagna_label.
  ///
  /// In en, this message translates to:
  /// **'Lagna'**
  String get kundali_detail_lagna_label;

  /// No description provided for @kundali_detail_moon_sign.
  ///
  /// In en, this message translates to:
  /// **'Moon Sign'**
  String get kundali_detail_moon_sign;

  /// No description provided for @kundali_detail_sun_sign.
  ///
  /// In en, this message translates to:
  /// **'Sun Sign'**
  String get kundali_detail_sun_sign;

  /// No description provided for @kundali_detail_nakshatra.
  ///
  /// In en, this message translates to:
  /// **'Nakshatra'**
  String get kundali_detail_nakshatra;

  /// No description provided for @kundali_detail_planetary_positions.
  ///
  /// In en, this message translates to:
  /// **'Planetary Positions'**
  String get kundali_detail_planetary_positions;

  /// No description provided for @kundali_detail_no_planetary_data.
  ///
  /// In en, this message translates to:
  /// **'No planetary position data available'**
  String get kundali_detail_no_planetary_data;

  /// No description provided for @kundali_detail_houses.
  ///
  /// In en, this message translates to:
  /// **'Houses'**
  String get kundali_detail_houses;

  /// No description provided for @kundali_detail_no_house_data.
  ///
  /// In en, this message translates to:
  /// **'No house data available'**
  String get kundali_detail_no_house_data;

  /// No description provided for @kundali_detail_house_label.
  ///
  /// In en, this message translates to:
  /// **'House {number}: {sign}'**
  String kundali_detail_house_label(String number, String sign);

  /// No description provided for @kundali_detail_failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Kundali details'**
  String get kundali_detail_failed_to_load;

  /// No description provided for @kundali_detail_report_generated.
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get kundali_detail_report_generated;

  /// No description provided for @kundali_detail_report_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report'**
  String get kundali_detail_report_failed;

  /// No description provided for @kundali_form_title.
  ///
  /// In en, this message translates to:
  /// **'Free Kundali'**
  String get kundali_form_title;

  /// No description provided for @kundali_form_header.
  ///
  /// In en, this message translates to:
  /// **'Get Your Free Kundali'**
  String get kundali_form_header;

  /// No description provided for @kundali_form_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your birth details to generate your personalized Kundali'**
  String get kundali_form_subtitle;

  /// No description provided for @kundali_form_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get kundali_form_name_label;

  /// No description provided for @kundali_form_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get kundali_form_name_hint;

  /// No description provided for @kundali_form_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get kundali_form_name_required;

  /// No description provided for @kundali_form_dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get kundali_form_dob_label;

  /// No description provided for @kundali_form_dob_hint.
  ///
  /// In en, this message translates to:
  /// **'Select your date of birth'**
  String get kundali_form_dob_hint;

  /// No description provided for @kundali_form_dob_required.
  ///
  /// In en, this message translates to:
  /// **'Please select your date of birth'**
  String get kundali_form_dob_required;

  /// No description provided for @kundali_form_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get kundali_form_time_label;

  /// No description provided for @kundali_form_time_hint.
  ///
  /// In en, this message translates to:
  /// **'Select your time of birth'**
  String get kundali_form_time_hint;

  /// No description provided for @kundali_form_time_required.
  ///
  /// In en, this message translates to:
  /// **'Please select your time of birth'**
  String get kundali_form_time_required;

  /// No description provided for @kundali_form_place_label.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get kundali_form_place_label;

  /// No description provided for @kundali_form_place_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your place of birth (e.g., Mumbai, India)'**
  String get kundali_form_place_hint;

  /// No description provided for @kundali_form_place_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your place of birth'**
  String get kundali_form_place_required;

  /// No description provided for @kundali_form_auto_fill_coords.
  ///
  /// In en, this message translates to:
  /// **'Auto-Fill Coordinates'**
  String get kundali_form_auto_fill_coords;

  /// No description provided for @kundali_form_fetching_coords.
  ///
  /// In en, this message translates to:
  /// **'Fetching Coordinates...'**
  String get kundali_form_fetching_coords;

  /// No description provided for @kundali_form_latitude_label.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get kundali_form_latitude_label;

  /// No description provided for @kundali_form_latitude_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 19.0760 (for Mumbai)'**
  String get kundali_form_latitude_hint;

  /// No description provided for @kundali_form_latitude_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter latitude'**
  String get kundali_form_latitude_required;

  /// No description provided for @kundali_form_latitude_invalid.
  ///
  /// In en, this message translates to:
  /// **'Latitude must be between -90 and 90'**
  String get kundali_form_latitude_invalid;

  /// No description provided for @kundali_form_longitude_label.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get kundali_form_longitude_label;

  /// No description provided for @kundali_form_longitude_hint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 72.8777 (for Mumbai)'**
  String get kundali_form_longitude_hint;

  /// No description provided for @kundali_form_longitude_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter longitude'**
  String get kundali_form_longitude_required;

  /// No description provided for @kundali_form_longitude_invalid.
  ///
  /// In en, this message translates to:
  /// **'Longitude must be between -180 and 180'**
  String get kundali_form_longitude_invalid;

  /// No description provided for @kundali_form_info.
  ///
  /// In en, this message translates to:
  /// **'Your Kundali will be calculated using Vedic Astrology with Lahiri Ayanamsa. Includes birth chart, planetary positions, houses, nakshatras, and Vimshottari Dasha.'**
  String get kundali_form_info;

  /// No description provided for @kundali_form_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate Free Kundali'**
  String get kundali_form_generate;

  /// No description provided for @kundali_form_generating_title.
  ///
  /// In en, this message translates to:
  /// **'AI Generating Kundali'**
  String get kundali_form_generating_title;

  /// No description provided for @kundali_form_generating_message.
  ///
  /// In en, this message translates to:
  /// **'Calculating planetary positions and creating your personalized birth chart...'**
  String get kundali_form_generating_message;

  /// No description provided for @kundali_form_coords_found.
  ///
  /// In en, this message translates to:
  /// **'Coordinates found for {place}'**
  String kundali_form_coords_found(String place);

  /// No description provided for @kundali_form_coords_not_found.
  ///
  /// In en, this message translates to:
  /// **'Could not find coordinates. Please enter manually.'**
  String get kundali_form_coords_not_found;

  /// No description provided for @kundali_form_success.
  ///
  /// In en, this message translates to:
  /// **'Kundali generated successfully!'**
  String get kundali_form_success;

  /// No description provided for @kundali_form_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate Kundali: {error}'**
  String kundali_form_failed(String error);

  /// No description provided for @kundali_input_title.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundali'**
  String get kundali_input_title;

  /// No description provided for @kundali_input_header.
  ///
  /// In en, this message translates to:
  /// **'Enter Birth Details'**
  String get kundali_input_header;

  /// No description provided for @kundali_input_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide accurate birth information for precise Kundali analysis'**
  String get kundali_input_subtitle;

  /// No description provided for @kundali_input_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get kundali_input_name_label;

  /// No description provided for @kundali_input_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get kundali_input_name_hint;

  /// No description provided for @kundali_input_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get kundali_input_name_required;

  /// No description provided for @kundali_input_dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get kundali_input_dob_label;

  /// No description provided for @kundali_input_dob_hint.
  ///
  /// In en, this message translates to:
  /// **'Select date of birth'**
  String get kundali_input_dob_hint;

  /// No description provided for @kundali_input_dob_select.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get kundali_input_dob_select;

  /// No description provided for @kundali_input_dob_required.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get kundali_input_dob_required;

  /// No description provided for @kundali_input_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get kundali_input_time_label;

  /// No description provided for @kundali_input_time_hint.
  ///
  /// In en, this message translates to:
  /// **'Select time of birth'**
  String get kundali_input_time_hint;

  /// No description provided for @kundali_input_time_select.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get kundali_input_time_select;

  /// No description provided for @kundali_input_time_required.
  ///
  /// In en, this message translates to:
  /// **'Please select time of birth'**
  String get kundali_input_time_required;

  /// No description provided for @kundali_input_place_label.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get kundali_input_place_label;

  /// No description provided for @kundali_input_place_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get kundali_input_place_hint;

  /// No description provided for @kundali_input_place_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter place of birth'**
  String get kundali_input_place_required;

  /// No description provided for @kundali_input_fetch_coords.
  ///
  /// In en, this message translates to:
  /// **'Fetch Coordinates'**
  String get kundali_input_fetch_coords;

  /// No description provided for @kundali_input_coords_success.
  ///
  /// In en, this message translates to:
  /// **'Coordinates fetched successfully'**
  String get kundali_input_coords_success;

  /// No description provided for @kundali_input_coords_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch coordinates'**
  String get kundali_input_coords_failed;

  /// No description provided for @kundali_input_coords_display.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lon}'**
  String kundali_input_coords_display(String lat, String lon);

  /// No description provided for @kundali_input_coords_required.
  ///
  /// In en, this message translates to:
  /// **'Please fetch coordinates for the birth place'**
  String get kundali_input_coords_required;

  /// No description provided for @kundali_input_generate.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundali'**
  String get kundali_input_generate;

  /// No description provided for @kundali_input_note.
  ///
  /// In en, this message translates to:
  /// **'Note: Accurate birth time is crucial for precise Kundali analysis. If exact time is unknown, use approximate time.'**
  String get kundali_input_note;

  /// No description provided for @kundali_input_success.
  ///
  /// In en, this message translates to:
  /// **'Kundali generated successfully'**
  String get kundali_input_success;

  /// No description provided for @kundali_input_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate Kundali'**
  String get kundali_input_failed;

  /// No description provided for @kundali_input_place_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter a place name first'**
  String get kundali_input_place_first;

  /// No description provided for @kundali_webview_title.
  ///
  /// In en, this message translates to:
  /// **'Generate Kundali Online'**
  String get kundali_webview_title;

  /// No description provided for @kundali_webview_fill_details.
  ///
  /// In en, this message translates to:
  /// **'Fill in your details and generate Kundali'**
  String get kundali_webview_fill_details;

  /// No description provided for @kundali_webview_download_pdf.
  ///
  /// In en, this message translates to:
  /// **'You can download the PDF from the website'**
  String get kundali_webview_download_pdf;

  /// No description provided for @kundali_webview_astrosage.
  ///
  /// In en, this message translates to:
  /// **'AstroSage'**
  String get kundali_webview_astrosage;

  /// No description provided for @kundali_webview_mpanchang.
  ///
  /// In en, this message translates to:
  /// **'mPanchang'**
  String get kundali_webview_mpanchang;

  /// No description provided for @kundali_webview_ganeshaspeaks.
  ///
  /// In en, this message translates to:
  /// **'GaneshaSpeaks'**
  String get kundali_webview_ganeshaspeaks;

  /// No description provided for @kundali_webview_clickastro.
  ///
  /// In en, this message translates to:
  /// **'ClickAstro'**
  String get kundali_webview_clickastro;

  /// No description provided for @compatibility_check_title.
  ///
  /// In en, this message translates to:
  /// **'Check Marriage Compatibility'**
  String get compatibility_check_title;

  /// No description provided for @compatibility_check_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter birth details of both individuals for Ashtakoot matching'**
  String get compatibility_check_subtitle;

  /// No description provided for @compatibility_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get compatibility_name_label;

  /// No description provided for @compatibility_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get compatibility_name_hint;

  /// No description provided for @compatibility_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter name'**
  String get compatibility_name_required;

  /// No description provided for @compatibility_dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get compatibility_dob_label;

  /// No description provided for @compatibility_dob_select.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get compatibility_dob_select;

  /// No description provided for @compatibility_dob_required.
  ///
  /// In en, this message translates to:
  /// **'Please select both dates of birth'**
  String get compatibility_dob_required;

  /// No description provided for @compatibility_time_label.
  ///
  /// In en, this message translates to:
  /// **'Time of Birth'**
  String get compatibility_time_label;

  /// No description provided for @compatibility_time_select.
  ///
  /// In en, this message translates to:
  /// **'Select time'**
  String get compatibility_time_select;

  /// No description provided for @compatibility_time_required.
  ///
  /// In en, this message translates to:
  /// **'Please select both times of birth'**
  String get compatibility_time_required;

  /// No description provided for @compatibility_place_label.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get compatibility_place_label;

  /// No description provided for @compatibility_place_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter city name'**
  String get compatibility_place_hint;

  /// No description provided for @compatibility_place_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter place'**
  String get compatibility_place_required;

  /// No description provided for @compatibility_fetch_coords.
  ///
  /// In en, this message translates to:
  /// **'Fetch Coordinates'**
  String get compatibility_fetch_coords;

  /// No description provided for @compatibility_coords_success.
  ///
  /// In en, this message translates to:
  /// **'Coordinates fetched successfully'**
  String get compatibility_coords_success;

  /// No description provided for @compatibility_coords_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch coordinates'**
  String get compatibility_coords_failed;

  /// No description provided for @compatibility_coords_display.
  ///
  /// In en, this message translates to:
  /// **'Coordinates: {lat}, {lon}'**
  String compatibility_coords_display(String lat, String lon);

  /// No description provided for @compatibility_coords_required.
  ///
  /// In en, this message translates to:
  /// **'Please fetch coordinates for both birth places'**
  String get compatibility_coords_required;

  /// No description provided for @compatibility_check_button.
  ///
  /// In en, this message translates to:
  /// **'Check Compatibility'**
  String get compatibility_check_button;

  /// No description provided for @compatibility_note.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoot matching analyzes 8 compatibility factors based on Vedic astrology principles.'**
  String get compatibility_note;

  /// No description provided for @compatibility_analysis_completed.
  ///
  /// In en, this message translates to:
  /// **'Compatibility analysis completed'**
  String get compatibility_analysis_completed;

  /// No description provided for @compatibility_analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Analysis Failed'**
  String get compatibility_analysis_failed;

  /// No description provided for @compatibility_place_first.
  ///
  /// In en, this message translates to:
  /// **'Please enter a place name first'**
  String get compatibility_place_first;

  /// No description provided for @compatibility_result_title.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Result'**
  String get compatibility_result_title;

  /// No description provided for @compatibility_result_ashtakoot_score.
  ///
  /// In en, this message translates to:
  /// **'Ashtakoot Compatibility Score'**
  String get compatibility_result_ashtakoot_score;

  /// No description provided for @compatibility_result_out_of.
  ///
  /// In en, this message translates to:
  /// **'out of 36'**
  String get compatibility_result_out_of;

  /// No description provided for @compatibility_result_excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent Match'**
  String get compatibility_result_excellent;

  /// No description provided for @compatibility_result_very_good.
  ///
  /// In en, this message translates to:
  /// **'Very Good Match'**
  String get compatibility_result_very_good;

  /// No description provided for @compatibility_result_good.
  ///
  /// In en, this message translates to:
  /// **'Good Match'**
  String get compatibility_result_good;

  /// No description provided for @compatibility_result_average.
  ///
  /// In en, this message translates to:
  /// **'Average Match'**
  String get compatibility_result_average;

  /// No description provided for @compatibility_result_challenging.
  ///
  /// In en, this message translates to:
  /// **'Challenging Match'**
  String get compatibility_result_challenging;

  /// No description provided for @compatibility_result_detailed_analysis.
  ///
  /// In en, this message translates to:
  /// **'Detailed Ashtakoot Analysis'**
  String get compatibility_result_detailed_analysis;

  /// No description provided for @compatibility_result_varna.
  ///
  /// In en, this message translates to:
  /// **'Varna'**
  String get compatibility_result_varna;

  /// No description provided for @compatibility_result_varna_desc.
  ///
  /// In en, this message translates to:
  /// **'Spiritual compatibility'**
  String get compatibility_result_varna_desc;

  /// No description provided for @compatibility_result_vashya.
  ///
  /// In en, this message translates to:
  /// **'Vashya'**
  String get compatibility_result_vashya;

  /// No description provided for @compatibility_result_vashya_desc.
  ///
  /// In en, this message translates to:
  /// **'Mutual attraction'**
  String get compatibility_result_vashya_desc;

  /// No description provided for @compatibility_result_tara.
  ///
  /// In en, this message translates to:
  /// **'Tara'**
  String get compatibility_result_tara;

  /// No description provided for @compatibility_result_tara_desc.
  ///
  /// In en, this message translates to:
  /// **'Birth star compatibility'**
  String get compatibility_result_tara_desc;

  /// No description provided for @compatibility_result_yoni.
  ///
  /// In en, this message translates to:
  /// **'Yoni'**
  String get compatibility_result_yoni;

  /// No description provided for @compatibility_result_yoni_desc.
  ///
  /// In en, this message translates to:
  /// **'Physical compatibility'**
  String get compatibility_result_yoni_desc;

  /// No description provided for @compatibility_result_graha_maitri.
  ///
  /// In en, this message translates to:
  /// **'Graha Maitri'**
  String get compatibility_result_graha_maitri;

  /// No description provided for @compatibility_result_graha_maitri_desc.
  ///
  /// In en, this message translates to:
  /// **'Mental compatibility'**
  String get compatibility_result_graha_maitri_desc;

  /// No description provided for @compatibility_result_gana.
  ///
  /// In en, this message translates to:
  /// **'Gana'**
  String get compatibility_result_gana;

  /// No description provided for @compatibility_result_gana_desc.
  ///
  /// In en, this message translates to:
  /// **'Temperament'**
  String get compatibility_result_gana_desc;

  /// No description provided for @compatibility_result_bhakoot.
  ///
  /// In en, this message translates to:
  /// **'Bhakoot'**
  String get compatibility_result_bhakoot;

  /// No description provided for @compatibility_result_bhakoot_desc.
  ///
  /// In en, this message translates to:
  /// **'Love and affection'**
  String get compatibility_result_bhakoot_desc;

  /// No description provided for @compatibility_result_nadi.
  ///
  /// In en, this message translates to:
  /// **'Nadi'**
  String get compatibility_result_nadi;

  /// No description provided for @compatibility_result_nadi_desc.
  ///
  /// In en, this message translates to:
  /// **'Health and genes'**
  String get compatibility_result_nadi_desc;

  /// No description provided for @compatibility_result_no_mangal_dosha.
  ///
  /// In en, this message translates to:
  /// **'No Mangal Dosha'**
  String get compatibility_result_no_mangal_dosha;

  /// No description provided for @compatibility_result_no_mangal_dosha_desc.
  ///
  /// In en, this message translates to:
  /// **'Neither person has Mangal Dosha'**
  String get compatibility_result_no_mangal_dosha_desc;

  /// No description provided for @compatibility_result_mangal_dosha.
  ///
  /// In en, this message translates to:
  /// **'Mangal Dosha Detected'**
  String get compatibility_result_mangal_dosha;

  /// No description provided for @compatibility_result_person1_dosha.
  ///
  /// In en, this message translates to:
  /// **'Person 1 has Mangal Dosha'**
  String get compatibility_result_person1_dosha;

  /// No description provided for @compatibility_result_person2_dosha.
  ///
  /// In en, this message translates to:
  /// **'Person 2 has Mangal Dosha'**
  String get compatibility_result_person2_dosha;

  /// No description provided for @compatibility_result_both_dosha.
  ///
  /// In en, this message translates to:
  /// **'Both having Mangal Dosha can neutralize its effects'**
  String get compatibility_result_both_dosha;

  /// No description provided for @compatibility_result_remedies_recommended.
  ///
  /// In en, this message translates to:
  /// **'Remedies are recommended for better harmony'**
  String get compatibility_result_remedies_recommended;

  /// No description provided for @compatibility_result_analysis.
  ///
  /// In en, this message translates to:
  /// **'Compatibility Analysis'**
  String get compatibility_result_analysis;

  /// No description provided for @compatibility_result_mental_harmony.
  ///
  /// In en, this message translates to:
  /// **'Mental Harmony'**
  String get compatibility_result_mental_harmony;

  /// No description provided for @compatibility_result_physical_harmony.
  ///
  /// In en, this message translates to:
  /// **'Physical Harmony'**
  String get compatibility_result_physical_harmony;

  /// No description provided for @compatibility_result_emotional_harmony.
  ///
  /// In en, this message translates to:
  /// **'Emotional Harmony'**
  String get compatibility_result_emotional_harmony;

  /// No description provided for @compatibility_result_spiritual_harmony.
  ///
  /// In en, this message translates to:
  /// **'Spiritual Harmony'**
  String get compatibility_result_spiritual_harmony;

  /// No description provided for @compatibility_result_remedies.
  ///
  /// In en, this message translates to:
  /// **'Recommended Remedies'**
  String get compatibility_result_remedies;

  /// No description provided for @numerology_input_header.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Details'**
  String get numerology_input_header;

  /// No description provided for @numerology_input_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the hidden meanings in your name and birth date'**
  String get numerology_input_subtitle;

  /// No description provided for @numerology_name_label.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get numerology_name_label;

  /// No description provided for @numerology_name_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter your complete name'**
  String get numerology_name_hint;

  /// No description provided for @numerology_name_required.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get numerology_name_required;

  /// No description provided for @numerology_name_min_length.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get numerology_name_min_length;

  /// No description provided for @numerology_dob_label.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get numerology_dob_label;

  /// No description provided for @numerology_dob_select.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get numerology_dob_select;

  /// No description provided for @numerology_dob_required.
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get numerology_dob_required;

  /// No description provided for @numerology_what_discover.
  ///
  /// In en, this message translates to:
  /// **'What You\'ll Discover'**
  String get numerology_what_discover;

  /// No description provided for @numerology_life_path_desc.
  ///
  /// In en, this message translates to:
  /// **'Your life\'s purpose and journey'**
  String get numerology_life_path_desc;

  /// No description provided for @numerology_destiny_desc.
  ///
  /// In en, this message translates to:
  /// **'Your natural talents and abilities'**
  String get numerology_destiny_desc;

  /// No description provided for @numerology_soul_urge_desc.
  ///
  /// In en, this message translates to:
  /// **'Your inner desires and motivations'**
  String get numerology_soul_urge_desc;

  /// No description provided for @numerology_lucky_numbers.
  ///
  /// In en, this message translates to:
  /// **'Lucky Numbers'**
  String get numerology_lucky_numbers;

  /// No description provided for @numerology_lucky_numbers_desc.
  ///
  /// In en, this message translates to:
  /// **'Numbers that bring you fortune'**
  String get numerology_lucky_numbers_desc;

  /// No description provided for @numerology_compatibility_label.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get numerology_compatibility_label;

  /// No description provided for @numerology_compatibility_desc.
  ///
  /// In en, this message translates to:
  /// **'Best matches for relationships'**
  String get numerology_compatibility_desc;

  /// No description provided for @numerology_analyze_button.
  ///
  /// In en, this message translates to:
  /// **'Analyze Numerology'**
  String get numerology_analyze_button;

  /// No description provided for @numerology_note.
  ///
  /// In en, this message translates to:
  /// **'Numerology reveals the vibrational patterns in your name and birth date, offering insights into your personality, life path, and destiny.'**
  String get numerology_note;

  /// No description provided for @numerology_analysis_completed.
  ///
  /// In en, this message translates to:
  /// **'Numerology analysis completed'**
  String get numerology_analysis_completed;

  /// No description provided for @numerology_analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to analyze numerology'**
  String get numerology_analysis_failed;

  /// No description provided for @numerology_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Numerology Analysis'**
  String get numerology_analysis_title;

  /// No description provided for @numerology_analysis_core_numbers.
  ///
  /// In en, this message translates to:
  /// **'Your Core Numbers'**
  String get numerology_analysis_core_numbers;

  /// No description provided for @numerology_analysis_life_path_label.
  ///
  /// In en, this message translates to:
  /// **'Life Path'**
  String get numerology_analysis_life_path_label;

  /// No description provided for @numerology_analysis_destiny_label.
  ///
  /// In en, this message translates to:
  /// **'Destiny'**
  String get numerology_analysis_destiny_label;

  /// No description provided for @numerology_analysis_soul_urge_label.
  ///
  /// In en, this message translates to:
  /// **'Soul Urge'**
  String get numerology_analysis_soul_urge_label;

  /// No description provided for @numerology_analysis_life_path_title.
  ///
  /// In en, this message translates to:
  /// **'Life Path Analysis'**
  String get numerology_analysis_life_path_title;

  /// No description provided for @numerology_analysis_destiny_title.
  ///
  /// In en, this message translates to:
  /// **'Destiny Analysis'**
  String get numerology_analysis_destiny_title;

  /// No description provided for @numerology_analysis_soul_urge_title.
  ///
  /// In en, this message translates to:
  /// **'Soul Urge Analysis'**
  String get numerology_analysis_soul_urge_title;

  /// No description provided for @numerology_analysis_lucky_elements.
  ///
  /// In en, this message translates to:
  /// **'Lucky Elements'**
  String get numerology_analysis_lucky_elements;

  /// No description provided for @numerology_analysis_lucky_numbers_label.
  ///
  /// In en, this message translates to:
  /// **'Lucky Numbers'**
  String get numerology_analysis_lucky_numbers_label;

  /// No description provided for @numerology_analysis_lucky_colors.
  ///
  /// In en, this message translates to:
  /// **'Lucky Colors'**
  String get numerology_analysis_lucky_colors;

  /// No description provided for @numerology_analysis_lucky_days.
  ///
  /// In en, this message translates to:
  /// **'Lucky Days'**
  String get numerology_analysis_lucky_days;

  /// No description provided for @numerology_analysis_compatibility_title.
  ///
  /// In en, this message translates to:
  /// **'Compatibility'**
  String get numerology_analysis_compatibility_title;

  /// No description provided for @numerology_analysis_best_matches.
  ///
  /// In en, this message translates to:
  /// **'Best Matches'**
  String get numerology_analysis_best_matches;

  /// No description provided for @numerology_analysis_challenging_matches.
  ///
  /// In en, this message translates to:
  /// **'Challenging Matches'**
  String get numerology_analysis_challenging_matches;

  /// No description provided for @palmistry_upload_header.
  ///
  /// In en, this message translates to:
  /// **'Capture Palm Images'**
  String get palmistry_upload_header;

  /// No description provided for @palmistry_upload_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Take clear photos of both palms in good lighting for accurate analysis'**
  String get palmistry_upload_subtitle;

  /// No description provided for @palmistry_left_hand_label.
  ///
  /// In en, this message translates to:
  /// **'Left Hand'**
  String get palmistry_left_hand_label;

  /// No description provided for @palmistry_right_hand_label.
  ///
  /// In en, this message translates to:
  /// **'Right Hand'**
  String get palmistry_right_hand_label;

  /// No description provided for @palmistry_take_photo.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get palmistry_take_photo;

  /// No description provided for @palmistry_choose_gallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get palmistry_choose_gallery;

  /// No description provided for @palmistry_remove_image.
  ///
  /// In en, this message translates to:
  /// **'Remove image'**
  String get palmistry_remove_image;

  /// No description provided for @palmistry_tap_to_capture.
  ///
  /// In en, this message translates to:
  /// **'Tap to capture'**
  String get palmistry_tap_to_capture;

  /// No description provided for @palmistry_analyze_button.
  ///
  /// In en, this message translates to:
  /// **'Analyze Palmistry'**
  String get palmistry_analyze_button;

  /// No description provided for @palmistry_both_required.
  ///
  /// In en, this message translates to:
  /// **'Please capture both left and right hand images'**
  String get palmistry_both_required;

  /// No description provided for @palmistry_tips.
  ///
  /// In en, this message translates to:
  /// **'Tips for best results:\n• Use good lighting\n• Keep palm flat and fingers spread\n• Avoid shadows on the palm\n• Capture the entire palm clearly'**
  String get palmistry_tips;

  /// No description provided for @palmistry_upload_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture image'**
  String get palmistry_upload_failed;

  /// No description provided for @palmistry_select_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to select image'**
  String get palmistry_select_failed;

  /// No description provided for @palmistry_upload_success.
  ///
  /// In en, this message translates to:
  /// **'Palmistry analysis completed'**
  String get palmistry_upload_success;

  /// No description provided for @palmistry_analysis_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload images'**
  String get palmistry_analysis_failed;

  /// No description provided for @palmistry_analysis_title.
  ///
  /// In en, this message translates to:
  /// **'Palmistry Analysis'**
  String get palmistry_analysis_title;

  /// No description provided for @palmistry_analysis_summary.
  ///
  /// In en, this message translates to:
  /// **'Analysis Summary'**
  String get palmistry_analysis_summary;

  /// No description provided for @palmistry_analysis_major_lines.
  ///
  /// In en, this message translates to:
  /// **'Major Palm Lines'**
  String get palmistry_analysis_major_lines;

  /// No description provided for @palmistry_analysis_mounts.
  ///
  /// In en, this message translates to:
  /// **'Palm Mounts'**
  String get palmistry_analysis_mounts;

  /// No description provided for @palmistry_analysis_fingers.
  ///
  /// In en, this message translates to:
  /// **'Finger Analysis'**
  String get palmistry_analysis_fingers;

  /// No description provided for @palmistry_analysis_predictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get palmistry_analysis_predictions;

  /// No description provided for @palmistry_analysis_health.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get palmistry_analysis_health;

  /// No description provided for @palmistry_analysis_career.
  ///
  /// In en, this message translates to:
  /// **'Career'**
  String get palmistry_analysis_career;

  /// No description provided for @palmistry_analysis_relationships.
  ///
  /// In en, this message translates to:
  /// **'Relationships'**
  String get palmistry_analysis_relationships;

  /// No description provided for @palmistry_analysis_longevity.
  ///
  /// In en, this message translates to:
  /// **'Longevity'**
  String get palmistry_analysis_longevity;

  /// No description provided for @onboarding_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboarding_back;

  /// No description provided for @onboarding_page_indicator.
  ///
  /// In en, this message translates to:
  /// **'Page {current} of {total}'**
  String onboarding_page_indicator(int current, int total);

  /// No description provided for @onboarding_skip_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to skip introduction and go to login'**
  String get onboarding_skip_hint;

  /// No description provided for @onboarding_back_hint.
  ///
  /// In en, this message translates to:
  /// **'Double tap to go back'**
  String get onboarding_back_hint;

  /// No description provided for @onboarding_slide1_title.
  ///
  /// In en, this message translates to:
  /// **'Career Guidance Made Simple'**
  String get onboarding_slide1_title;

  /// No description provided for @onboarding_slide1_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover Your Path'**
  String get onboarding_slide1_subtitle;

  /// No description provided for @onboarding_slide1_description.
  ///
  /// In en, this message translates to:
  /// **'Get personalized career guidance based on ancient wisdom and modern AI technology'**
  String get onboarding_slide1_description;

  /// No description provided for @onboarding_slide2_title.
  ///
  /// In en, this message translates to:
  /// **'Palmistry Analysis'**
  String get onboarding_slide2_title;

  /// No description provided for @onboarding_slide2_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Read Your Future'**
  String get onboarding_slide2_subtitle;

  /// No description provided for @onboarding_slide2_description.
  ///
  /// In en, this message translates to:
  /// **'Upload your palm image and receive detailed analysis of your life lines and destiny'**
  String get onboarding_slide2_description;

  /// No description provided for @onboarding_slide3_title.
  ///
  /// In en, this message translates to:
  /// **'Vedic Jyotish'**
  String get onboarding_slide3_title;

  /// No description provided for @onboarding_slide3_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Ancient Astrology'**
  String get onboarding_slide3_subtitle;

  /// No description provided for @onboarding_slide3_description.
  ///
  /// In en, this message translates to:
  /// **'Get insights from Vedic astrology based on your birth details and planetary positions'**
  String get onboarding_slide3_description;

  /// No description provided for @onboarding_slide4_title.
  ///
  /// In en, this message translates to:
  /// **'Numerology'**
  String get onboarding_slide4_title;

  /// No description provided for @onboarding_slide4_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Power of Numbers'**
  String get onboarding_slide4_subtitle;

  /// No description provided for @onboarding_slide4_description.
  ///
  /// In en, this message translates to:
  /// **'Discover the hidden meanings in your numbers and how they influence your life'**
  String get onboarding_slide4_description;

  /// No description provided for @onboarding_slide5_title.
  ///
  /// In en, this message translates to:
  /// **'Personalized Reports'**
  String get onboarding_slide5_title;

  /// No description provided for @onboarding_slide5_subtitle.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Insights'**
  String get onboarding_slide5_subtitle;

  /// No description provided for @onboarding_slide5_description.
  ///
  /// In en, this message translates to:
  /// **'Receive comprehensive PDF reports with actionable guidance for your career and life'**
  String get onboarding_slide5_description;

  /// No description provided for @onboarding_slide6_title.
  ///
  /// In en, this message translates to:
  /// **'Ready to Begin'**
  String get onboarding_slide6_title;

  /// No description provided for @onboarding_slide6_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Start Your Journey'**
  String get onboarding_slide6_subtitle;

  /// No description provided for @onboarding_slide6_description.
  ///
  /// In en, this message translates to:
  /// **'Join thousands of users who have found clarity and direction with DishaAjyoti'**
  String get onboarding_slide6_description;

  /// No description provided for @order_tracking_title.
  ///
  /// In en, this message translates to:
  /// **'Order Tracking'**
  String get order_tracking_title;

  /// No description provided for @order_tracking_order_details.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get order_tracking_order_details;

  /// No description provided for @order_tracking_order_id.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get order_tracking_order_id;

  /// No description provided for @order_tracking_service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get order_tracking_service;

  /// No description provided for @order_tracking_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get order_tracking_amount;

  /// No description provided for @order_tracking_order_date.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get order_tracking_order_date;

  /// No description provided for @order_tracking_payment_id.
  ///
  /// In en, this message translates to:
  /// **'Payment ID'**
  String get order_tracking_payment_id;

  /// No description provided for @order_tracking_completed_on.
  ///
  /// In en, this message translates to:
  /// **'Completed On'**
  String get order_tracking_completed_on;

  /// No description provided for @order_tracking_timeline.
  ///
  /// In en, this message translates to:
  /// **'Order Timeline'**
  String get order_tracking_timeline;

  /// No description provided for @order_tracking_order_placed.
  ///
  /// In en, this message translates to:
  /// **'Order Placed'**
  String get order_tracking_order_placed;

  /// No description provided for @order_tracking_payment_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed'**
  String get order_tracking_payment_confirmed;

  /// No description provided for @order_tracking_payment_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get order_tracking_payment_completed;

  /// No description provided for @order_tracking_payment_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get order_tracking_payment_pending;

  /// No description provided for @order_tracking_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get order_tracking_processing;

  /// No description provided for @order_tracking_processing_in_progress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get order_tracking_processing_in_progress;

  /// No description provided for @order_tracking_processing_waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get order_tracking_processing_waiting;

  /// No description provided for @order_tracking_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get order_tracking_completed;

  /// No description provided for @order_tracking_view_report.
  ///
  /// In en, this message translates to:
  /// **'View Report'**
  String get order_tracking_view_report;

  /// No description provided for @order_tracking_download_report.
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get order_tracking_download_report;

  /// No description provided for @order_tracking_opening_report.
  ///
  /// In en, this message translates to:
  /// **'Opening report...'**
  String get order_tracking_opening_report;

  /// No description provided for @order_tracking_downloading_report.
  ///
  /// In en, this message translates to:
  /// **'Downloading report...'**
  String get order_tracking_downloading_report;

  /// No description provided for @order_tracking_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Your order is waiting for payment confirmation'**
  String get order_tracking_status_pending;

  /// No description provided for @order_tracking_status_processing.
  ///
  /// In en, this message translates to:
  /// **'Your report is being generated'**
  String get order_tracking_status_processing;

  /// No description provided for @order_tracking_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Your report is ready to view'**
  String get order_tracking_status_completed;

  /// No description provided for @order_tracking_status_failed.
  ///
  /// In en, this message translates to:
  /// **'Order processing failed. Please contact support'**
  String get order_tracking_status_failed;

  /// No description provided for @order_tracking_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'This order has been cancelled'**
  String get order_tracking_status_cancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'hi',
        'kn',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'kn':
      return AppLocalizationsKn();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
