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
    required this.view,
    required this.lighting,
    required this.phone,
    required this.latitude,
    required this.longitude,
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
  final String view;
  final String lighting;
  final String phone;
  final String latitude;
  final String longitude;

  String get dimensionLabel => '${length}×${height}';

  String get rentLabel => '${monthlyRent.isEmpty ? '1' : monthlyRent} تومان';

  bool get hasValidLocation {
    final lat = double.tryParse(latitude) ?? 0;
    final lon = double.tryParse(longitude) ?? 0;
    return lat != 0 && lon != 0;
  }

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
      view: json['view']?.toString() ?? '',
      lighting: json['lighting']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
    );
  }
}
