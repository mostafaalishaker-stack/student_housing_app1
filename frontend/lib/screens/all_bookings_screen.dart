import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({super.key});

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingProvider>().loadAllBookings();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'confirmed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'cancelled': return Colors.red;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final bp = context.read<BookingProvider>();
    await bp.updateStatus(id, status);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم ${status == 'confirmed' ? 'تأكيد' : status == 'cancelled' ? 'إلغاء' : 'رفض'} الحجز')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('جميع الحجوزات')),
      body: bp.loading
          ? const Center(child: CircularProgressIndicator())
          : bp.allBookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('لا توجد حجوزات', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: bp.allBookings.length,
                  itemBuilder: (_, i) {
                    final b = bp.allBookings[i];
                    final apt = b.apartment;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: _statusColor(b.status).withAlpha(30),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(b.typeIcon, style: const TextStyle(fontSize: 20), textAlign: TextAlign.center),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(b.typeText, style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text(apt?['title'] ?? 'شقة', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                      Text(b.dateInfo, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      if (b.bedCount != null)
                                        Text('عدد الأسرّة: ${b.bedCount}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                      if (b.message != null && b.message!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('رسالة: ${b.message}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _statusColor(b.status).withAlpha(20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(b.statusText, style: TextStyle(color: _statusColor(b.status), fontSize: 12)),
                                ),
                              ],
                            ),
                            if (b.status == 'pending') ...[
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _updateStatus(b.id, 'rejected'),
                                    icon: const Icon(Icons.close, size: 16),
                                    label: const Text('رفض'),
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                                  ),
                                  const SizedBox(width: 8),
                                  FilledButton.icon(
                                    onPressed: () => _updateStatus(b.id, 'confirmed'),
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('تأكيد'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
