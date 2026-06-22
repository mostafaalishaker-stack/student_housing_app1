import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../services/api_service.dart';

class ApartmentProvider extends ChangeNotifier {
  List<Apartment> _apartments = [];
  List<Apartment>? _filtered;
  bool _loading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedDistrict;
  double? _maxPrice;
  String? _gender;
  bool? _furnishedOnly;

  List<Apartment> get apartments => _filtered ?? _apartments;
  bool get loading => _loading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  Future<void> loadApartments({bool refresh = false}) async {
    if (_apartments.isNotEmpty && !refresh) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.get('/apartments');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _apartments = (data['apartments'] as List)
            .map((j) => Apartment.fromJson(j))
            .toList();
        _applyFilters();
      }
    } catch (e) {
      _error = 'فشل تحميل الشقق';
    }
    _loading = false;
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByDistrict(String? district) {
    _selectedDistrict = district;
    _applyFilters();
    notifyListeners();
  }

  void filterByMaxPrice(double? price) {
    _maxPrice = price;
    _applyFilters();
    notifyListeners();
  }

  void filterByGender(String? gender) {
    _gender = gender;
    _applyFilters();
    notifyListeners();
  }

  void filterByFurnished(bool? furnished) {
    _furnishedOnly = furnished;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedDistrict = null;
    _maxPrice = null;
    _gender = null;
    _furnishedOnly = null;
    _filtered = null;
    notifyListeners();
  }

  void _applyFilters() {
    var result = _apartments;
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((a) =>
        a.title.toLowerCase().contains(q) ||
        a.description.toLowerCase().contains(q) ||
        a.location.toLowerCase().contains(q)
      ).toList();
    }
    if (_selectedDistrict != null) {
      result = result.where((a) => a.district == _selectedDistrict).toList();
    }
    if (_maxPrice != null) {
      result = result.where((a) => a.price <= _maxPrice!).toList();
    }
    if (_gender != null && _gender != 'any') {
      result = result.where((a) => a.gender == _gender || a.gender == 'any').toList();
    }
    if (_furnishedOnly == true) {
      result = result.where((a) => a.furnished).toList();
    }
    _filtered = result;
  }
}
