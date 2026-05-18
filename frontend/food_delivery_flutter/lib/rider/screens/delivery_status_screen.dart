// ============================================================
// FILE: lib/rider/screens/delivery_status_screen.dart
// PURPOSE: Shows delivery assignments and status updates for riders.
//          Allows riders to update delivery status and track orders.
//
// PHASE 3: Uses dummy data
// PHASE 4: Replace with real API calls to /api/deliveries and /api/orders
// ============================================================

import 'package:flutter/material.dart';
import '../../models/delivery_model.dart';

class DeliveryStatusScreen extends StatefulWidget {
  const DeliveryStatusScreen({super.key});

  @override
  State<DeliveryStatusScreen> createState() => _DeliveryStatusScreenState();
}

class _DeliveryStatusScreenState extends State<DeliveryStatusScreen> {
  // ── State Variables ────────────────────────────────────────
  List<DeliveryModel> _deliveries = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  // ── Load Rider's Deliveries ────────────────────────────────
  // PHASE 4: Replace with API call to GET /api/deliveries?rider_id=<rider_id>
  Future<void> _loadDeliveries() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // PHASE 3: Load dummy deliveries
      _deliveries = DeliveryModel.getDummyDeliveries();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load deliveries: $e';
        _isLoading = false;
      });
    }
  }

  // ── Update Delivery Status ──────────────────────────────────
  // PHASE 4: Replace with API call to PATCH /api/deliveries/<delivery_id>
  Future<void> _updateDeliveryStatus(
      String deliveryId, String newStatus) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 1));

      // PHASE 3: Update local state
      setState(() {
        final index = _deliveries.indexWhere((d) => d.id == deliveryId);
        if (index != -1) {
          _deliveries[index] = DeliveryModel(
            id: _deliveries[index].id,
            orderId: _deliveries[index].orderId,
            riderId: _deliveries[index].riderId,
            status: newStatus,
            currentLocation: _deliveries[index].currentLocation,
            pickupTime: _deliveries[index].pickupTime,
            deliveryTime: newStatus == 'delivered'
                ? DateTime.now().toIso8601String()
                : null,
            estimatedDeliveryTime: _deliveries[index].estimatedDeliveryTime,
            actualDeliveryTime: newStatus == 'delivered'
                ? DateTime.now().toIso8601String()
                : null,
            deliveryAddress: _deliveries[index].deliveryAddress,
            customerPhone: _deliveries[index].customerPhone,
            notes: _deliveries[index].notes,
            createdAt: _deliveries[index].createdAt,
            updatedAt: DateTime.now().toIso8601String(),
          );
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Delivery status updated to ${newStatus.replaceAll('_', ' ')}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveries,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadDeliveries,
        tooltip: 'Refresh Deliveries',
        child: const Icon(Icons.refresh),
      ),
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
              onPressed: _loadDeliveries,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_deliveries.isEmpty) {
      return _buildEmptyState();
    }

    return _buildDeliveriesList();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delivery_dining,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No deliveries assigned',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You will receive delivery assignments soon',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadDeliveries,
            icon: const Icon(Icons.refresh),
            label: const Text('Check for Updates'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesList() {
    // Sort deliveries by priority: pending first, then in_progress, then completed
    final sortedDeliveries = List<DeliveryModel>.from(_deliveries)
      ..sort((a, b) {
        final priorityOrder = [
          'assigned',
          'picked_up',
          'in_progress',
          'delivered'
        ];
        final aPriority = priorityOrder.indexOf(a.status);
        final bPriority = priorityOrder.indexOf(b.status);
        return aPriority.compareTo(bPriority);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDeliveries.length,
      itemBuilder: (context, index) {
        final delivery = sortedDeliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${delivery.orderId.substring(delivery.orderId.length - 6)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(delivery.status)
                        .withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getStatusColor(delivery.status)
                          .withAlpha((0.3 * 255).round()),
                    ),
                  ),
                  child: Text(
                    delivery.statusDisplayText,
                    style: TextStyle(
                      color: _getStatusColor(delivery.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Delivery Address
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.red[400], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.deliveryAddress?.fullAddress ??
                        'Address not available',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Customer Phone
            if (delivery.customerPhone != null) ...[
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.green[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    delivery.customerPhone!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Estimated Delivery Time
            if (delivery.estimatedDeliveryTime != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.blue[400], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ETA: ${_formatDateTime(delivery.estimatedDeliveryTime!)}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Notes
            if (delivery.notes != null && delivery.notes!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, color: Colors.orange[400], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: ${delivery.notes}',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            _buildActionButtons(delivery),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DeliveryModel delivery) {
    final nextStatuses = _getNextStatuses(delivery.status);

    if (nextStatuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: nextStatuses.map((status) {
            return ElevatedButton(
              onPressed: () => _updateDeliveryStatus(delivery.id, status),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: _getStatusColor(status),
              ),
              child: Text(
                _getStatusButtonText(status),
                style: const TextStyle(fontSize: 12),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Helper Methods ─────────────────────────────────────────
  List<String> _getNextStatuses(String currentStatus) {
    switch (currentStatus) {
      case 'assigned':
        return ['picked_up'];
      case 'picked_up':
        return ['in_progress'];
      case 'in_progress':
        return ['delivered'];
      case 'delivered':
      case 'cancelled':
        return [];
      default:
        return [];
    }
  }

  String _getStatusButtonText(String status) {
    switch (status) {
      case 'picked_up':
        return 'Picked Up';
      case 'in_progress':
        return 'Start Delivery';
      case 'delivered':
        return 'Mark Delivered';
      default:
        return status.replaceAll('_', ' ').toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'assigned':
        return Colors.blue;
      case 'picked_up':
        return Colors.orange;
      case 'in_progress':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}
