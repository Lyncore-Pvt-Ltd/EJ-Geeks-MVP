import 'package:get_it/get_it.dart';

import '../../features/inspection/data/datasources/inspection_image_data_source.dart';
import '../../features/inspection/data/datasources/inspection_local_data_source.dart';
import '../../features/inspection/data/repositories/inspection_image_repository_impl.dart';
import '../../features/inspection/data/repositories/inspection_repository_impl.dart';
import '../../features/inspection/domain/repositories/inspection_image_repository.dart';
import '../../features/inspection/domain/repositories/inspection_repository.dart';
import '../../features/inspection/domain/usecases/get_inspection_by_invoice_id.dart';
import '../../features/inspection/domain/usecases/pick_inspection_image.dart';
import '../../features/inspection/domain/usecases/save_inspection.dart';
import '../../features/inspection/presentation/bloc/inspection_bloc.dart';
import '../database/app_database.dart';

final GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase.instance);

  sl.registerLazySingleton<InspectionLocalDataSource>(
    () => InspectionLocalDataSource(appDatabase: sl()),
  );

  sl.registerLazySingleton<InspectionRepository>(
    () => InspectionRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<SaveInspection>(() => SaveInspection(sl()));
  sl.registerLazySingleton<GetInspectionByInvoiceId>(
    () => GetInspectionByInvoiceId(sl()),
  );

  sl.registerLazySingleton<InspectionImageDataSource>(
    () => InspectionImageDataSource(),
  );

  sl.registerLazySingleton<InspectionImageRepository>(
    () => InspectionImageRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton<PickInspectionImage>(
    () => PickInspectionImage(sl()),
  );

  sl.registerFactoryParam<InspectionBloc, String, void>(
    (invoiceId, _) => InspectionBloc(
      invoiceId: invoiceId,
      saveInspection: sl(),
      getInspectionByInvoiceId: sl(),
      pickInspectionImage: sl(),
    ),
  );
}
