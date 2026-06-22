import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<BookingProvider>().loadMyBookings();
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

  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزاتي')),
      body: bp.loading
          ? const Center(child: CircularProgressIndicator())
          : bp.myBookings.isEmpty
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
                  itemCount: bp.myBookings.length,
                  itemBuilder: (_, i) {
                    final b = bp.myBookings[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Container(
                          width: 50, height: 50,
                          decoration: BoxDecoration(
                            color: _statusColor(b.status).withAlpha(30),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(b.typeIcon, style: const TextStyle(fontSize: 22), textAlign: TextAlign.center),
                        ),
                        title: Text(b.typeText, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.apartment?['title'] ?? 'شقة', style: const TextStyle(fontSize: 13)),
                            Text(b.dateInfo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(b.status).withAlpha(20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(b.statusText, style: TextStyle(color: _statusColor(b.status), fontSize: 12)),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
