import 'package:flutter/material.dart';

import '../../../../shared/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onDelete;
  final VoidCallback? onBuy;

  const ProductCard({
    super.key,
    required this.product,
    this.onDelete,
    this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = product.cropName.trim().isEmpty
        ? '?'
        : product.cropName.trim().substring(0, 1).toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(firstLetter),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    product.cropName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (product.exportOnly) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('EXPORT'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${product.quantityKg.toStringAsFixed(0)} kg available',
            ),
            Text(
              '₹${product.pricePerKg.toStringAsFixed(2)} / kg',
            ),
            Text(
              '${product.qualityGrade} • '
              '${product.farmingType} • '
              '${product.location}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (onDelete != null || onBuy != null) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (onDelete != null)
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Delete product',
                      icon: const Icon(Icons.delete_outline),
                    ),
                  if (onBuy != null) ...[
                    const SizedBox(width: 8),

                    // Gives the button a finite width.
                    SizedBox(
                      width: 110,
                      child: FilledButton.icon(
                        onPressed: onBuy,
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 18,
                        ),
                        label: const Text('Buy'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
