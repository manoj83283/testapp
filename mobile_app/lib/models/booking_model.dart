class BookingModel {
  final String id;
  final String serviceId;
  final String customerId;
  final String providerId;
  final String status;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.customerId,
    required this.providerId,
    required this.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) => BookingModel(
        id: json['_id'],
        serviceId: json['serviceId'],
        customerId: json['customerId'],
        providerId: json['providerId'],
        status: json['status'],
      );
}