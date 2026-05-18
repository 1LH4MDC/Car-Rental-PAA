class BookingModel {
  final String? id;
  final String carId;
  final String? userId;
  final DateTime startDate;
  final DateTime endDate;
  final int totalDays;
  final double totalPrice;
  final String status;
  final String? pickupLocation;
  final String? returnLocation;
  final String? notes;
  final DateTime? createdAt;

  BookingModel({
    this.id,
    required this.carId,
    this.userId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.totalPrice,
    this.status = 'pending',
    this.pickupLocation,
    this.returnLocation,
    this.notes,
    this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['_id'] as String?,
      carId: (json['car'] is Map ? json['car']['_id'] : json['car']) as String? ?? '',
      userId: (json['user'] is Map ? json['user']['_id'] : json['user']) as String?,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      totalDays: json['totalDays'] as int? ?? 0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      pickupLocation: json['pickupLocation'] as String?,
      returnLocation: json['returnLocation'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'car': carId,
      'startDate': '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
      'endDate': '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
      'pickupLocation': pickupLocation ?? 'Kantor Pusat',
      'returnLocation': returnLocation ?? 'Kantor Pusat',
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}