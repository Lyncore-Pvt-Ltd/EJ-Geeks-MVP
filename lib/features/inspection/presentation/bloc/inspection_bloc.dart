import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/app_storage_paths.dart';
import '../../data/constants/inspection_checklist_data.dart';
import '../../domain/entities/inspection_checklist_item.dart';
import '../../domain/entities/inspection_record.dart';
import '../../domain/entities/inspection_section.dart';
import '../../domain/repositories/inspection_repository.dart';
import 'inspection_event.dart';
import 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  final String invoiceId;
  final InspectionRepository _repository;
  final ImagePicker _imagePicker;
  final String id;

  InspectionBloc({
    required this.invoiceId,
    required InspectionRepository repository,
    ImagePicker? imagePicker,
  }) : _repository = repository,
       _imagePicker = imagePicker ?? ImagePicker(),
       id = const Uuid().v4(),
       super(InspectionState(sections: _buildInitialSections())) {
    on<RatingChanged>(_onRatingChanged);
    on<SectionCommentChanged>(_onSectionCommentChanged);
    on<ImagePicked>(_onImagePicked);
    on<ImageRemoved>(_onImageRemoved);
    on<InspectionSaved>(_onInspectionSaved);
  }

  static List<InspectionSection> _buildInitialSections() {
    return kInspectionChecklistData.entries
        .map(
          (entry) => InspectionSection(
            name: entry.key,
            items: entry.value
                .map((label) => InspectionChecklistItem(label: label))
                .toList(),
          ),
        )
        .toList();
  }

  void _onRatingChanged(RatingChanged event, Emitter<InspectionState> emit) {
    final updatedSections = state.sections.map((section) {
      if (section.name != event.sectionName) return section;
      final updatedItems = section.items.map((item) {
        if (item.label != event.itemLabel) return item;
        return item.copyWith(rating: event.rating);
      }).toList();
      return section.copyWith(items: updatedItems);
    }).toList();

    emit(state.copyWith(sections: updatedSections));
  }

  void _onSectionCommentChanged(
    SectionCommentChanged event,
    Emitter<InspectionState> emit,
  ) {
    final updatedSections = state.sections.map((section) {
      if (section.name != event.sectionName) return section;
      return section.copyWith(comment: event.comment);
    }).toList();

    emit(state.copyWith(sections: updatedSections));
  }

  Future<void> _onImagePicked(
    ImagePicked event,
    Emitter<InspectionState> emit,
  ) async {
    emit(state.copyWith(isPickingImage: true, errorMessage: null));
    try {
      final picked = await _imagePicker.pickImage(
        source: event.source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 70,
      );
      if (picked == null) {
        emit(state.copyWith(isPickingImage: false));
        return;
      }

      final destinationPath = await AppStoragePaths.newImagePath(invoiceId);
      await File(picked.path).copy(destinationPath);

      emit(
        state.copyWith(
          imagePaths: [...state.imagePaths, destinationPath],
          isPickingImage: false,
        ),
      );
    } on StorageException catch (e) {
      emit(state.copyWith(isPickingImage: false, errorMessage: e.message));
    } catch (e) {
      emit(
        state.copyWith(
          isPickingImage: false,
          errorMessage: 'Failed to add photo: $e',
        ),
      );
    }
  }

  void _onImageRemoved(ImageRemoved event, Emitter<InspectionState> emit) {
    emit(
      state.copyWith(
        imagePaths: state.imagePaths.where((p) => p != event.path).toList(),
      ),
    );
  }

  Future<void> _onInspectionSaved(
    InspectionSaved event,
    Emitter<InspectionState> emit,
  ) async {
    emit(state.copyWith(isSaving: true, errorMessage: null));

    final record = InspectionRecord(
      id: id,
      invoiceId: invoiceId,
      vehicleDetails: event.vehicleDetails,
      sections: state.sections,
      imagePaths: state.imagePaths,
      createdAt: DateTime.now(),
    );

    final result = await _repository.saveInspection(record);

    result.fold(
      (failure) => emit(
        state.copyWith(isSaving: false, errorMessage: failure.message),
      ),
      (_) => emit(
        state.copyWith(isSaving: false, saveSuccess: true, errorMessage: null),
      ),
    );
  }
}
