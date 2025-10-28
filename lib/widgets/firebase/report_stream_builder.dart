import 'package:flutter/material.dart';
import '../../models/firebase/service_report_model.dart';
import '../../services/firebase/firestore_service.dart';

/// StreamBuilder widget for real-time report updates
/// Handles listener lifecycle automatically
class ReportStreamBuilder extends StatefulWidget {
  final String reportId;
  final Widget Function(BuildContext context, ServiceReport report) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;

  const ReportStreamBuilder({
    Key? key,
    required this.reportId,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ReportStreamBuilder> createState() => _ReportStreamBuilderState();
}

class _ReportStreamBuilderState extends State<ReportStreamBuilder> {
  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ServiceReport?>(
      stream: _firestoreService.watchReport(widget.reportId),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return widget.errorBuilder
                  ?.call(context, snapshot.error.toString()) ??
              Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
        }

        // Handle no data state
        if (!snapshot.hasData || snapshot.data == null) {
          return widget.errorBuilder?.call(context, 'Report not found') ??
              const Center(child: Text('Report not found'));
        }

        // Build with report data
        return widget.builder(context, snapshot.data!);
      },
    );
  }

  @override
  void dispose() {
    // Stream subscription is automatically disposed by StreamBuilder
    super.dispose();
  }
}

/// StreamBuilder widget for real-time user reports list
class UserReportsStreamBuilder extends StatefulWidget {
  final String userId;
  final Widget Function(BuildContext context, List<ServiceReport> reports)
      builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final int limit;

  const UserReportsStreamBuilder({
    Key? key,
    required this.userId,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.limit = 20,
  }) : super(key: key);

  @override
  State<UserReportsStreamBuilder> createState() =>
      _UserReportsStreamBuilderState();
}

class _UserReportsStreamBuilderState extends State<UserReportsStreamBuilder> {
  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ServiceReport>>(
      stream: _firestoreService.watchUserReports(
        widget.userId,
        limit: widget.limit,
      ),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return widget.errorBuilder
                  ?.call(context, snapshot.error.toString()) ??
              Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
        }

        // Handle no data state
        if (!snapshot.hasData) {
          return widget.errorBuilder?.call(context, 'No reports found') ??
              const Center(child: Text('No reports found'));
        }

        // Build with reports list
        return widget.builder(context, snapshot.data!);
      },
    );
  }

  @override
  void dispose() {
    // Stream subscription is automatically disposed by StreamBuilder
    super.dispose();
  }
}

/// StreamBuilder widget for real-time order updates
class OrderStreamBuilder extends StatefulWidget {
  final String orderId;
  final Widget Function(BuildContext context, dynamic order) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;

  const OrderStreamBuilder({
    Key? key,
    required this.orderId,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<OrderStreamBuilder> createState() => _OrderStreamBuilderState();
}

class _OrderStreamBuilderState extends State<OrderStreamBuilder> {
  final FirestoreService _firestoreService = FirestoreService.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestoreService.watchOrder(widget.orderId),
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
              const Center(child: CircularProgressIndicator());
        }

        // Handle error state
        if (snapshot.hasError) {
          return widget.errorBuilder
                  ?.call(context, snapshot.error.toString()) ??
              Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
        }

        // Handle no data state
        if (!snapshot.hasData || snapshot.data == null) {
          return widget.errorBuilder?.call(context, 'Order not found') ??
              const Center(child: Text('Order not found'));
        }

        // Build with order data
        return widget.builder(context, snapshot.data!);
      },
    );
  }

  @override
  void dispose() {
    // Stream subscription is automatically disposed by StreamBuilder
    super.dispose();
  }
}
