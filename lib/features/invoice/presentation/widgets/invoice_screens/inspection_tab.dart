import 'package:ej_geek/core/di/service_locator.dart';
import 'package:ej_geek/features/inspection/domain/entities/inspection_section.dart';
import 'package:ej_geek/features/inspection/domain/entities/vehicle_details.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_event.dart';
import 'package:ej_geek/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_image_picker.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/inspection_section_card.dart';
import 'package:ej_geek/features/inspection/presentation/widgets/vehicle_details_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InspectionTab extends StatefulWidget {
  const InspectionTab({super.key, required this.invoiceId});

  final String invoiceId;

  @override
  State<InspectionTab> createState() => _InspectionTabState();
}

class _InspectionTabState extends State<InspectionTab> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _regoController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();
  final _vinController = TextEditingController();
  final _engineNoController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _regoController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    _vinController.dispose();
    _engineNoController.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final vehicleDetails = VehicleDetails(
      make: _makeController.text,
      model: _modelController.text,
      rego: _regoController.text,
      year: _yearController.text,
      odometer: _odometerController.text,
      vin: _vinController.text,
      engineNo: _engineNoController.text,
    );
    context.read<InspectionBloc>().add(InspectionSaved(vehicleDetails));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InspectionBloc>(param1: widget.invoiceId),
      child: BlocListener<InspectionBloc, InspectionState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage ||
            previous.saveSuccess != current.saveSuccess,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          } else if (state.saveSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inspection saved')),
            );
          }
        },
        child: Builder(
          builder: (context) {
            final sectionCount = context.select<InspectionBloc, int>(
              (bloc) => bloc.state.sections.length,
            );

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        VehicleDetailsForm(
                          makeController: _makeController,
                          modelController: _modelController,
                          regoController: _regoController,
                          yearController: _yearController,
                          odometerController: _odometerController,
                          vinController: _vinController,
                          engineNoController: _engineNoController,
                        ),
                        const SizedBox(height: 12),
                        const InspectionImagePicker(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: sectionCount,
                    itemBuilder: (context, index) {
                      // Only rebuilds this one card when its own section
                      // changes (e.g. a rating tick or comment keystroke) —
                      // not the other four sections.
                      return BlocSelector<
                        InspectionBloc,
                        InspectionState,
                        InspectionSection
                      >(
                        selector: (state) => state.sections[index],
                        builder: (context, section) {
                          return InspectionSectionCard(section: section);
                        },
                      );
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverToBoxAdapter(
                    child: BlocBuilder<InspectionBloc, InspectionState>(
                      buildWhen: (previous, current) =>
                          previous.isSaving != current.isSaving,
                      builder: (context, state) {
                        return InspectionGradientButton(
                          label: 'Save Inspection',
                          isLoading: state.isSaving,
                          onTap: () => _save(context),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
