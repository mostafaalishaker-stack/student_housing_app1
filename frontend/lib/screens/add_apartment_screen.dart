import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/apartment_provider.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AddApartmentScreen extends StatefulWidget {
  const AddApartmentScreen({super.key});

  @override
  State<AddApartmentScreen> createState() => _AddApartmentScreenState();
}

class _AddApartmentScreenState extends State<AddApartmentScreen> {
  final _form = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();

  String _district = 'الحي الأول';
  int _bedrooms = 1;
  int _bathrooms = 1;
  int _totalRooms = 1;
  int _totalBeds = 2;
  String _gender = 'any';
  bool _furnished = false;
  bool _allowRoomBooking = true;
  bool _allowBedBooking = false;
  final _roomPriceCtrl = TextEditingController();
  final _bedPriceCtrl = TextEditingController();
  final List<File> _images = [];
  final List<String> _selectedAmenities = [];

  final _allAmenities = [
    'WiFi', 'تكييف', 'مطبخ', 'ثلاجة', 'غسالة', 'تلفزيون',
    'سخان', 'مروحة', 'شرفة', 'مصعد', 'موقف سيارات', 'أمن',
  ];

  final _districts = [
    'الحي الأول', 'الحي الثاني', 'الحي الثالث', 'الحي الرابع',
    'الحي الخامس', 'الحي السادس', 'الحي السابع', 'الحي الثامن',
    'الجامعة', 'المدينة الجامعية',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    _areaCtrl.dispose();
    _roomPriceCtrl.dispose();
    _bedPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage();
    setState(() => _images.addAll(files.map((f) => File(f.path))));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر صورة واحدة على الأقل')));
      return;
    }
    final body = {
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'price': double.parse(_priceCtrl.text),
      'location': _locationCtrl.text,
      'district': _district,
      'bedrooms': _bedrooms,
      'bathrooms': _bathrooms,
      'area': _areaCtrl.text.isNotEmpty ? double.parse(_areaCtrl.text) : null,
      'amenities': _selectedAmenities,
      'furnished': _furnished,
      'gender': _gender,
      'totalRooms': _totalRooms,
      'totalBeds': _totalBeds,
      'availableRooms': _totalRooms,
      'availableBeds': _totalBeds,
      'pricePerRoom': _roomPriceCtrl.text.isNotEmpty ? double.parse(_roomPriceCtrl.text) : null,
      'pricePerBed': _bedPriceCtrl.text.isNotEmpty ? double.parse(_bedPriceCtrl.text) : null,
      'allowRoomBooking': _allowRoomBooking,
      'allowBedBooking': _allowBedBooking,
      'available': true,
    };

    try {
      final res = await ApiService.post('/apartments', body);
      if (res.statusCode == 201) {
        final data = jsonDecode(res.body);
        final aptId = data['apartment']['id'];
        if (_images.isNotEmpty) {
          await ApiService.uploadFiles('/apartments/$aptId/images', _images, 'images');
        }
        if (!mounted) return;
        context.read<ApartmentProvider>().loadApartments(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إضافة الشقة بنجاح')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: ${res.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة شقة جديدة')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'عنوان الشقة', border: OutlineInputBorder()),
                validator: (v) => v != null && v.isNotEmpty ? null : 'أدخل عنواناً',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'الوصف', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (v) => v != null && v.isNotEmpty ? null : 'أدخل وصفاً',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceCtrl,
                      decoration: const InputDecoration(labelText: 'السعر (ج.م)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (v) => v != null && double.tryParse(v) != null ? null : 'أدخل سعراً صحيحاً',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _areaCtrl,
                      decoration: const InputDecoration(labelText: 'المساحة (م²)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(labelText: 'العنوان التفصيلي', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _district,
                decoration: const InputDecoration(labelText: 'الحي', border: OutlineInputBorder()),
                items: _districts.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                onChanged: (v) => setState(() => _district = v!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStepper('غرف النوم', _bedrooms, (v) => setState(() => _bedrooms = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStepper('الحمامات', _bathrooms, (v) => setState(() => _bathrooms = v))),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'الجنس', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('للجميع')),
                  DropdownMenuItem(value: 'male', child: Text('طلاب')),
                  DropdownMenuItem(value: 'female', child: Text('طالبات')),
                ],
                onChanged: (v) => setState(() => _gender = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('مفروشة'),
                value: _furnished,
                onChanged: (v) => setState(() => _furnished = v),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildStepper('إجمالي الغرف', _totalRooms, (v) => setState(() => _totalRooms = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildStepper('إجمالي الأسرّة', _totalBeds, (v) => setState(() => _totalBeds = v))),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _roomPriceCtrl,
                      decoration: const InputDecoration(labelText: 'سعر الغرفة (ج.م)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _bedPriceCtrl,
                      decoration: const InputDecoration(labelText: 'سعر السرير (ج.م)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('يسمح بحجز غرفة'),
                value: _allowRoomBooking,
                onChanged: (v) => setState(() => _allowRoomBooking = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('يسمح بحجز سرير'),
                value: _allowBedBooking,
                onChanged: (v) => setState(() => _allowBedBooking = v),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 16),
              Text('الخدمات', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 4,
                children: _allAmenities.map((a) => FilterChip(
                  label: Text(a),
                  selected: _selectedAmenities.contains(a),
                  onSelected: (sel) {
                    setState(() {
                      sel ? _selectedAmenities.add(a) : _selectedAmenities.remove(a);
                    });
                  },
                )).toList(),
              ),
              const SizedBox(height: 16),
              Text('الصور', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: [
                  ..._images.map((f) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(f, width: 100, height: 100, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _images.remove(f)),
                          child: Container(
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.red),
                            child: const Icon(Icons.close, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  )),
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add_a_photo, color: Colors.grey), Text('إضافة', style: TextStyle(color: Colors.grey, fontSize: 12))],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(onPressed: _submit, child: const Text('إضافة الشقة', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(String label, int value, ValueChanged<int> onChanged) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > 0 ? () => onChanged(value - 1) : null,
        ),
        Text('$value', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => onChanged(value + 1),
        ),
      ],
    );
  }
}
