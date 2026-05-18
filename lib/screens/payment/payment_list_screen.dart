import 'package:flutter/material.dart';
import 'package:modul6/models/payment_model.dart';
import 'package:modul6/services/auth_service.dart';
import 'package:modul6/services/payment_service.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  List<PaymentModel> _payments = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchPayments();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
  }

  Future<void> _fetchPayments() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final payments = await PaymentService.getPayments();
      if (mounted) setState(() => _payments = payments);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPayment(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verifikasi Pembayaran'),
        content: const Text('Konfirmasi pembayaran ini sudah diterima?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Ya, Verifikasi', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await PaymentService.verifyPayment(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pembayaran berhasil diverifikasi!'), backgroundColor: Colors.green),
          );
          _fetchPayments();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
        );
      }
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'verified': return Colors.green;
      case 'rejected': return Colors.red;
      case 'refunded': return Colors.purple;
      default: return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending': return 'Menunggu';
      case 'verified': return 'Terverifikasi';
      case 'rejected': return 'Ditolak';
      case 'refunded': return 'Direfund';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat pembayaran...')
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchPayments, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : _payments.isEmpty
                  ? const Center(child: Text('Belum ada data pembayaran'))
                  : RefreshIndicator(
                      onRefresh: _fetchPayments,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _payments.length,
                        itemBuilder: (context, index) {
                          final payment = _payments[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Payment #${payment.id?.substring(0, 8) ?? '-'}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(payment.status).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: _statusColor(payment.status)),
                                        ),
                                        child: Text(
                                          _statusLabel(payment.status),
                                          style: TextStyle(
                                            color: _statusColor(payment.status),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),

                                  // Info pembayaran
                                  _infoRow(Icons.payments_outlined, 'Total', 'Rp ${_formatPrice(payment.amount)}'),
                                  _infoRow(Icons.account_balance_wallet, 'Metode', payment.method.toUpperCase()),
                                  if (payment.bankName != null)
                                    _infoRow(Icons.account_balance, 'Bank', payment.bankName!),
                                  if (payment.accountNumber != null)
                                    _infoRow(Icons.dialpad, 'No. Rekening', payment.accountNumber!),
                                  if (payment.accountName != null)
                                    _infoRow(Icons.person_outline, 'Nama', payment.accountName!),
                                  if (payment.transactionId != null)
                                    _infoRow(Icons.receipt_outlined, 'ID Transaksi', payment.transactionId!),
                                  if (payment.notes != null)
                                    _infoRow(Icons.notes, 'Catatan', payment.notes!),
                                  if (payment.createdAt != null)
                                    _infoRow(Icons.access_time, 'Waktu',
                                        '${payment.createdAt!.day}/${payment.createdAt!.month}/${payment.createdAt!.year}'),

                                  // Tombol verifikasi (admin)
                                  if (_role == 'admin' && payment.status == 'pending') ...[
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _verifyPayment(payment.id!),
                                        icon: const Icon(Icons.verified, color: Colors.white, size: 18),
                                        label: const Text(
                                          'Verifikasi Pembayaran',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    String s = price.toStringAsFixed(0);
    String result = '';
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      count++;
      result = s[i] + result;
      if (count % 3 == 0 && i != 0) result = '.$result';
    }
    return result;
  }
}