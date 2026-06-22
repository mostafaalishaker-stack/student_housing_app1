import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../models/apartment.dart';

class ApartmentDetailScreen extends StatefulWidget {
  final Apartment apartment;
  const ApartmentDetailScreen({super.key, required this.apartment});

  @override
  State<ApartmentDetailScreen> createState() => _ApartmentDetailScreenState();
}

class _ApartmentDetailScreenState extends State<ApartmentDetailScreen> {
  int _currentImage = 0;

  void _showBookingOptions() {
    if (!context.read<AuthProvider>().isLoggedIn) {
      Navigator.pushNamed(context, '/login');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BookingSheet(apartment: widget.apartment),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.apartment;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: a.images.isNotEmpty
                  ? Stack(
                      children: [
                        PageView.builder(
                          itemCount: a.images.length,
                          onPageChanged: (i) => setState(() => _currentImage = i),
                          itemBuilder: (_, i) => Image.network(a.images[i], fit: BoxFit.cover, width: double.infinity),
                        ),
                        if (a.images.length > 1)
                          Positioned(
                            bottom: 8,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(a.images.length, (i) => Container(
                                width: 8, height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentImage == i ? Colors.white : Colors.white38,
                                ),
                              )),
                            ),
                          ),
                      ],
                    )
                  : Container(color: Colors.grey[300], child: const Icon(Icons.image, size: 80)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (a.furnished)
                        _tag('مفروش', Colors.green),
                      const SizedBox(width: 6),
                      if (a.gender != 'any')
                        _tag(a.gender == 'male' ? 'للطلاب' : 'للطالبات', Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(a.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('${a.location} - ${a.district}', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('${a.price.toStringAsFixed(0)} ج.م', style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold,
                      )),
                      Text(' / شهرياً', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoChip(Icons.bed, '$bedrooms غرف'),
                      _infoChip(Icons.bathroom, '$bathrooms حمامات'),
                      if (a.area != null) _infoChip(Icons.square_foot, '${a.area!.toStringAsFixed(0)} م²'),
                      _infoChip(Icons.meeting_room, '${a.totalRooms} غرفة'),
                      if (a.totalBeds > 0) _infoChip(Icons.single_bed, '${a.totalBeds} سرير'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Booking options section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('خيارات الحجز', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _bookingOption(
                          icon: Icons.home,
                          label: 'الشقة كاملة',
                          price: '${a.price.toStringAsFixed(0)} ج.م/شهر',
                        ),
                        if (a.allowRoomBooking)
                          _bookingOption(
                            icon: Icons.meeting_room,
                            label: 'غرفة',
                            price: a.pricePerRoom != null ? '${a.pricePerRoom!.toStringAsFixed(0)} ج.م/شهر' : 'اسأل',
                            note: '${a.availableRooms} غرف متاحة',
                          ),
                        if (a.allowBedBooking)
                          _bookingOption(
                            icon: Icons.single_bed,
                            label: 'سرير (1 - 6)',
                            price: a.pricePerBed != null ? '${a.pricePerBed!.toStringAsFixed(0)} ج.م/شهر' : 'اسأل',
                            note: '${a.availableBeds} أسرّة متاحة',
                          ),
                        _bookingOption(
                          icon: Icons.visibility,
                          label: 'طلب معاينة',
                          price: 'مجاناً',
                          color: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                  Text('الوصف', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(a.description, style: TextStyle(color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 20),
                  Text('الخدمات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: a.amenities.map((am) => Chip(
                      label: Text(am, style: const TextStyle(fontSize: 13)),
                      avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _showBookingOptions,
              icon: const Icon(Icons.calendar_today),
              label: const Text('حجز أو طلب معاينة', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _bookingOption({
    required IconData icon,
    required String label,
    required String price,
    String? note,
    Color? color,
  }) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (note != null) ...[
            const SizedBox(width: 4),
            Text('($note)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
          const Spacer(),
          Text(price, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Bottom sheet for booking
class _BookingSheet extends StatefulWidget {
  final Apartment apartment;
  const _BookingSheet({required this.apartment});

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  String _selectedType = 'entire';
  int _bedCount = 1;
  final _msgCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateTime.now().toIso8601String().split('T')[0];
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final bp = context.read<BookingProvider>();

    bool ok;
    if (_selectedType == 'viewing') {
      ok = await bp.createBooking(
        apartmentId: widget.apartment.id,
        type: 'viewing',
        viewingDate: _dateCtrl.text,
        viewingTime: _timeCtrl.text.isNotEmpty ? _timeCtrl.text : null,
        message: _msgCtrl.text,
      );
    } else if (_selectedType == 'bed') {
      ok = await bp.createBooking(
        apartmentId: widget.apartment.id,
        type: 'bed',
        bedCount: _bedCount,
        startDate: _dateCtrl.text,
        endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        message: _msgCtrl.text,
      );
    } else if (_selectedType == 'room') {
      ok = await bp.createBooking(
        apartmentId: widget.apartment.id,
        type: 'room',
        startDate: _dateCtrl.text,
        endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        message: _msgCtrl.text,
      );
    } else {
      ok = await bp.createBooking(
        apartmentId: widget.apartment.id,
        type: 'entire',
        startDate: _dateCtrl.text,
        endDate: DateTime.now().add(const Duration(days: 30)).toIso8601String().split('T')[0],
        message: _msgCtrl.text,
      );
    }

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'تم إرسال الطلب بنجاح' : bp.error ?? 'فشل الإرسال'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.apartment;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20, right: 20, top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Text('نوع الحجز', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _buildTypeOption('entire', Icons.home, 'الشقة كاملة', '${a.price.toStringAsFixed(0)} ج.م/شهر'),
          if (a.allowRoomBooking)
            _buildTypeOption('room', Icons.meeting_room, 'غرفة', a.pricePerRoom != null ? '${a.pricePerRoom!.toStringAsFixed(0)} ج.م/شهر' : 'اسأل'),
          if (a.allowBedBooking)
            _buildTypeOption('bed', Icons.single_bed, 'سرير', a.pricePerBed != null ? '${a.pricePerBed!.toStringAsFixed(0)} ج.م/شهر' : 'اسأل'),
          _buildTypeOption('viewing', Icons.visibility, 'طلب معاينة', 'مجاناً'),

          if (_selectedType == 'bed') ...[
            const SizedBox(height: 12),
            Text('عدد الأسرّة', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8,
              children: List.generate(6, (i) => ChoiceChip(
                label: Text('${i + 1}'),
                selected: _bedCount == i + 1,
                onSelected: (v) => setState(() => _bedCount = i + 1),
              )),
            ),
          ],

          const SizedBox(height: 12),
          TextField(
            controller: _dateCtrl,
            decoration: InputDecoration(
              labelText: _selectedType == 'viewing' ? 'تاريخ المعاينة' : 'تاريخ البداية',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.calendar_today),
            ),
            readOnly: true,
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (date != null) _dateCtrl.text = date.toIso8601String().split('T')[0];
            },
          ),

          if (_selectedType == 'viewing') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _timeCtrl,
              decoration: const InputDecoration(
                labelText: 'الوقت المناسب (اختياري)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.access_time),
                hintText: 'مثال: 10:00 صباحاً',
              ),
            ),
          ],

          const SizedBox(height: 12),
          TextField(
            controller: _msgCtrl,
            decoration: const InputDecoration(
              labelText: 'رسالة (اختياري)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_selectedType == 'viewing' ? 'طلب معاينة' : 'تأكيد الحجز', style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type, IconData icon, String label, String price) {
    final selected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Theme.of(context).colorScheme.primaryContainer.withAlpha(80) : Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[300]!),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[600]),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
              const Spacer(),
              Text(price, style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
