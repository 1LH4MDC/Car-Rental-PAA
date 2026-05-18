class PaymentModel {
  final String? id;
  final String bookingId;
  final double amount;
  final String method;
  final String? bankName;
  final String? accountNumber;
  final String? accountName;
  final String? transactionId;
  final String? proofOfPayment;
  final String status;
  final String? notes;
  final DateTime? createdAt;

  PaymentModel({
    this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    this.bankName,
    this.accountNumber,
    this.accountName,
    this.transactionId,
    this.proofOfPayment,
    this.status = 'pending',
    this.notes,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id'] as String?,
      bookingId:
          (json['booking'] is Map ? json['booking']['_id'] : json['booking'])
                  as String? ??
              '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      method: json['method'] as String? ?? 'transfer_bank',
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      accountName: json['accountName'] as String?,
      transactionId: json['transactionId'] as String?,
      proofOfPayment: json['proofOfPayment'] as String?,
      status: json['status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'bookingId': bookingId,
      'method': method,
    };

    if (method == 'transfer_bank') {
      // Transfer bank: kirim detail rekening + transactionId
      if (bankName != null) map['bankName'] = bankName;
      if (accountNumber != null) map['accountNumber'] = accountNumber;
      if (accountName != null) map['accountName'] = accountName;
      if (transactionId != null) map['transactionId'] = transactionId;
    } else {
      // E-Wallet & Credit Card: wajib transactionId
      if (transactionId != null) map['transactionId'] = transactionId;
    }

    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;
    return map;
  }
}