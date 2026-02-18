import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../../../widgets/app_page_scaffold.dart';
import '../controllers/add_billboard_controller.dart';

class AddBillboardView extends GetView<AddBillboardController> {
  const AddBillboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPageScaffold(
      child: Container(
        color: const Color(0xFFE9ECEF),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 820),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'افزودن تابلو جدید',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _inputField(controller.codeController, hint: 'کد تابلو'),
                  const SizedBox(height: 12),
                  Obx(
                    () => _multiSelectField(
                      label: 'استان (چند انتخابی)',
                      valueText: controller.selectedProvincesLabel,
                      onTap: () {
                        _openProvincePicker(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(
                    () => _multiSelectField(
                      label: 'شهرها (چند انتخابی)',
                      valueText: controller.isLoadingCities.value
                          ? 'در حال دریافت شهرها...'
                          : controller.selectedCitiesLabel,
                      onTap: () {
                        _openCityPicker(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _inputField(controller.areaController, hint: 'منطقه / محور'),
                  const SizedBox(height: 12),
                  Obx(
                    () => _dropdownField(
                      value: controller.selectedType.value,
                      hint: 'تیپ تابلو',
                      items: AddBillboardController.billboardTypes
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => controller.selectedType.value = value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _inputField(controller.lengthController, hint: 'طول (متر)'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _inputField(
                          controller.heightController,
                          hint: 'ارتفاع (متر)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _inputField(controller.viewController, hint: 'دید'),
                  const SizedBox(height: 12),
                  Obx(
                    () => _dropdownField(
                      value: controller.selectedLighting.value,
                      hint: 'روشنایی',
                      items: AddBillboardController.lightingOptions
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => controller.selectedLighting.value = value,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _inputField(
                    controller.monthlyRentController,
                    hint: 'اجاره ماهیانه (تومان)',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _inputField(
                    controller.phoneController,
                    hint: 'شماره تماس',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'موقعیت روی نقشه',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _MapPicker(controller: controller),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          controller.longitudeController,
                          hint: 'Longitude',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _inputField(
                          controller.latitudeController,
                          hint: 'Latitude',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _inputField(controller.sellerController, hint: 'فروشنده'),
                  const SizedBox(height: 16),
                  Text(
                    'تصویر تابلو',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller.imageUrlController,
                    hint: 'لینک تصویر (اختیاری)',
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF8C93A3)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Text(
                        'انتخاب و آپلود تصویر  ⬆',
                        style: TextStyle(
                          color: Color(0xFF3F4FA8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Obx(
                    () => SizedBox(
                      height: 50,
                      child: FilledButton(
                        onPressed: controller.isSubmitting.value
                            ? null
                            : controller.submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2F3CCF),
                          disabledBackgroundColor: const Color(0xFF2F3CCF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: controller.isSubmitting.value
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'ثبت تابلو',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openProvincePicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Obx(
            () => _SelectionSheet(
              title: 'انتخاب استان',
              isLoading: controller.isLoadingProvinces.value,
              options: controller.provinces
                  .map((province) => _SelectionItem(
                        id: province.id,
                        title: province.name,
                        selected:
                            controller.selectedProvinceIds.contains(province.id),
                      ))
                  .toList(),
              onToggle: (id) => controller.toggleProvinceSelection(id),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCityPicker(BuildContext context) {
    if (controller.selectedProvinceIds.isEmpty) {
      Get.snackbar('توجه', 'ابتدا حداقل یک استان انتخاب کنید.');
      return Future.value();
    }

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Obx(
            () => _SelectionSheet(
              title: 'انتخاب شهر',
              isLoading: controller.isLoadingCities.value,
              options: controller.cityOptions
                  .map(
                    (city) => _SelectionItem(
                      id: city.name,
                      title: city.name,
                      selected: controller.selectedCityNames.contains(city.name),
                    ),
                  )
                  .toList(),
              onToggle: controller.toggleCitySelection,
            ),
          ),
        );
      },
    );
  }

  Widget _inputField(
    TextEditingController controller, {
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFE9ECEF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF8C93A3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: Color(0xFF8C93A3)),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF8C93A3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: value,
          hint: Align(
            alignment: Alignment.centerRight,
            child: Text(
              hint,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _multiSelectField({
    required String label,
    required String valueText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFE9ECEF),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF8C93A3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFF8C93A3)),
          ),
          suffixIcon: const Icon(Icons.keyboard_arrow_down),
        ),
        child: Text(
          valueText,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Color(0xFF374151)),
        ),
      ),
    );
  }
}

class _SelectionSheet extends StatelessWidget {
  const _SelectionSheet({
    required this.title,
    required this.isLoading,
    required this.options,
    required this.onToggle,
  });

  final String title;
  final bool isLoading;
  final List<_SelectionItem> options;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (options.isEmpty)
            const Expanded(
              child: Center(
                child: Text('موردی برای انتخاب وجود ندارد'),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = options[index];

                  return CheckboxListTile(
                    value: item.selected,
                    onChanged: (_) => onToggle(item.id),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      item.title,
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _SelectionItem {
  const _SelectionItem({
    required this.id,
    required this.title,
    required this.selected,
  });

  final String id;
  final String title;
  final bool selected;
}

class _MapPicker extends StatefulWidget {
  const _MapPicker({required this.controller});

  final AddBillboardController controller;

  @override
  State<_MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<_MapPicker> {
  LatLng _selected = const LatLng(32.4279, 53.6880);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        height: 300,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: _selected,
            initialZoom: 5.2,
            onTap: (tapPosition, latLng) {
              setState(() => _selected = latLng);
              widget.controller.setCoordinates(latLng.latitude, latLng.longitude);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'tablo_rebuild',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _selected,
                  width: 48,
                  height: 48,
                  child: const Icon(
                    Icons.location_pin,
                    size: 40,
                    color: Color(0xFF2544FF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
