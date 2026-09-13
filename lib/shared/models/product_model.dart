class ProductModel {
  final int id;
  final int farmerId;
  final String cropName;
  final double quantityKg;
  final double pricePerKg;
  final String qualityGrade;
  final String farmingType;
  final String location;
  final String? harvestDate;
  final bool exportOnly;
  final bool active;

  const ProductModel({required this.id, required this.farmerId, required this.cropName, required this.quantityKg, required this.pricePerKg, required this.qualityGrade, required this.farmingType, required this.location, this.harvestDate, required this.exportOnly, required this.active});

  factory ProductModel.fromJson(Map<String, dynamic> j) => ProductModel(
    id: (j['id'] as num).toInt(), farmerId: (j['farmer_id'] as num).toInt(), cropName: j['crop_name'] as String,
    quantityKg: (j['quantity_kg'] as num).toDouble(), pricePerKg: (j['price_per_kg'] as num).toDouble(),
    qualityGrade: j['quality_grade'] as String, farmingType: j['farming_type'] as String, location: j['location'] as String,
    harvestDate: j['harvest_date'] as String?, exportOnly: j['export_only'] as bool? ?? false, active: j['active'] as bool? ?? true,
  );
}
