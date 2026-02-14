class BillboardItem {
  const BillboardItem({
    required this.id,
    required this.provinceName,
    required this.city,
    required this.area,
    required this.length,
    required this.height,
    required this.imageUrl,
    required this.code,
    required this.type,
  });

  final String id;
  final String provinceName;
  final String city;
  final String area;
  final String length;
  final String height;
  final String imageUrl;
  final String code;
  final String type;

  String get dimensionLabel => '${length}×${height}';

  factory BillboardItem.fromJson(Map<String, dynamic> json) {
    return BillboardItem(
      id: json['id']?.toString() ?? '',
      provinceName: json['province_name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      length: json['length']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}
