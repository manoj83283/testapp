class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double pricePerHour;
  final double pricePerDay;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricePerHour,
    required this.pricePerDay,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) => ServiceModel(
        id: json['_id'],
        name: json['name'],
        description: json['description'],
        pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
        pricePerDay: (json['pricePerDay'] ?? 0).toDouble(),
      );
}