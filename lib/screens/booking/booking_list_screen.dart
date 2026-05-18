import 'package:flutter/material.dart';
import 'package:modul6/models/booking_model.dart';
import 'package:modul6/services/auth_service.dart';
import 'package:modul6/services/booking_service.dart';
import 'package:modul6/widgets/loading_indicator.dart';
import 'package:modul6/screens/booking/booking_form_screen.dart';
import 'package:modul6/screens/payment/payment_form_screen.dart';

class BookingListScreen extends StatefulWidget {
  final String? carId;
  final String? carName;

  const BookingListScreen({super.key, this.carId, this.carName});

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  List<BookingModel> _bookings = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchBookings();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final bookings = await BookingService.getBookings();
      if (mounted) setState(() => _bookings = bookings);
    } catch (e) {
      if (mounted) {
        setState(
            () => _errorMessage = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _displayDays(BookingModel booking) {
    if (booking.totalDays > 0) return booking.totalDays;
    return booking.endDate.difference(booking.startDate).inDays;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Booking'),
        content: const Text('Yakin ingin membatalkan booking ini?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Tidak')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await BookingService.cancelBooking(booking.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Booking dibatalkan'),
                backgroundColor: Colors.orange),
          );
          _fetchBookings();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(e.toString().replaceAll('Exception: ', '')),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  Future<void> _confirmBooking(String id) async {
    try {
      await BookingService.confirmBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking dikonfirmasi!'),
              backgroundColor: Colors.blue),
        );
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeBooking(String id) async {
    try {
      await BookingService.completeBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Booking selesai!'),
              backgroundColor: Colors.green),
        );
        _fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.carName != null
            ? 'Booking: ${widget.carName}'
            : 'Daftar Booking'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat data booking...')
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                          onPressed: _fetchBookings,
                          child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : _bookings.isEmpty
                  ? const Center(child: Text('Belum ada booking'))
                  : RefreshIndicator(
                      onRefresh: _fetchBookings,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _bookings.length,
                        itemBuilder: (context, index) {
                          final booking = _bookings[index];

                          
                          final days = _displayDays(booking);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // ── Header ──────────────────────────────
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Booking #${booking.id?.substring(0, 8) ?? '-'}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _statusColor(booking.status)
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                              color: _statusColor(
                                                  booking.status)),
                                        ),
                                        child: Text(
                                          _statusLabel(booking.status),
                                          style: TextStyle(
                                              color: _statusColor(
                                                  booking.status),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20),

                                  // ── Info Booking ─────────────────────────
                                  _infoRow(Icons.calendar_today, 'Mulai',
                                      _formatDate(booking.startDate)),
                                  _infoRow(
                                      Icons.calendar_today_outlined,
                                      'Selesai',
                                      _formatDate(booking.endDate)),
                                  // ✅ Pakai days (hasil _displayDays) bukan booking.totalDays
                                  _infoRow(Icons.access_time, 'Durasi',
                                      '$days hari'),
                                  _infoRow(Icons.payments_outlined, 'Total',
                                      'Rp ${_formatPrice(booking.totalPrice)}'),

                                  const SizedBox(height: 12),

                                  // ── Tombol aksi USER ─────────────────────
                                  if (_role == 'user') ...[
                                    if (booking.status == 'pending') ...[
                                      Row(children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PaymentFormScreen(
                                                        booking: booking),
                                              ),
                                            ).then((_) => _fetchBookings()),
                                            icon: const Icon(Icons.payment,
                                                size: 16),
                                            label: const Text('Bayar'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                _cancelBooking(booking),
                                            icon: const Icon(
                                                Icons.cancel_outlined,
                                                size: 16),
                                            label: const Text('Batalkan'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: Colors.red,
                                              side: const BorderSide(
                                                  color: Colors.red),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ],

                                  // ── Tombol aksi ADMIN ────────────────────
                                  if (_role == 'admin') ...[
                                    Row(children: [
                                      if (booking.status == 'pending')
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _confirmBooking(booking.id!),
                                            icon: const Icon(
                                                Icons.check_circle_outline,
                                                size: 16),
                                            label: const Text('Konfirmasi'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                        ),
                                      if (booking.status == 'confirmed') ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () =>
                                                _completeBooking(booking.id!),
                                            icon: const Icon(Icons.done_all,
                                                size: 16),
                                            label: const Text('Selesaikan'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ]),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: _role == 'user' && widget.carId != null
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingFormScreen(
                      carId: widget.carId!, carName: widget.carName ?? ''),
                ),
              ).then((_) => _fetchBookings()),
              backgroundColor: const Color(0xFF1A1A2E),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Buat Booking',
                  style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ',
              style:
                  TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

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