import 'package:flutter/material.dart';
import 'package:modul6/models/booking_model.dart';
import 'package:modul6/models/payment_model.dart';
import 'package:modul6/services/payment_service.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class PaymentFormScreen extends StatefulWidget {
  final BookingModel booking;
  const PaymentFormScreen({super.key, required this.booking});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionIdController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _bankNameController = TextEditingController(text: 'BCA');
  final _notesController = TextEditingController();

  String _selectedMethod = 'transfer_bank';
  bool _isLoading = false;

  // ✅ Fallback: hitung dari selisih tanggal jika totalDays = 0
  int get _displayDays {
    if (widget.booking.totalDays > 0) return widget.booking.totalDays;
    return widget.booking.endDate.difference(widget.booking.startDate).inDays;
  }

  // ✅ Cash dihapus — hanya 3 method yang dikenali backend
  final List<Map<String, dynamic>> _methods = [
    {'value': 'transfer_bank', 'label': 'Transfer Bank', 'icon': Icons.account_balance},
    {'value': 'e_wallet',      'label': 'E-Wallet',      'icon': Icons.wallet},
    {'value': 'credit_card',   'label': 'Kartu Kredit',  'icon': Icons.credit_card},
  ];

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final payment = PaymentModel(
        bookingId: widget.booking.id!,
        amount: widget.booking.totalPrice,
        method: _selectedMethod,
        bankName: _selectedMethod == 'transfer_bank'
            ? _bankNameController.text.trim() : null,
        accountNumber: _selectedMethod == 'transfer_bank'
            ? _accountNumberController.text.trim() : null,
        accountName: _selectedMethod == 'transfer_bank'
            ? _accountNameController.text.trim() : null,
        transactionId: _transactionIdController.text.isEmpty
            ? null : _transactionIdController.text.trim(),
        notes: _notesController.text.isEmpty
            ? null : _notesController.text.trim(),
      );
      await PaymentService.createPayment(payment);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pembayaran berhasil disubmit! Menunggu verifikasi admin.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _transactionIdController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _bankNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pembayaran'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memproses pembayaran...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Ringkasan Booking ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Ringkasan Booking',
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 8),
                          _summaryRow('ID Booking',
                              '#${widget.booking.id?.substring(0, 8) ?? '-'}'),
                          // ✅ Gunakan _displayDays bukan widget.booking.totalDays
                          _summaryRow('Durasi', '$_displayDays hari'),
                          _summaryRow('Tgl Mulai', _formatDate(widget.booking.startDate)),
                          _summaryRow('Tgl Selesai', _formatDate(widget.booking.endDate)),
                          const Divider(color: Colors.white24, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Pembayaran',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(
                                'Rp ${_formatPrice(widget.booking.totalPrice)}',
                                style: const TextStyle(
                                    color: Colors.orangeAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('Metode Pembayaran',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),

                    ...(_methods.map((m) => _buildMethodTile(m))),

                    // ── Form Transfer Bank ─────────────────────────────────
                    if (_selectedMethod == 'transfer_bank') ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Icon(Icons.info_outline,
                                  color: Colors.blue.shade700, size: 18),
                              const SizedBox(width: 8),
                              Text('Rekening Tujuan',
                                  style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.bold)),
                            ]),
                            const SizedBox(height: 6),
                            Text(
                              'BCA — 1234567890 (a.n. PT Car Rental)\n'
                              'BRI — 0987654321 (a.n. PT Car Rental)',
                              style: TextStyle(
                                  color: Colors.blue.shade800, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField(_bankNameController, 'Nama Bank',
                          Icons.account_balance,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                      const SizedBox(height: 12),
                      _buildField(_accountNumberController,
                          'Nomor Rekening Pengirim', Icons.dialpad,
                          keyboard: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                      const SizedBox(height: 12),
                      _buildField(_accountNameController,
                          'Nama Pemilik Rekening', Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                      const SizedBox(height: 12),
                      _buildField(_transactionIdController,
                          'ID Transaksi / Referensi', Icons.receipt_outlined,
                          validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),

                    // ── Form E-Wallet & Kartu Kredit ───────────────────────
                    ] else ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.purple.shade200),
                        ),
                        child: Row(children: [
                          Icon(Icons.info_outline,
                              color: Colors.purple.shade700, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Masukkan ID transaksi dari aplikasi '
                              'e-wallet / kartu kredit kamu',
                              style: TextStyle(
                                  color: Colors.purple.shade700, fontSize: 13),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 12),
                      _buildField(
                        _transactionIdController,
                        'ID Transaksi / Nomor Referensi',
                        Icons.receipt_outlined,
                        validator: (v) =>
                            v!.isEmpty ? 'ID Transaksi wajib diisi' : null,
                      ),
                    ],

                    const SizedBox(height: 12),
                    _buildField(_notesController, 'Catatan (opsional)',
                        Icons.notes, maxLines: 3),

                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: _submitPayment,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Submit Pembayaran',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1A1A2E)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal',
                          style: TextStyle(
                              fontSize: 16, color: Color(0xFF1A1A2E))),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    String? Function(String?)? validator,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A1A2E), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildMethodTile(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['value'];
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMethod = method['value'];
        _transactionIdController.clear();
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          color: isSelected
              ? const Color(0xFF1A1A2E).withValues(alpha: 0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            Icon(method['icon'] as IconData,
                color: isSelected ? const Color(0xFF1A1A2E) : Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method['label'] as String,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1A1A2E) : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF1A1A2E), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';

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