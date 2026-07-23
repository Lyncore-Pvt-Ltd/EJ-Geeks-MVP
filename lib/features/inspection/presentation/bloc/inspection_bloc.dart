import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../data/constants/inspection_checklist_data.dart';
import '../../domain/entities/inspection_checklist_item.dart';
import '../../domain/entities/inspection_record.dart';
import '../../domain/entities/inspection_section.dart';
import '../../domain/usecases/get_inspection_by_invoice_id.dart';
import '../../domain/usecases/pick_inspection_image.dart';
import '../../domain/usecases/save_inspection.dart';
import 'inspection_event.dart';
import 'inspection_state.dart';

class InspectionBloc extends Bloc<InspectionEvent, InspectionState> {
  final String invoiceId;
  final SaveInspection _saveInspection;
  final GetInspectionByInvoiceId _getInspectionByInvoiceId;
  final PickInspectionImage _pickInspectionImage;

  // Id of the persisted `inspections` row for this invoice. Starts as a
  // freshly generated id (new inspection); if `InspectionLoadRequested`
  // finds an existing row for this invoiceId, it's overwritten with that
  // row's id so subsequent saves overwrite it instead of inserting a
  // duplicate. It's a persistence-layer detail with no UI purpose, so it
  // lives on the bloc rather than in `InspectionState`.
  String _recordId;

  InspectionBloc({
    required this.invoiceId,
    required SaveInspection saveInspection,
    required GetInspectionByInvoiceId getInspectionByInvoiceId,
    required PickInspectionImage pickInspectionImage,
  }) : _saveInspection = saveInspection,
       _getInspectionByInvoiceId = getInspectionByInvoiceId,
       _pickInspectionImage = pickInspectionImage,
       _recordId = const Uuid().v4(),
       super(InspectionState(sections: _buildInitialSections())) {
    on<RatingChanged>(_onRatingChanged);
    on<SectionCommentChanged>(_onSectionCommentChanged);
    on<ImagePicked>(_onImagePicked);
    on<ImageRemoved>(_onImageRemoved);
    on<InspectionSaved>(_onInspectionSaved);
    on<InspectionLoadRequested>(_onInspectionLoadRequested);
    add(const InspectionLoadRequested());
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

    final result = await _pickInspectionImage(
      PickInspectionImageParams(source: event.source, invoiceId: invoiceId),
    );

    result.fold(
      (failure) => emit(
        state.copyWith(isPickingImage: false, errorMessage: failure.message),
      ),
      (path) {
        if (path == null) {
          emit(state.copyWith(isPickingImage: false));
          return;
        }
        emit(
          state.copyWith(
            imagePaths: [...state.imagePaths, path],
            isPickingImage: false,
          ),
        );
      },
    );
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
      id: _recordId,
      invoiceId: invoiceId,
      vehicleDetails: event.vehicleDetails,
      sections: state.sections,
      imagePaths: state.imagePaths,
      createdAt: DateTime.now(),
    );

    final result = await _saveInspection(record);

    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(
        state.copyWith(isSaving: false, saveSuccess: true, errorMessage: null),
      ),
    );
  }

  Future<void> _onInspectionLoadRequested(
    InspectionLoadRequested event,
    Emitter<InspectionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final result = await _getInspectionByInvoiceId(invoiceId);

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, errorMessage: failure.message)),
      (record) {
        if (record == null) {
          emit(state.copyWith(isLoading: false));
          return;
        }
        _recordId = record.id;
        emit(
          state.copyWith(
            isLoading: false,
            vehicleDetails: record.vehicleDetails,
            imagePaths: record.imagePaths,
            sections: _mergeLoadedSections(state.sections, record.sections),
          ),
        );
      },
    );
  }

  static List<InspectionSection> _mergeLoadedSections(
    List<InspectionSection> canonical,
    List<InspectionSection> loaded,
  ) {
    final loadedByName = {for (final s in loaded) s.name: s};
    return canonical.map((canonicalSection) {
      final loadedSection = loadedByName[canonicalSection.name];
      if (loadedSection == null) return canonicalSection;

      final loadedItemsByLabel = {
        for (final i in loadedSection.items) i.label: i,
      };
      final mergedItems = canonicalSection.items.map((canonicalItem) {
        final loadedItem = loadedItemsByLabel[canonicalItem.label];
        if (loadedItem == null) return canonicalItem;
        return InspectionChecklistItem(
          label: canonicalItem.label,
          rating: loadedItem.rating,
        );
      }).toList();

      return InspectionSection(
        name: canonicalSection.name,
        items: mergedItems,
        comment: loadedSection.comment,
      );
    }).toList();
  }
}
