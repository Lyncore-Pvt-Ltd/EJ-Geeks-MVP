import 'package:ej_geek/core/theme/app_pallete.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VehicleDetailsForm extends StatelessWidget {
  const VehicleDetailsForm({
    super.key,
    required this.makeController,
    required this.modelController,
    required this.regoController,
    required this.yearController,
    required this.odometerController,
    required this.vinController,
    required this.engineNoController,
  });

  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController regoController;
  final TextEditingController yearController;
  final TextEditingController odometerController;
  final TextEditingController vinController;
  final TextEditingController engineNoController;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppPallete.dynamicBlack : AppPallete.whiteout,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppPallete.warmOnyx : AppPallete.nebulousWhite,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppPallete.cascadingWhite
                  : AppPallete.tricornBlack,
            ),
          ),
          const SizedBox(height: 12),
          _field('Make', makeController),
          const SizedBox(height: 10),
          _field('Model', modelController),
          const SizedBox(height: 10),
          _field('Rego', regoController),
          const SizedBox(height: 10),
          _field(
            'Year',
            yearController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
          _field(
            'Odometer',
            odometerController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 10),
          _field('VIN', vinController, textCapitalization: TextCapitalization.characters),
          const SizedBox(height: 10),
          _field(
            'Engine No.',
            engineNoController,
            textCapitalization: TextCapitalization.characters,
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return InspectionTextField(
      controller: controller,
      label: label,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
    );
  }
}
