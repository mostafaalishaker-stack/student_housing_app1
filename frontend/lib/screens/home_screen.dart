import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/apartment_provider.dart';
import '../widgets/apartment_card.dart';
import '../widgets/filter_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ApartmentProvider>().loadApartments();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const FilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ap = context.watch<ApartmentProvider>();
    final apartments = ap.apartments;

    return Scaffold(
      appBar: AppBar(
        title: const Text('سكنكم'),
        actions: [
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () => Navigator.pushNamed(context, '/admin'),
              tooltip: 'لوحة التحكم',
            ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () => Navigator.pushNamed(context, '/my-bookings'),
            tooltip: 'حجوزاتي',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
            tooltip: 'تسجيل خروج',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'بحث عن شقة...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(80),
                    ),
                    onChanged: (v) => ap.search(v),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _showFilters,
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
          ),
          if (apartments.isEmpty && !ap.loading)
            Expanded(child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('لا توجد شقق', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  if (ap.searchQuery.isNotEmpty)
                    TextButton(onPressed: ap.clearFilters, child: const Text('مسح البحث')),
                ],
              ),
            )),
          if (ap.loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => ap.loadApartments(refresh: true),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: apartments.length,
                  itemBuilder: (_, i) => ApartmentCard(apartment: apartments[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
