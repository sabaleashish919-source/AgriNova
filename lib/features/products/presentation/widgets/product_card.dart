import 'package:flutter/material.dart';
import '../../../../shared/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onDelete;
  final VoidCallback? onBuy;
  const ProductCard({super.key, required this.product, this.onDelete, this.onBuy});

  @override
  Widget build(BuildContext context) {
    final firstLetter = product.cropName.trim().isEmpty ? '?' : product.cropName.trim().substring(0, 1).toUpperCase();
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(backgroundColor: const Color(0xFFDDF2D8), foregroundColor: const Color(0xFF116B38), child: Text(firstLetter, style: const TextStyle(fontWeight: FontWeight.w800))),
            const SizedBox(width: 12),
            Expanded(child: Text(product.cropName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF113A23)))),
            if (product.exportOnly) const Chip(label: Text('EXPORT')),
          ]),
          const SizedBox(height: 16),
          Text('${product.quantityKg.toStringAsFixed(0)} kg available', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text('₹${product.pricePerKg.toStringAsFixed(2)} / kg', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF116B38))),
          const SizedBox(height: 7),
          Text('${product.qualityGrade} • ${product.farmingType}', style: const TextStyle(color: Color(0xFF66766B))),
          Text(product.location, style: const TextStyle(color: Color(0xFF66766B))),
          if (onDelete != null || (onBuy != null && !product.exportOnly)) ...[
            const SizedBox(height: 14),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              if (onDelete != null) IconButton(onPressed: onDelete, tooltip: 'Delete product', icon: const Icon(Icons.delete_outline)),
              if (onBuy != null && !product.exportOnly) ...[
                const SizedBox(width: 8),
                SizedBox(width: 110, child: FilledButton.icon(onPressed: onBuy, icon: const Icon(Icons.shopping_cart_outlined, size: 18), label: const Text('Buy'))),
              ],
            ]),
          ],
        ]),
      ),
    );
  }
}
