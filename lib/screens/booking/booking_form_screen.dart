import 'package:flutter/material.dart';
import 'package:modul6/models/booking_model.dart';
import 'package:modul6/services/booking_service.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class BookingFormScreen extends StatefulWidget {
  final String carId;
  final String carName;

  const BookingFormScreen({super.key, required this.carId, required this.carName});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _pickupController = TextEditingController(text: 'Kantor Pusat');
  final _returnController = TextEditingController(text: 'Kantor Pusat');

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? now)
          : (_endDate ?? (_startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 1)))),
      firstDate: isStart ? now : (_startDate ?? now).add(const Duration(days: 1)),
      lastDate: DateTime(now.year + 2),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A1A2E)),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && !_endDate!.isAfter(_startDate!)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final booking = BookingModel(
        carId: widget.carId,
        startDate: _startDate!,
        endDate: _endDate!,
        totalDays: _totalDays,
        totalPrice: 0,
        pickupLocation: _pickupController.text.trim(),
        returnLocation: _returnController.text.trim(),
        notes: _notesController.text.isEmpty ? null : _notesController.text.trim(),
      );
      await BookingService.createBooking(booking);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking berhasil! Silakan lakukan pembayaran.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pickupController.dispose();
    _returnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Booking'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Membuat booking...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Info Mobil
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1A1A2E).withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.directions_car, color: Color(0xFF1A1A2E), size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Mobil yang dipesan',
                                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(widget.carName,
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Text('Pilih Tanggal',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),

                    _buildDatePicker(
                      label: 'Tanggal Mulai',
                      date: _startDate,
                      icon: Icons.calendar_today,
                      onTap: () => _pickDate(isStart: true),
                    ),
                    const SizedBox(height: 12),
                    _buildDatePicker(
                      label: 'Tanggal Selesai',
                      date: _endDate,
                      icon: Icons.calendar_today_outlined,
                      onTap: () => _pickDate(isStart: false),
                    ),

                    if (_startDate != null && _endDate != null && _totalDays > 0) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.access_time, color: Colors.green, size: 20),
                            const SizedBox(width: 8),
                            Text('Durasi sewa: $_totalDays hari',
                                style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    const Text('Lokasi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _pickupController,
                      decoration: _inputDecoration('Lokasi Pengambilan', Icons.location_on),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _returnController,
                      decoration: _inputDecoration('Lokasi Pengembalian', Icons.location_off),
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    ),

                    const SizedBox(height: 24),
                    const Text('Catatan (opsional)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: _inputDecoration('Contoh: Butuh kursi bayi...', Icons.notes),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton.icon(
                      onPressed: _submitBooking,
                      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                      label: const Text('Buat Booking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A2E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1A1A2E)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Batal', style: TextStyle(fontSize: 16, color: Color(0xFF1A1A2E))),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
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
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: date != null ? const Color(0xFF1A1A2E) : Colors.grey.shade300,
            width: date != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(icon, color: date != null ? const Color(0xFF1A1A2E) : Colors.grey, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 2),
                  Text(
                    date != null
                        ? '${date.day} ${_monthName(date.month)} ${date.year}'
                        : 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: date != null ? FontWeight.w600 : FontWeight.normal,
                      color: date != null ? const Color(0xFF1A1A2E) : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return months[month];
  }
}