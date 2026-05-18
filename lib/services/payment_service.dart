import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:modul6/config/api_config.dart';
import 'package:modul6/models/payment_model.dart';
import 'package:modul6/services/auth_service.dart';

class PaymentService {
  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthService.getToken();
    return {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'};
  }

  static Future<List<PaymentModel>> getPayments() async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}');
    final headers = await _authHeaders();
    final response = await http.get(url, headers: headers);
    final body = json.decode(response.body);
    if (response.statusCode == 200) {
      final List data = body['data']['payments'] ?? [];
      return data.map((e) => PaymentModel.fromJson(e)).toList();
    } else {
      throw Exception(body['message'] ?? 'Gagal mengambil data pembayaran');
    }
  }

  static Future<PaymentModel> createPayment(PaymentModel payment) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}');
    final headers = await _authHeaders();
    final response = await http.post(url, headers: headers, body: json.encode(payment.toJson()));
    final body = json.decode(response.body);
    if (response.statusCode == 201) {
      return PaymentModel.fromJson(body['data']['payment']);
    } else {
      throw Exception(body['message'] ?? 'Gagal submit pembayaran');
    }
  }

  static Future<void> verifyPayment(String id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.paymentsPrefix}/$id/verify');
    final headers = await _authHeaders();
    final response = await http.put(url, headers: headers);
    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Gagal verifikasi pembayaran');
    }
  }
}