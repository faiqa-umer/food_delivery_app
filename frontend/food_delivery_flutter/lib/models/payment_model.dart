// ============================================================
// FILE: lib/models/payment_model.dart
// PURPOSE: Dart data class for payment operations.
//          Mirrors the payment JSON from the Flask backend.
//
// USAGE:
//   final payment = PaymentModel.fromJson(jsonMap);
//   print(payment.status);
// ============================================================

class PaymentModel {
  final String id;
  final String orderId;
  final String userId;
  final double amount;
  final String method;
  final String status;
  final String? transactionId;
  final String createdAt;
  final String updatedAt;

  const PaymentModel({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: json['status'] as String,
      transactionId: json['transaction_id'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'user_id': userId,
      'amount': amount,
      'method': method,
      'status': status,
      'transaction_id': transactionId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  static PaymentModel getDummyPayment() {
    return PaymentModel(
      id: 'pay001',
      orderId: 'order001',
      userId: 'user123',
      amount: 40.48,
      method: 'jazzcash',
      status: 'completed',
      transactionId: 'JAZZ_order001_1705318800',
      createdAt: '2024-01-15T12:00:00Z',
      updatedAt: '2024-01-15T12:01:00Z',
    );
  }

  static List<PaymentModel> getDummyList() {
    return [
      getDummyPayment(),
      PaymentModel(
        id: 'pay002',
        orderId: 'order002',
        userId: 'user456',
        amount: 38.97,
        method: 'card',
        status: 'completed',
        transactionId: 'CARD_order002_1705322400',
        createdAt: '2024-01-15T13:00:00Z',
        updatedAt: '2024-01-15T13:01:00Z',
      ),
    ];
  }

  // ── Helper Methods ─────────────────────────────────────────
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isRefunded => status == 'refunded';

  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'Processing';
      case 'completed':
        return 'Completed';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  String get methodDisplayText {
    switch (method) {
      case 'cash':
        return 'Cash on Delivery';
      case 'card':
        return 'Credit/Debit Card';
      case 'jazzcash':
        return 'JazzCash';
      case 'easypaisa':
        return 'Easypaisa';
      default:
        return method.toUpperCase();
    }
  }
}
