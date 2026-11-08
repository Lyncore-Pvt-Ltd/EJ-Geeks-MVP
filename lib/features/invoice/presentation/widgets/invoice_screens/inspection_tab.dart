import 'package:auto_flow/core/presentation/widgets/af/af_secondary_button.dart';
import 'package:auto_flow/core/theme/autoflow_tokens.dart';
import 'package:auto_flow/features/inspection/domain/entities/inspection_section.dart';
import 'package:auto_flow/features/inspection/domain/entities/vehicle_details.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_bloc.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_event.dart';
import 'package:auto_flow/features/inspection/presentation/bloc/inspection_state.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/inspection_gradient_button.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/inspection_image_picker.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/inspection_section_card.dart';
import 'package:auto_flow/features/inspection/presentation/widgets/vehicle_details_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InspectionTab extends StatefulWidget {
  const InspectionTab({
    super.key,
    required this.invoiceId,
    required this.onGenerateRequested,
  });

  final String invoiceId;

  /// Shared with the Invoice tab's "Generate Invoice" button — triggers the
  /// bottom sheet's cross-tab save + both-PDF generation flow.
  final VoidCallback onGenerateRequested;

  @override
  State<InspectionTab> createState() => InspectionTabState();
}

class InspectionTabState extends State<InspectionTab>
    with AutomaticKeepAliveClientMixin<InspectionTab> {
  @override
  bool get wantKeepAlive => true;

  final _formKey = GlobalKey<FormState>();

  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _regoController = TextEditingController();
  final _yearController = TextEditingController();
  final _odometerController = TextEditingController();
  final _vinController = TextEditingController();
  final _engineNoController = TextEditingController();

  VehicleDetails _lastSavedVehicleDetails = const VehicleDetails();

  @override
  void dispose() {
    _ownerNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _regoController.dispose();
    _yearController.dispose();
    _odometerController.dispose();
    _vinController.dispose();
    _engineNoController.dispose();
    super.dispose();
  }

  bool validate() => _formKey.currentState?.validate() ?? true;

  VehicleDetails get _currentVehicleDetails => VehicleDetails(
    ownerName: _ownerNameController.text,
    address: _addressController.text,
    phoneNumber: _phoneController.text,
    make: _makeController.text,
    model: _modelController.text,
    rego: _regoController.text,
    year: _yearController.text,
    odometer: _odometerController.text,
    vin: _vinController.text,
    engineNo: _engineNoController.text,
  );

  bool get hasUnsavedChanges =>
      _currentVehicleDetails != _lastSavedVehicleDetails;

  void save() {
    final vehicleDetails = _currentVehicleDetails;
    _lastSavedVehicleDetails = vehicleDetails;
    // Progress/success shows in the sheet's floating AfSaveStatus pill.
    context.read<InspectionBloc>().add(InspectionSaved(vehicleDetails));
  }

  void _populateFrom(VehicleDetails vehicleDetails) {
    _ownerNameController.text = vehicleDetails.ownerName;
    _addressController.text = vehicleDetails.address;
    _phoneController.text = vehicleDetails.phoneNumber;
    _makeController.text = vehicleDetails.make;
    _modelController.text = vehicleDetails.model;
    _regoController.text = vehicleDetails.rego;
    _yearController.text = vehicleDetails.year;
    _odometerController.text = vehicleDetails.odometer;
    _vinController.text = vehicleDetails.vin;
    _engineNoController.text = vehicleDetails.engineNo;
    _lastSavedVehicleDetails = vehicleDetails;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final vehicleDetails = context.read<InspectionBloc>().state.vehicleDetails;
    if (vehicleDetails != null && _ownerNameController.text.isEmpty) {
      _populateFrom(vehicleDetails);
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<InspectionBloc, InspectionState>(
          // Success shows in the sheet's AfSaveStatus pill; only errors
          // still need a SnackBar.
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            }
          },
        ),
        BlocListener<InspectionBloc, InspectionState>(
          listenWhen: (previous, current) =>
              previous.vehicleDetails == null && current.vehicleDetails != null,
          listener: (context, state) => _populateFrom(state.vehicleDetails!),
        ),
      ],
      child: Builder(
        builder: (context) {
          final sectionCount = context.select<InspectionBloc, int>(
            (bloc) => bloc.state.sections.length,
          );

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AfSpace.gutter,
                  AfSpace.gutter,
                  AfSpace.gutter,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Form(
                        key: _formKey,
                        child: VehicleDetailsForm(
                          ownerNameController: _ownerNameController,
                          addressController: _addressController,
                          phoneController: _phoneController,
                          makeController: _makeController,
                          modelController: _modelController,
                          regoController: _regoController,
                          yearController: _yearController,
                          odometerController: _odometerController,
                          vinController: _vinController,
                          engineNoController: _engineNoController,
                        ),
                      ),
                      const SizedBox(height: AfSpace.s12),
                      const InspectionImagePicker(),
                      const SizedBox(height: AfSpace.m16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AfSpace.gutter),
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
                padding: const EdgeInsets.fromLTRB(
                  AfSpace.gutter,
                  0,
                  AfSpace.gutter,
                  AfSpace.gutter,
                ),
                sliver: SliverToBoxAdapter(
                  child: BlocBuilder<InspectionBloc, InspectionState>(
                    buildWhen: (previous, current) =>
                        previous.isSaving != current.isSaving ||
                        previous.isLoading != current.isLoading,
                    builder: (context, state) {
                      final isBusy = state.isSaving || state.isLoading;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          InspectionGradientButton(
                            label: 'Generate PDF',
                            onTap: isBusy ? null : widget.onGenerateRequested,
                          ),
                          const SizedBox(height: AfSpace.s12),
                          AfSecondaryButton(
                            label: 'Draft',
                            onPressed: isBusy ? null : save,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).viewInsets.bottom,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
