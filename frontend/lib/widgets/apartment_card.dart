import 'package:flutter/material.dart';
import '../models/apartment.dart';
import '../screens/apartment_detail_screen.dart';

class ApartmentCard extends StatelessWidget {
  final Apartment apartment;
  const ApartmentCard({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final a = apartment;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ApartmentDetailScreen(apartment: a)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.images.isNotEmpty)
              SizedBox(
                height: 160,
                width: double.infinity,
                child: Image.network(a.images[0], fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (a.furnished)
                        Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(4)),
                          child: Text('مفروش', style: TextStyle(color: Colors.green[700], fontSize: 11)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text('${a.district}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(width: 12),
                      Icon(Icons.bed, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text('${a.bedrooms}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      if (a.area != null) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.square_foot, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text('${a.area!.toStringAsFixed(0)} م²', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                      if (a.totalBeds > 0) ...[
                        const SizedBox(width: 12),
                        Icon(Icons.single_bed, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text('${a.totalBeds}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${a.price.toStringAsFixed(0)} ج.م', style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      )),
                      Text('/شهر', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                      const Spacer(),
                      if (a.gender != 'any')
                        Chip(
                          label: Text(a.gender == 'male' ? 'طلاب' : 'طالبات', style: const TextStyle(fontSize: 11)),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
