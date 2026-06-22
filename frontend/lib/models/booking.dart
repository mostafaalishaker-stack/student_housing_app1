class Booking {
  final String id;
  final String userId;
  final String apartmentId;
  final String type;
  final int? bedCount;
  final String? viewingDate;
  final String? viewingTime;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? message;
  final Map<String, dynamic>? apartment;

  Booking({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.type,
    this.bedCount,
    this.viewingDate,
    this.viewingTime,
    this.startDate,
    this.endDate,
    required this.status,
    this.message,
    this.apartment,
  });

  String get typeText {
    switch (type) {
      case 'entire': return 'الشقة كاملة';
      case 'room': return 'غرفة';
      case 'bed': return bedCount != null ? '$bedCount أسرّة' : 'سرير';
      case 'viewing': return 'طلب معاينة';
      default: return type;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'entire': return '🏠';
      case 'room': return '🚪';
      case 'bed': return '🛏️';
      case 'viewing': return '👁️';
      default: return '📋';
    }
  }

  String get statusText {
    switch (status) {
      case 'pending': return 'قيد الانتظار';
      case 'confirmed': return 'مؤكد';
      case 'cancelled': return 'ملغي';
      case 'rejected': return 'مرفوض';
      default: return status;
    }
  }

  String get dateInfo {
    if (type == 'viewing') {
      return 'معاينة: ${viewingDate ?? 'قريباً'} ${viewingTime != null ? "الساعة $viewingTime" : ''}';
    }
    if (startDate != null && endDate != null) {
      return '$startDate → $endDate';
    }
    return '';
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      apartmentId: json['apartmentId'] ?? '',
      type: json['type'] ?? 'entire',
      bedCount: json['bedCount'],
      viewingDate: json['viewingDate'],
      viewingTime: json['viewingTime'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      status: json['status'] ?? 'pending',
      message: json['message'],
      apartment: json['Apartment'],
    );
  }
}
