class BillboardItem {
  const BillboardItem({
    required this.id,
    required this.provinceId,
    required this.provinceName,
    required this.city,
    required this.area,
    required this.length,
    required this.height,
    required this.imageUrl,
    required this.code,
    required this.type,
    required this.monthlyRent,
  });

  final String id;
  final String provinceId;
  final String provinceName;
  final String city;
  final String area;
  final String length;
  final String height;
  final String imageUrl;
  final String code;
  final String type;
  final String monthlyRent;

  String get dimensionLabel => '${length}×${height}';

  String get rentLabel => '${monthlyRent.isEmpty ? '1' : monthlyRent} تومان / ماه';

  factory BillboardItem.fromJson(Map<String, dynamic> json) {
    return BillboardItem(
      id: json['id']?.toString() ?? '',
      provinceId: json['province_id']?.toString() ?? '',
      provinceName: json['province_name']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      length: json['length']?.toString() ?? '',
      height: json['height']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      monthlyRent: json['monthly_rent']?.toString() ?? '',
    );
  }
}
