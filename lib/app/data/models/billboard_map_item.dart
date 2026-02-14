class BillboardMapItem {
  const BillboardMapItem({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.area,
    required this.provinceId,
  });

  final String id;
  final double latitude;
  final double longitude;
  final String city;
  final String area;
  final String provinceId;

  bool get hasValidLocation => latitude != 0 && longitude != 0;

  factory BillboardMapItem.fromJson(Map<String, dynamic> json) {
    return BillboardMapItem(
      id: json['id']?.toString() ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0,
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      provinceId: json['province_id']?.toString() ?? '',
    );
  }
}
