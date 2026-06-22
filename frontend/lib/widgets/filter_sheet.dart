import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/apartment_provider.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('تصفية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(onPressed: () { Navigator.pop(context); }, child: const Text('إغلاق')),
            ],
          ),
          const SizedBox(height: 16),
          const Text('الجنس', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(label: const Text('الجميع'), selected: true, onSelected: (_) { Navigator.pop(context); }),
              ChoiceChip(label: const Text('طلاب'), selected: false, onSelected: (_) { Navigator.pop(context); }),
              ChoiceChip(label: const Text('طالبات'), selected: false, onSelected: (_) { Navigator.pop(context); }),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
