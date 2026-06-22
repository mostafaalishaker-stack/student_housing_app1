import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/apartment_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('لوحة التحكم')),
        body: const Center(child: Text('غير مصرح بالدخول')),
      );
    }
    final ap = context.watch<ApartmentProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/all-bookings'),
            icon: const Icon(Icons.calendar_month),
            label: const Text('الحجوزات'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 48),
                  const SizedBox(height: 8),
                  Text('مرحبا، ${auth.user?.name ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(auth.user?.email ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('لوحة التحكم'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text('جميع الحجوزات'),
              onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/all-bookings'); },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل خروج'),
              onTap: () { auth.logout(); Navigator.pushReplacementNamed(context, '/login'); },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ap.loadApartments(refresh: true),
        child: ap.loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: ap.apartments.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FilledButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/add-apartment'),
                        icon: const Icon(Icons.add),
                        label: const Text('إضافة شقة جديدة'),
                      ),
                    );
                  }
                  final a = ap.apartments[i - 1];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 50, height: 50,
                          child: a.images.isNotEmpty
                              ? Image.network(a.images[0], fit: BoxFit.cover)
                              : Container(color: Colors.grey[200], child: const Icon(Icons.image, color: Colors.grey)),
                        ),
                      ),
                      title: Text(a.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${a.price} ج.م - ${a.district}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => Navigator.push(context, MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(title: const Text('تعديل شقة')),
                                body: Center(child: Text('قريباً... تعديل ${a.title}')),
                              ),
                            )),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('حذف الشقة'),
                                content: Text('هل أنت متأكد من حذف "${a.title}"؟'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                  FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('حذف')),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
