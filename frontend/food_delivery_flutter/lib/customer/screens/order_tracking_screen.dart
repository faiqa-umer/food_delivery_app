// ============================================================
// FILE: lib/customer/screens/order_tracking_screen.dart
// PURPOSE: Shows order status, timeline, delivery tracking,
//          and real-time updates.
//
// PHASE 3: Uses dummy data and mock updates
// PHASE 4: Replace with real API calls to /api/orders/<id> and /api/deliveries/<id>
// ============================================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../models/delivery_model.dart';
import '../../services/api_service.dart';
import 'payment_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({
    super.key,
    required this.order,
  });

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  // ── State Variables ────────────────────────────────────────
  late OrderModel _currentOrder;
  DeliveryModel? _delivery;
  Timer? _updateTimer;
  bool _isLoading = false;

  // Order status timeline
  final List<Map<String, dynamic>> _statusSteps = [
    {
      'status': 'pending',
      'title': 'Order Placed',
      'description': 'Your order has been received',
      'icon': Icons.receipt,
      'color': Colors.blue,
    },
    {
      'status': 'confirmed',
      'title': 'Order Confirmed',
      'description': 'Restaurant has confirmed your order',
      'icon': Icons.check_circle,
      'color': Colors.green,
    },
    {
      'status': 'preparing',
      'title': 'Preparing',
      'description': 'Your food is being prepared',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'status': 'ready',
      'title': 'Ready for Pickup',
      'description': 'Your order is ready',
      'icon': Icons.takeout_dining,
      'color': Colors.purple,
    },
    {
      'status': 'out_for_delivery',
      'title': 'Out for Delivery',
      'description': 'Rider is on the way',
      'icon': Icons.delivery_dining,
      'color': Colors.blue,
    },
    {
      'status': 'delivered',
      'title': 'Delivered',
      'description': 'Enjoy your meal!',
      'icon': Icons.done_all,
      'color': Colors.green,
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    _refreshOrderStatus();
    _startStatusUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  // ── Load Delivery Information ──────────────────────────────
  // PHASE 4: Replace with API call to GET /api/deliveries/<order_id>
  Future<void> _loadDeliveryInfo() async {
    if (_currentOrder.deliveryId == null || _currentOrder.deliveryId!.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.getDeliveryInfo(_currentOrder.id);
      final deliveryJson = response['delivery'] as Map<String, dynamic>;
      _delivery = DeliveryModel.fromJson(deliveryJson);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load delivery info: $e')),
      );
    }
  }

  // ── Start Status Updates ───────────────────────────────────
  // PHASE 4: Replace with real-time updates (WebSocket/SSE)
  void _startStatusUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _refreshOrderStatus();
    });
  }

  // ── Refresh Order Status ───────────────────────────────────
  Future<void> _refreshOrderStatus() async {
    if (!mounted) return;

    try {
      final response = await ApiService.getOrderStatus(_currentOrder.id);
      final orderJson = response['order'] as Map<String, dynamic>;
      final updatedOrder = OrderModel.fromJson(orderJson);

      setState(() {
        _currentOrder = updatedOrder;
      });

      if (_currentOrder.deliveryId != null &&
          _currentOrder.deliveryId!.isNotEmpty) {
        await _loadDeliveryInfo();
      }
    } catch (_) {
      // Keep current order if refresh fails.
    }
  }

  // ── Get Current Status Index ───────────────────────────────
  int _getCurrentStatusIndex() {
    return _statusSteps
        .indexWhere((step) => step['status'] == _currentOrder.status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrderStatus,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildTrackingView(),
    );
  }

  Widget _buildTrackingView() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Info Header
          _buildOrderHeader(),

          const SizedBox(height: 24),

          // Status Timeline
          _buildStatusTimeline(),

          const SizedBox(height: 24),

          // Delivery Info (if applicable)
          if (_delivery != null) ...[
            _buildDeliveryInfo(),
            const SizedBox(height: 24),
          ],

          // Order Items
          _buildOrderItems(),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.blue[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${_currentOrder.id.substring(_currentOrder.id.length - 6)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentOrder.status),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _getStatusDisplayText(_currentOrder.status),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Total: Rs. ${_currentOrder.totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ordered ${_formatDateTime(_currentOrder.createdAt)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 12),
          if (_currentOrder.paymentId != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('View Payment'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        paymentId: _currentOrder.paymentId,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Status',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),
          ..._statusSteps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= _getCurrentStatusIndex();
            final isCurrent = index == _getCurrentStatusIndex();

            return _buildTimelineStep(
              step: step,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
              isLast: index == _statusSteps.length - 1,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required Map<String, dynamic> step,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline line and icon
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isCompleted ? step['color'] : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  step['icon'],
                  color: Colors.white,
                  size: 16,
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? step['color'] : Colors.grey[300],
                ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Step details
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCurrent
                  ? step['color'].withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent ? step['color'] : Colors.transparent,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step['title'],
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent ? step['color'] : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  step['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Information',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.delivery_dining, color: Colors.orange),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rider: ${_delivery!.riderId ?? "Not assigned"}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Status: ${_delivery!.statusDisplayText}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_delivery!.estimatedDeliveryTime != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.access_time, color: Colors.blue),
                        const SizedBox(width: 12),
                        Text(
                          'Estimated delivery: ${_formatDateTime(_delivery!.estimatedDeliveryTime!)}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                  if (_delivery!.isDelayed) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery is delayed',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Items',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...?_currentOrder.itemsDetails?.map((item) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.fastfood,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Menu Item ${item.menuItemId}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Quantity: ${item.quantity} × Rs. ${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (item.specialInstructions.isNotEmpty)
                            Text(
                              'Note: ${item.specialInstructions}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      'Rs. ${(item.quantity * item.price).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Helper Methods ─────────────────────────────────────────
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'confirmed':
        return Colors.green;
      case 'preparing':
        return Colors.orange;
      case 'ready':
        return Colors.purple;
      case 'out_for_delivery':
        return Colors.blue;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
