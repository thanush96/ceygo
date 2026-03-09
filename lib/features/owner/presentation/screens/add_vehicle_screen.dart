import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/owner/data/owner_repository.dart';
import 'package:ceygo_app/features/owner/presentation/providers/owner_providers.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  final Car? vehicle; // null for add, non-null for edit

  const AddVehicleScreen({super.key, this.vehicle});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _seatsCtrl;
  late TextEditingController _plateCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _imageUrlCtrl;

  String _brand = '';
  String _brandLogo = '';
  String _transmission = 'Auto';
  String _fuelType = 'Petrol';
  bool _airportPickup = false;
  bool _isLoading = false;

  bool get _isEditing => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _nameCtrl = TextEditingController(text: v?.name ?? '');
    _priceCtrl = TextEditingController(text: v?.pricePerDay.toStringAsFixed(0) ?? '');
    _seatsCtrl = TextEditingController(text: v?.seats.toString() ?? '4');
    _plateCtrl = TextEditingController(text: '');
    _locationCtrl = TextEditingController(text: v?.location ?? '');
    _imageUrlCtrl = TextEditingController(text: v?.imageUrl ?? '');
    if (v != null) {
      _brand = v.brand;
      _brandLogo = v.brandLogo;
      _transmission = v.transmission;
      _fuelType = v.fuelType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _seatsCtrl.dispose();
    _plateCtrl.dispose();
    _locationCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a brand')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(ownerRepositoryProvider);
      if (_isEditing) {
        await repo.updateVehicle(widget.vehicle!.id, {
          'name': _nameCtrl.text.trim(),
          'brand': _brand,
          'brandLogo': _brandLogo,
          'pricePerDay': double.parse(_priceCtrl.text.trim()),
          'seats': int.parse(_seatsCtrl.text.trim()),
          'transmission': _transmission,
          'fuelType': _fuelType,
          'airportPickupAvailable': _airportPickup,
          if (_locationCtrl.text.isNotEmpty) 'location': _locationCtrl.text.trim(),
          if (_imageUrlCtrl.text.isNotEmpty) 'imageUrl': _imageUrlCtrl.text.trim(),
        });
      } else {
        await repo.addVehicle(
          name: _nameCtrl.text.trim(),
          brand: _brand,
          brandLogo: _brandLogo.isNotEmpty ? _brandLogo : null,
          imageUrl: _imageUrlCtrl.text.isNotEmpty ? _imageUrlCtrl.text.trim() : null,
          pricePerDay: double.parse(_priceCtrl.text.trim()),
          seats: int.parse(_seatsCtrl.text.trim()),
          transmission: _transmission,
          fuelType: _fuelType,
          plateNo: _plateCtrl.text.trim(),
          airportPickupAvailable: _airportPickup,
          location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text.trim() : null,
        );
      }

      ref.invalidate(myVehiclesProvider);
      ref.invalidate(ownerStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Vehicle updated' : 'Vehicle added')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandsAsync = ref.watch(brandsProvider);

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => context.pop(),
          ),
          title: Text(
            _isEditing ? 'Edit Vehicle' : 'Add Vehicle',
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Preview
                if (_imageUrlCtrl.text.isNotEmpty)
                  Container(
                    height: 180,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey.shade200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _imageUrlCtrl.text,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),

                _buildLabel('Vehicle Name'),
                _buildTextField(_nameCtrl, 'e.g. Corolla', validator: (v) => v!.isEmpty ? 'Required' : null),

                _buildLabel('Brand'),
                brandsAsync.when(
                  data: (brands) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _brand.isNotEmpty && brands.any((b) => b['name'] == _brand) ? _brand : null,
                        hint: const Text('Select Brand'),
                        isExpanded: true,
                        items: brands.map((b) => DropdownMenuItem(
                          value: b['name'],
                          child: Row(
                            children: [
                              Image.network(b['logo']!, width: 24, height: 24, errorBuilder: (_, __, ___) => const SizedBox(width: 24)),
                              const SizedBox(width: 10),
                              Text(b['name']!),
                            ],
                          ),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            final selected = brands.firstWhere((b) => b['name'] == val);
                            setState(() {
                              _brand = val;
                              _brandLogo = selected['logo'] ?? '';
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => _buildTextField(TextEditingController(text: _brand), 'Enter brand name'),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Price/Day (Rs)'),
                          _buildTextField(_priceCtrl, 'e.g. 5000',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Seats'),
                          _buildTextField(_seatsCtrl, 'e.g. 4',
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                _buildLabel('Transmission'),
                Row(
                  children: [
                    _ToggleChip(label: 'Auto', selected: _transmission == 'Auto', onTap: () => setState(() => _transmission = 'Auto')),
                    const SizedBox(width: 10),
                    _ToggleChip(label: 'Manual', selected: _transmission == 'Manual', onTap: () => setState(() => _transmission = 'Manual')),
                  ],
                ),

                const SizedBox(height: 16),
                _buildLabel('Fuel Type'),
                Wrap(
                  spacing: 8,
                  children: ['Petrol', 'Diesel', 'Electric', 'Hybrid'].map((f) =>
                    _ToggleChip(label: f, selected: _fuelType == f, onTap: () => setState(() => _fuelType = f)),
                  ).toList(),
                ),

                if (!_isEditing) ...[
                  const SizedBox(height: 16),
                  _buildLabel('Plate Number'),
                  _buildTextField(_plateCtrl, 'e.g. CAB-1234',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],

                const SizedBox(height: 16),
                _buildLabel('Location'),
                _buildTextField(_locationCtrl, 'e.g. Colombo'),

                _buildLabel('Image URL'),
                _buildTextField(_imageUrlCtrl, 'https://...', onChanged: (_) => setState(() {})),

                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Airport Pickup Available'),
                  value: _airportPickup,
                  onChanged: (v) => setState(() => _airportPickup = v),
                  activeTrackColor: theme.primaryColor,
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(
                            _isEditing ? 'Update Vehicle' : 'Add Vehicle',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).primaryColor)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: selected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
