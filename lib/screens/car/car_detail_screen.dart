import 'package:flutter/material.dart';
import 'package:modul6/models/car_model.dart';
import 'package:modul6/services/car_service.dart';
import 'package:modul6/services/auth_service.dart';
import 'package:modul6/screens/booking/booking_form_screen.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class CarDetailScreen extends StatefulWidget {
  final String carId;
  final String? carName;

  const CarDetailScreen({super.key, required this.carId, this.carName});

  @override
  State<CarDetailScreen> createState() => _CarDetailScreenState();
}

class _CarDetailScreenState extends State<CarDetailScreen> {
  CarModel? _car;
  bool _isLoading = true;
  String _errorMessage = '';
  String _role = 'user';

  static const _dark = Color(0xFF1A1A2E);

  @override
  void initState() {
    super.initState();
    _loadRole();
    _fetchCar();
  }

  Future<void> _loadRole() async {
    final role = await AuthService.getRole();
    if (mounted) setState(() => _role = role ?? 'user');
  }

  Future<void> _fetchCar() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    try {
      final car = await CarService.getCarById(widget.carId);
      if (mounted) setState(() => _car = car);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = _car;
    return Scaffold(
      backgroundColor: Colors.white,
      // ── Tombol Booking sticky ────────────────────────────────────────────
      bottomNavigationBar: (car != null && _role == 'user' && car.isAvailable)
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingFormScreen(carId: car.id!, carName: car.name),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  label: const Text(
                    'Booking Sekarang',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _dark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            )
          : null,

      body: _isLoading
          ? const LoadingIndicator(message: 'Memuat detail mobil...')
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text(_errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _fetchCar, child: const Text('Coba Lagi')),
                    ],
                  ),
                )
              : car == null
                  ? const Center(child: Text('Data tidak ditemukan'))
                  : CustomScrollView(
                      slivers: [
                        
                        SliverAppBar(
                          expandedHeight: 280,
                          pinned: true,
                          backgroundColor: _dark,
                          foregroundColor: Colors.white,
                          title: Text(widget.carName ?? car.name,
                              style: const TextStyle(fontSize: 16)),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Gradient latar
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Color(0xFF1A1A2E), Color(0xFF0F3460)],
                                    ),
                                  ),
                                ),
                                // Ikon mobil besar sebagai placeholder foto
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 40),
                                      Icon(
                                        _iconForType(car.type),
                                        size: 110,
                                        color: Colors.white.withValues(alpha: 0.13),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        car.brand.toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          fontSize: 13,
                                          letterSpacing: 5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Badge status
                                Positioned(
                                  top: 100,
                                  right: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: car.isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      car.isAvailable
                                          ? '✓ Tersedia'
                                          : '✗ Tidak Tersedia',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Konten ────────────────────────────────────────
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama & Harga
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(car.name,
                                              style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: _dark)),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${car.brand}'
                                            '${car.model != null ? ' • ${car.model}' : ''}'
                                            ' • ${car.year}',
                                            style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Rp ${_fmt(car.pricePerDay)}',
                                          style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green),
                                        ),
                                        Text('/hari',
                                            style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Rating
                                if (car.rating != null)
                                  Row(children: [
                                    _stars(car.rating!),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${car.rating!.toStringAsFixed(1)}'
                                      '${car.totalReviews != null ? ' (${car.totalReviews} ulasan)' : ''}',
                                      style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 13),
                                    ),
                                  ]),

                                // Lokasi
                                if (car.location != null) ...[
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    Icon(Icons.location_on,
                                        size: 15,
                                        color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(car.location!,
                                        style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 13)),
                                  ]),
                                ],

                                const SizedBox(height: 24),
                                const Divider(),
                                const SizedBox(height: 16),

                                // ── Spesifikasi 
                                const Text('Spesifikasi',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: _dark)),
                                const SizedBox(height: 12),
                                GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 0.95,
                                  children: [
                                    _specCard(Icons.event_seat, 'Kursi',
                                        '${car.seats} Orang'),
                                    _specCard(
                                      car.transmission == 'automatic'
                                          ? Icons.settings_suggest
                                          : Icons.settings,
                                      'Transmisi',
                                      car.transmission == 'automatic'
                                          ? 'Otomatis'
                                          : 'Manual',
                                    ),
                                    _specCard(Icons.local_gas_station, 'BBM',
                                        _fuelLabel(car.fuel)),
                                    _specCard(Icons.directions_car, 'Tipe',
                                        _typeLabel(car.type)),
                                    _specCard(Icons.palette, 'Warna',
                                        car.color ?? '-'),
                                    _specCard(
                                      Icons.speed,
                                      'Kilometer',
                                      car.mileage != null
                                          ? '${_fmt(car.mileage!)} km'
                                          : '-',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // ── Nomor Plat ───────────────────────────
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: _dark,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        const Icon(Icons.badge,
                                            color: Colors.white60, size: 18),
                                        const SizedBox(width: 8),
                                        const Text('Nomor Plat',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13)),
                                      ]),
                                      Text(
                                        car.licensePlate,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            letterSpacing: 3),
                                      ),
                                    ],
                                  ),
                                ),

                                // ── Deskripsi ────────────────────────────
                                if (car.description != null &&
                                    car.description!.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Text('Deskripsi',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _dark)),
                                  const SizedBox(height: 8),
                                  Text(car.description!,
                                      style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 14,
                                          height: 1.6)),
                                ],

                                // ── Fitur ────────────────────────────────
                                if (car.features.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  const Text('Fitur',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _dark)),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: car.features
                                        .map((f) => Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                              decoration: BoxDecoration(
                                                color: _dark.withValues(alpha: 0.07),
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                border: Border.all(
                                                    color: _dark.withValues(alpha: 0.2)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.check_circle,
                                                      size: 14, color: _dark),
                                                  const SizedBox(width: 4),
                                                  Text(f,
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: _dark,
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ],

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }

  // ── Widget helpers 

  Widget _stars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: Colors.amber, size: 18);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: Colors.amber, size: 18);
        }
        return Icon(Icons.star_border, color: Colors.grey.shade400, size: 18);
      }),
    );
  }

  Widget _specCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: _dark, size: 22),
          const SizedBox(height: 6),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 12, color: _dark)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }



  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'suv':     return Icons.directions_car;
      case 'truck':
      case 'pickup':  return Icons.local_shipping;
      case 'van':     return Icons.airport_shuttle;
      case 'sport':   return Icons.speed;
      default:        return Icons.directions_car_filled;
    }
  }

  String _typeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'sedan':     return 'Sedan';
      case 'suv':       return 'SUV';
      case 'hatchback': return 'Hatchback';
      case 'mpv':       return 'MPV';
      case 'pickup':    return 'Pickup';
      case 'van':       return 'Van';
      case 'sport':     return 'Sport';
      default:          return type;
    }
  }

  String _fuelLabel(String fuel) {
    switch (fuel.toLowerCase()) {
      case 'bensin':
      case 'gasoline': return 'Bensin';
      case 'diesel':   return 'Diesel';
      case 'electric':
      case 'listrik':  return 'Listrik';
      case 'hybrid':   return 'Hybrid';
      default:         return fuel;
    }
  }

  String _fmt(double price) {
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