import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // IMPORTANT: Change this to your Laravel backend URL
  static const String baseUrl = 'http://localhost:8000/api';
  // For local development in Windsurf/Chrome
  // Use 'http://10.0.2.2:8000/api' for Android emulator
  // Use 'http://localhost:8000/api' for web/Windows development

  static String? _token;

  // Initialize token from storage
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  // Save token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear token
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Get headers
  static Map<String, String> _getHeaders({bool needsAuth = false}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _getHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _getHeaders(),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await saveToken(data['token']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  // Logout
  static Future<void> logout() async {
    try {
      await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: _getHeaders(needsAuth: true),
      );
    } finally {
      await clearToken();
    }
  }

  // Get all clothing items
  static Future<List<dynamic>> getClothingItems({
    int? categoryId,
    String? size,
    String? status,
    String? search,
  }) async {
    var uri = Uri.parse('$baseUrl/clothing');

    final queryParams = <String, String>{};
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (size != null) queryParams['size'] = size;
    if (status != null) queryParams['status'] = status;
    if (search != null) queryParams['search'] = search;

    if (queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] as List;
    } else {
      throw Exception('Failed to load clothing items');
    }
  }

  // Get single clothing item
  static Future<Map<String, dynamic>> getClothingItem(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/clothing/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load clothing item');
    }
  }

  // Create rental
  static Future<Map<String, dynamic>> createRental({
    required String rentalDate,
    required String returnDate,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rentals'),
      headers: _getHeaders(needsAuth: true),
      body: jsonEncode({
        'rental_date': rentalDate,
        'return_date': returnDate,
        'notes': notes,
        'items': items,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create rental');
    }
  }

  // Get my rentals
  static Future<List<dynamic>> getMyRentals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rentals/my'),
      headers: _getHeaders(needsAuth: true),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to load rentals');
    }
  }

  // Create payment
  static Future<Map<String, dynamic>> createPayment({
    required int rentalId,
    required double amount,
    required String method,
    String? transactionReference,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: _getHeaders(needsAuth: true),
      body: jsonEncode({
        'rental_id': rentalId,
        'amount': amount,
        'method': method,
        'transaction_reference': transactionReference,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create payment');
    }
  }

  // Create cash payment
  static Future<Map<String, dynamic>> createCashPayment({
    required int rentalId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/cash'),
      headers: _getHeaders(needsAuth: true),
      body: jsonEncode({
        'rental_id': rentalId,
        'amount': amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to create cash payment');
    }
  }

  // Process card payment
  static Future<Map<String, dynamic>> processCardPayment({
    required int rentalId,
    required double amount,
    required String stripePaymentId,
    required String paymentIntentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/card'),
      headers: _getHeaders(needsAuth: true),
      body: jsonEncode({
        'rental_id': rentalId,
        'amount': amount,
        'stripe_payment_id': stripePaymentId,
        'payment_intent_id': paymentIntentId,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to process card payment');
    }
  }

  // Get payment status
  static Future<Map<String, dynamic>> getPaymentStatus(int rentalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/payments/status/$rentalId'),
      headers: _getHeaders(needsAuth: true),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to get payment status');
    }
  }

  // Get pending cash payments (admin)
  static Future<List<dynamic>> getPendingCashPayments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/payments/pending-cash'),
      headers: _getHeaders(needsAuth: true),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['pending_payments'] as List;
    } else {
      throw Exception('Failed to get pending cash payments');
    }
  }

  // Confirm cash payment (admin)
  static Future<Map<String, dynamic>> confirmCashPayment({
    required int rentalId,
    required double amountReceived,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/payments/confirm-cash/$rentalId'),
      headers: _getHeaders(needsAuth: true),
      body: jsonEncode({
        'amount_received': amountReceived,
        'notes': notes,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to confirm cash payment');
    }
  }

  // Clear all rentals for current user
  static Future<Map<String, dynamic>> clearAllRentals() async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rentals/clear-all'),
      headers: _getHeaders(needsAuth: true),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to clear rentals');
    }
  }

  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: _getHeaders(needsAuth: true),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Failed to load user profile');
    }
  }
}