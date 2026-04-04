import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:ceygo_app/core/widgets/gradient_background.dart';
import 'package:ceygo_app/features/owner/data/owner_repository.dart';
import 'package:ceygo_app/features/owner/presentation/providers/owner_providers.dart';
import 'package:ceygo_app/features/home/presentation/providers/home_providers.dart';
import 'package:ceygo_app/features/home/domain/models/car.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  final Car? vehicle;

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

  String _brand = '';
  String _brandLogo = '';
  String _transmission = 'Auto';
  String _fuelType = 'Petrol';
  bool _airportPickup = false;
  bool _isLoading = false;
  String _loadingStatus = '';

  // Image handling
  final List<_SelectedImage> _selectedImages = [];
  final List<String> _existingImageUrls = [];
  final ImagePicker _picker = ImagePicker();

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
    if (v != null) {
      _brand = v.brand;
      _brandLogo = v.brandLogo;
      _transmission = v.transmission;
      _fuelType = v.fuelType;
      // Load existing images
      _existingImageUrls.addAll(v.images);
      if (v.imageUrl.isNotEmpty && !_existingImageUrls.contains(v.imageUrl)) {
        _existingImageUrls.insert(0, v.imageUrl);
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _seatsCtrl.dispose();
    _plateCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  int get _totalImageCount => _existingImageUrls.length + _selectedImages.length;

  Future<void> _pickImages() async {
    final remaining = 5 - _totalImageCount;
    if (remaining <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 images allowed')),
      );
      return;
    }

    try {
      final List<XFile> picked = await _picker.pickMultiImage(
        imageQuality: 90,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked.isEmpty) return;

      final toAdd = picked.take(remaining);
      for (final xfile in toAdd) {
        final bytes = await xfile.readAsBytes();
        // Compress using flutter_image_compress
        final compressed = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 1200,
          minHeight: 800,
          quality: 75,
          format: CompressFormat.jpeg,
        );
        setState(() {
          _selectedImages.add(_SelectedImage(
            bytes: compressed,
            file: File(xfile.path),
          ));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick images: $e')),
        );
      }
    }
  }

  void _removeNewImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  void _removeExistingImage(int index) {
    setState(() => _existingImageUrls.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_brand.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a brand')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingStatus = 'Preparing...';
    });

    try {
      final repo = ref.read(ownerRepositoryProvider);
      List<String> uploadedUrls = [];

      // Upload new images if any
      if (_selectedImages.isNotEmpty) {
        setState(() => _loadingStatus = 'Uploading images...');
        final imageBytes = _selectedImages.map((img) => img.bytes).toList();
        uploadedUrls = await repo.uploadVehicleImages(imageBytes);
      }

      // Combine existing + newly uploaded
      final allImages = [..._existingImageUrls, ...uploadedUrls];
      final primaryImage = allImages.isNotEmpty ? allImages.first : null;

      setState(() => _loadingStatus = _isEditing ? 'Updating vehicle...' : 'Adding vehicle...');

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
          if (primaryImage != null) 'imageUrl': primaryImage,
          'images': allImages,
        });
      } else {
        await repo.addVehicle(
          name: _nameCtrl.text.trim(),
          brand: _brand,
          brandLogo: _brandLogo.isNotEmpty ? _brandLogo : null,
          imageUrl: primaryImage,
          pricePerDay: double.parse(_priceCtrl.text.trim()),
          seats: int.parse(_seatsCtrl.text.trim()),
          transmission: _transmission,
          fuelType: _fuelType,
          plateNo: _plateCtrl.text.trim(),
          airportPickupAvailable: _airportPickup,
          location: _locationCtrl.text.isNotEmpty ? _locationCtrl.text.trim() : null,
          images: allImages,
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
      if (mounted) setState(() {
        _isLoading = false;
        _loadingStatus = '';
      });
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
                // Image Picker Section
                _buildLabel('Vehicle Photos (up to 5)'),
                _buildImagePicker(),

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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                              if (_loadingStatus.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(_loadingStatus, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                                ),
                            ],
                          )
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

  Widget _buildImagePicker() {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // Existing images (from server)
          ..._existingImageUrls.asMap().entries.map((entry) => _buildImageTile(
            child: Image.network(entry.value, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
            onRemove: () => _removeExistingImage(entry.key),
          )),
          // Newly picked images
          ..._selectedImages.asMap().entries.map((entry) => _buildImageTile(
            child: Image.file(entry.value.file, fit: BoxFit.cover),
            onRemove: () => _removeNewImage(entry.key),
            sizeLabel: _formatBytes(entry.value.bytes.length),
          )),
          // Add button
          if (_totalImageCount < 5)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: 110,
                height: 120,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 36, color: Colors.grey.shade400),
                    const SizedBox(height: 6),
                    Text(
                      'Add Photo',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '${_totalImageCount}/5',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageTile({required Widget child, required VoidCallback onRemove, String? sizeLabel}) {
    return Container(
      width: 110,
      height: 120,
      margin: const EdgeInsets.only(right: 10),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 110, height: 120, child: child),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
          if (sizeLabel != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(sizeLabel, style: const TextStyle(color: Colors.white, fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
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

class _SelectedImage {
  final Uint8List bytes;
  final File file;
  _SelectedImage({required this.bytes, required this.file});
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
