import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/product_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../data/product_repository.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository(ref.watch(apiClientProvider)));
final myProductsProvider = FutureProvider<List<ProductModel>>((ref) => ref.watch(productRepositoryProvider).mine());
final marketplaceProductsProvider = FutureProvider<List<ProductModel>>((ref) => ref.watch(productRepositoryProvider).list());
final exportProductsProvider = FutureProvider<List<ProductModel>>((ref) => ref.watch(productRepositoryProvider).list(exportOnly: true));
