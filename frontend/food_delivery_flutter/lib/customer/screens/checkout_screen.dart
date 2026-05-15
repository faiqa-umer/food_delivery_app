// ignore_for_file: unused_element
// ============================================================
// FILE: lib/customer/screens/checkout_screen.dart
// PURPOSE: Final step before placing order. Shows order summary,
//          delivery address form, payment method selection.
// ============================================================

import 'package:flutter/material.dart';
import '../../models/cart_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../services/api_service.dart';
import 'order_tracking_screen.dart';
import 'payment_screen.dart'; // ✅ Added import

class CheckoutScreen extends StatefulWidget {
  final CartModel cart;

  const CheckoutScreen({
    super.key,
    required this.cart,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ── Form Controllers ────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();

  // ── State Variables ─────────────────────────────────────────
  String _selectedPaymentMethod = 'cash';
  bool _isPlacingOrder = false;

  // Available payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'cash',
      'name': 'Cash on Delivery',
      'icon': Icons.money,
      'description': 'Pay when order is delivered',
    },
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
      'description': 'Visa, MasterCard, etc.',
    },
    {
      'id': 'jazzcash',
      'name': 'JazzCash',
      'icon': Icons.account_balance_wallet,
      'description': 'Mobile wallet payment',
    },
    {
      'id': 'easypaisa',
      'name': 'Easypaisa',
      'icon': Icons.account_balance_wallet,
      'description': 'Mobile wallet payment',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  void _loadSavedAddress() {
    final dummyAddress = DeliveryAddress.getDummyAddress();
    _streetController.text = dummyAddress.street;
    _cityController.text = dummyAddress.city;
    _stateController.text = dummyAddress.state;
    _zipController.text = dummyAddress.zip;
  }

  // ── Place Order ─────────────────────────────────────────────
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final deliveryAddress = DeliveryAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
      );

      // ── Step 1: Create Order ──
      debugPrint('📦 Creating order...');
      final orderResponse = await ApiService.createOrder(
        restaurantId: widget.cart.restaurantId ?? '',
        deliveryAddress: deliveryAddress.toJson(),
        totalAmount: widget.cart.totalAmount,
        paymentMethod: _selectedPaymentMethod,
      );
      debugPrint('✅ Order response: $orderResponse');

      final order =
          OrderModel.fromJson(orderResponse['order'] as Map<String, dynamic>);
      debugPrint('✅ Order created: ${order.id}');

      // ── Step 2: Process Payment ──
      debugPrint('💳 Processing payment for order: ${order.id}');
      await ApiService.processPayment(
        orderId: order.id,
        amount: order.totalAmount,
        paymentMethod: _selectedPaymentMethod,
      );
      debugPrint('✅ Payment processed successfully');

      // ── Step 3: Navigate to Payment Screen ✅ ──
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order placed successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              orderId: order.id,
            ),
          ),
        );
      }
    } catch (e) {
      // ✅ Debug print to see actual error
      debugPrint('❌ Order/Payment error: $e');

      // Fallback demo order if backend is unavailable
      final deliveryAddress = DeliveryAddress(
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
      );

      final order = OrderModel(
        id: 'order_new_${DateTime.now().millisecondsSinceEpoch}',
        userId: widget.cart.userId,
        restaurantId: widget.cart.restaurantId!,
        items: widget.cart.items.map((item) => item.id!).toList(),
        totalAmount: widget.cart.totalAmount,
        deliveryAddress: deliveryAddress,
        status: 'pending',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      if (mounted) {
        // ✅ Show payment screen even in demo mode
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(order: order),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Demo mode (error: $e)')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  // ── Process Payment (unused legacy mock) ───────────────────
  Future<PaymentModel> _processPayment(String orderId, double amount) async {
    await Future.delayed(const Duration(seconds: 1));
    return PaymentModel(
      id: 'pay_new_${DateTime.now().millisecondsSinceEpoch}',
      orderId: orderId,
      userId: widget.cart.userId,
      amount: amount,
      method: _selectedPaymentMethod,
      status: 'completed',
      transactionId:
          '${_selectedPaymentMethod.toUpperCase()}_${orderId}_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: _isPlacingOrder ? _buildLoadingView() : _buildCheckoutForm(),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Placing your order...',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we process your payment',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderSummary(),
          const Divider(height: 32),
          _buildDeliveryAddress(),
          const Divider(height: 32),
          _buildPaymentMethod(),
          const SizedBox(height: 24),
          _buildPlaceOrderButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...widget.cart.items.map((item) {
            final quantity = item.quantity;
            final price = quantity * item.price;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Menu Item ${item.menuItemId} x$quantity',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Rs. ${price.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            );
          }),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Rs. ${widget.cart.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Address',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Street address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _zipController,
              decoration: const InputDecoration(
                labelText: 'ZIP/Postal Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'ZIP code is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ..._paymentMethods.map((method) {
            final isSelected = method['id'] == _selectedPaymentMethod;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedPaymentMethod = method['id'];
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        method['icon'],
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              method['name'],
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            Text(
                              method['description'],
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Radio<String>(
                        value: method['id'],
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _placeOrder,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Place Order',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
