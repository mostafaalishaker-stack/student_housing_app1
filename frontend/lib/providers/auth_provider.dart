import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  String? get error => _error;

  Future<void> loadUser() async {
    final token = await ApiService.getToken();
    if (token == null) return;
    try {
      final res = await ApiService.get('/auth/me');
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        _user = User.fromJson(data['user']);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/login', {
        'email': email,
        'password': password,
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        _user = User.fromJson(data['user']);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'];
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'فشل الاتصال بالخادم';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, String? university) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await ApiService.post('/auth/register', {
        'name': name,
        'email': email,
        'password': password,
        'university': university ?? '',
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        _user = User.fromJson(data['user']);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'];
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'فشل الاتصال بالخادم';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> googleSignIn() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        _loading = false;
        notifyListeners();
        return false;
      }
      final googleAuth = await googleUser.authentication;
      if (googleAuth.idToken == null) {
        _error = 'فشل الحصول على توثيق Google';
        _loading = false;
        notifyListeners();
        return false;
      }
      final res = await ApiService.post('/auth/google', {
        'idToken': googleAuth.idToken,
      });
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        _user = User.fromJson(data['user']);
        _loading = false;
        notifyListeners();
        return true;
      } else {
        _error = data['message'];
        _loading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'فشل تسجيل الدخول بـ Google';
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _user = null;
    try { await GoogleSignIn().signOut(); } catch (_) {}
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
