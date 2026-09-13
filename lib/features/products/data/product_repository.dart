import '../../../core/network/api_client.dart';
import '../../../shared/models/product_model.dart';

class ProductRepository {
  final ApiClient api;
  ProductRepository(this.api);

  Future<List<ProductModel>> list({bool exportOnly=false}) async {
    final r = await api.get('/products', queryParameters: {'export_only': exportOnly});
    return (r.data as List).map((e) => ProductModel.fromJson(Map<String,dynamic>.from(e))).toList();
  }
  Future<List<ProductModel>> mine() async {
    final r = await api.get('/products/mine');
    return (r.data as List).map((e) => ProductModel.fromJson(Map<String,dynamic>.from(e))).toList();
  }
  Future<ProductModel> create(Map<String,dynamic> data) async {
    final r = await api.post('/products', data: data);
    return ProductModel.fromJson(Map<String,dynamic>.from(r.data));
  }
  Future<void> delete(int id) => api.delete('/products/$id').then((_) {});
}
