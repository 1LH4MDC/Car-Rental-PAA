import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modul6/config/api_config.dart';
import 'package:modul6/models/booking_model.dart';
import 'package:modul6/services/auth_service.dart';

class BookingService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<BookingModel>> getBookings() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      final List data = body['data']['bookings'] ?? [];
      return data.map((e) => BookingModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data booking');
    }
  }

  static Future<BookingModel> createBooking(BookingModel booking) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}');
    final headers = await _authHeaders();
    final response = await http.post(url, headers: headers, body: json.encode(booking.toJson()));
    final body = json.decode(response.body);
    if (response.statusCode == 201) {
      return BookingModel.fromJson(body['data']['booking']);
    } else {
      throw Exception(body['message'] ?? 'Gagal membuat booking');
    }
  }

  static Future<void> cancelBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/cancel');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal membatalkan booking');
    }
  }

  static Future<void> confirmBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/confirm');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal konfirmasi booking');
    }
  }

  static Future<void> completeBooking(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.bookingsPrefix}/$id/complete');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal menyelesaikan booking');
    }
  }
}