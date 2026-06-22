import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _myBookings = [];
  List<Booking> _allBookings = [];
  bool _loading = false;
  String? _error;

  List<Booking> get myBookings => _myBookings;
  List<Booking> get allBookings => _allBookings;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadMyBookings() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/bookings/my');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _myBookings = (data['bookings'] as List)
            .map((j) => Booking.fromJson(j))
            .toList();
      }
    } catch (e) {
      _error = 'فشل تحميل الحجوزات';
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> loadAllBookings() async {
    _loading = true;
    notifyListeners();
    try {
      final res = await ApiService.get('/bookings');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _allBookings = (data['bookings'] as List)
            .map((j) => Booking.fromJson(j))
            .toList();
      }
    } catch (e) {
      _error = 'فشل تحميل الحجوزات';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createBooking({
    required String apartmentId,
    required String type,
    int? bedCount,
    String? viewingDate,
    String? viewingTime,
    String? startDate,
    String? endDate,
    String? message,
  }) async {
    try {
      final body = <String, dynamic>{
        'apartmentId': apartmentId,
        'type': type,
      };
      if (bedCount != null) body['bedCount'] = bedCount;
      if (viewingDate != null) body['viewingDate'] = viewingDate;
      if (viewingTime != null) body['viewingTime'] = viewingTime;
      if (startDate != null) body['startDate'] = startDate;
      if (endDate != null) body['endDate'] = endDate;
      if (message != null) body['message'] = message;

      final res = await ApiService.post('/bookings', body);
      if (res.statusCode == 201) {
        await loadMyBookings();
        return true;
      }
      final data = jsonDecode(res.body);
      _error = data['message'];
      return false;
    } catch (e) {
      _error = 'فشل الاتصال';
      return false;
    }
  }

  Future<bool> updateStatus(String bookingId, String status) async {
    try {
      final res = await ApiService.put('/bookings/$bookingId/status', {'status': status});
      if (res.statusCode == 200) {
        await loadAllBookings();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
