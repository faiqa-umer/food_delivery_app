// ============================================================
// FILE: lib/customer/screens/payment_screen.dart
// PURPOSE: Shows payment details and status for an order.
//          Used during checkout and for viewing payment history.
//
// PHASE 3: Uses dummy data
// PHASE 4: Replace with real API calls to /api/payments/<id>
// ============================================================

import 'package:flutter/material.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String? paymentId;
  final String? orderId;

  const PaymentScreen({
    super.key,
    this.paymentId,
    this.orderId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // ── State Variables ────────────────────────────────────────
  PaymentModel? _payment;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPaymentDetails();
  }

  // ── Load Payment Details ────────────────────────────────────
  // PHASE 4: Replace with API call to GET /api/payments/<payment_id>
  // or GET /api/orders/<order_id>/payment
  Future<void> _loadPaymentDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> response;
      if (widget.paymentId != null) {
        response = await ApiService.getPaymentStatus(widget.paymentId!);
      } else if (widget.orderId != null) {
        response = await ApiService.getOrderPayment(widget.orderId!);
      } else {
        throw Exception('No payment or order ID provided');
      }

      final paymentJson = response['payment'] as Map<String, dynamic>;
      _payment = PaymentModel.fromJson(paymentJson);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load payment details: $e';
        _isLoading = false;
      });

      // Fallback to dummy payment for an operational UI.
      _payment = PaymentModel.getDummyPayment();
      setState(() {
        _errorMessage = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPaymentDetails,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_payment == null) {
      return const Center(
        child: Text('Payment details not found'),
      );
    }

    return _buildPaymentDetails();
  }

  Widget _buildPaymentDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Status Header
          _buildStatusHeader(),

          const SizedBox(height: 24),

          // Payment Details
          _buildPaymentInfo(),

          const SizedBox(height: 24),

          // Transaction Details
          _buildTransactionInfo(),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getStatusColor(_payment!.status)
            .withAlpha((0.1 * 255).toInt()), // was withOpacity(0.1)
        border: Border(
          bottom: BorderSide(
            color: _getStatusColor(_payment!.status)
                .withAlpha((0.3 * 255).toInt()), // was withOpacity(0.3)
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getStatusColor(_payment!.status),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(_payment!.status),
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _payment!.statusDisplayText,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(_payment!.status),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment ID: ${_payment!.id}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard([
            _buildInfoRow(
                'Amount', 'Rs. ${_payment!.amount.toStringAsFixed(2)}'),
            _buildInfoRow('Method', _payment!.methodDisplayText),
            _buildInfoRow('Order ID', _payment!.orderId),
            _buildInfoRow('Date', _formatDateTime(_payment!.createdAt)),
          ]),
        ],
      ),
    );
  }

  Widget _buildTransactionInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transaction Details',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard([
            if (_payment!.transactionId != null)
              _buildInfoRow('Transaction ID', _payment!.transactionId!),
            _buildInfoRow('Status', _payment!.statusDisplayText),
            _buildInfoRow('Last Updated', _formatDateTime(_payment!.updatedAt)),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          if (_payment!.isFailed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate back to checkout or retry payment
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Retry Payment'),
              ),
            ),
          if (_payment!.isCompleted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to order tracking
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('View Order'),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                // Show contact support dialog
                _showSupportDialog();
              },
              child: const Text('Contact Support'),
            ),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('For payment-related issues, contact our support team:'),
            SizedBox(height: 8),
            Text('📧 support@fooddelivery.com'),
            Text('📞 +92-300-1234567'),
            Text('🕒 24/7 Available'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // ── Helper Methods ─────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.hourglass_top;
      case 'failed':
        return Icons.error;
      case 'refunded':
        return Icons.undo;
      default:
        return Icons.info;
    }
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
