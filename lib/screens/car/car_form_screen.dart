import 'package:flutter/material.dart';
import 'package:modul6/models/car_model.dart';
import 'package:modul6/services/car_service.dart';
import 'package:modul6/widgets/custom_text_field.dart';
import 'package:modul6/widgets/loading_indicator.dart';

class CarFormScreen extends StatefulWidget {
  final CarModel? car;
  const CarFormScreen({super.key, this.car});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _licensePlateController;
  late TextEditingController _colorController;
  late TextEditingController _priceController;
  late TextEditingController _seatsController;
  late TextEditingController _mileageController;
  late TextEditingController _locationController;
  late TextEditingController _descController;

  String _selectedType = 'sedan';
  String _selectedTransmission = 'manual';
  String _selectedFuel = 'bensin';
  bool _isAvailable = true;
  bool _isLoading = false;

  final List<String> _types = ['sedan', 'suv', 'mpv', 'hatchback', 'pickup', 'van'];
  final List<String> _transmissions = ['manual', 'automatic'];
  final List<String> _fuels = ['bensin', 'diesel', 'hybrid', 'electric'];

  @override
  void initState() {
    super.initState();
    final car = widget.car;
    _nameController = TextEditingController(text: car?.name ?? '');
    _brandController = TextEditingController(text: car?.brand ?? '');
    _modelController = TextEditingController(text: car?.model ?? '');
    _yearController = TextEditingController(text: car?.year != null ? car!.year.toString() : '');
    _licensePlateController = TextEditingController(text: car?.licensePlate ?? '');
    _colorController = TextEditingController(text: car?.color ?? '');
    _priceController = TextEditingController(text: car?.pricePerDay != null ? car!.pricePerDay.toStringAsFixed(0) : '');
    _seatsController = TextEditingController(text: car?.seats != null ? car!.seats.toString() : '');
    _mileageController = TextEditingController(text: car?.mileage?.toStringAsFixed(0) ?? '');
    _locationController = TextEditingController(text: car?.location ?? '');
    _descController = TextEditingController(text: car?.description ?? '');
    if (car != null) {
      if (_types.contains(car.type)) _selectedType = car.type;
      if (_transmissions.contains(car.transmission)) _selectedTransmission = car.transmission;
      if (_fuels.contains(car.fuel)) _selectedFuel = car.fuel;
      _isAvailable = car.isAvailable;
    }
  }

  Future<void> _saveCar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final carData = CarModel(
        id: widget.car?.id,
        name: _nameController.text.trim(),
        brand: _brandController.text.trim(),
        model: _modelController.text.isEmpty ? null : _modelController.text.trim(),
        type: _selectedType,
        year: int.parse(_yearController.text.trim()),
        licensePlate: _licensePlateController.text.trim(),
        color: _colorController.text.isEmpty ? null : _colorController.text.trim(),
        pricePerDay: double.parse(_priceController.text.trim()),
        seats: int.parse(_seatsController.text.trim()),
        transmission: _selectedTransmission,
        fuel: _selectedFuel,
        mileage: _mileageController.text.isEmpty ? null : double.parse(_mileageController.text.trim()),
        location: _locationController.text.isEmpty ? null : _locationController.text.trim(),
        description: _descController.text.isEmpty ? null : _descController.text.trim(),
        isAvailable: _isAvailable,
        images: widget.car?.images ?? [],
        features: widget.car?.features ?? [],
      );
      if (widget.car == null) {
        await CarService.createCar(carData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mobil berhasil ditambahkan'), backgroundColor: Colors.green),
        );
      } else {
        await CarService.updateCar(widget.car!.id!, carData);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mobil berhasil diperbarui'), backgroundColor: Colors.green),
        );
      }
      if (mounted) Navigator.pop(context, true);
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
    _nameController.dispose(); _brandController.dispose(); _modelController.dispose();
    _yearController.dispose(); _licensePlateController.dispose(); _colorController.dispose();
    _priceController.dispose(); _seatsController.dispose(); _mileageController.dispose();
    _locationController.dispose(); _descController.dispose();
    super.dispose();
  }

  Widget _buildDropdown(String label, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.toUpperCase()))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.car == null ? 'Tambah Mobil' : 'Edit Mobil'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Menyimpan data...')
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  CustomTextField(label: 'Nama Mobil *', controller: _nameController,
                      validator: (v) => v!.isEmpty ? 'Wajib diisi' : null),
                  Row(children: [
                    Expanded(child: CustomTextField(label: 'Merek *', controller: _brandController,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'Model', controller: _modelController)),
                  ]),
                  Row(children: [
                    Expanded(child: CustomTextField(label: 'Tahun *', controller: _yearController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'Plat Nomor *', controller: _licensePlateController,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                  ]),
                  Row(children: [
                    Expanded(child: CustomTextField(label: 'Harga/Hari *', controller: _priceController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                    const SizedBox(width: 12),
                    Expanded(child: CustomTextField(label: 'Kursi *', controller: _seatsController,
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null)),
                  ]),
                  CustomTextField(label: 'Warna', controller: _colorController),
                  CustomTextField(label: 'Jarak Tempuh (km)', controller: _mileageController,
                      keyboardType: TextInputType.number),
                  _buildDropdown('Tipe', _types, _selectedType, (v) => setState(() => _selectedType = v!)),
                  _buildDropdown('Transmisi', _transmissions, _selectedTransmission, (v) => setState(() => _selectedTransmission = v!)),
                  _buildDropdown('Bahan Bakar', _fuels, _selectedFuel, (v) => setState(() => _selectedFuel = v!)),
                  SwitchListTile(
                    title: const Text('Ketersediaan'),
                    subtitle: Text(_isAvailable ? 'Mobil tersedia' : 'Tidak tersedia'),
                    value: _isAvailable,
                    activeThumbColor: Colors.green,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _isAvailable = v),
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(label: 'Lokasi', controller: _locationController),
                  CustomTextField(label: 'Deskripsi', controller: _descController, maxLines: 3),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveCar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A1A2E),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}