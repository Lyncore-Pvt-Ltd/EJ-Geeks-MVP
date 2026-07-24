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
import '../../features/invoice/data/datasources/invoice_local_data_source.dart';
import '../../features/invoice/data/repositories/invoice_repository_impl.dart';
import '../../features/invoice/domain/repositories/invoice_repository.dart';
import '../../features/invoice/domain/usecases/delete_invoice.dart';
import '../../features/invoice/domain/usecases/get_all_invoices.dart';
import '../../features/invoice/domain/usecases/update_invoice_service_status.dart';
import '../../features/invoice/domain/usecases/upsert_invoice_draft.dart';
import '../../features/invoice/presentation/bloc/invoice_bloc.dart';
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

  sl.registerLazySingleton<InvoiceLocalDataSource>(
    () => InvoiceLocalDataSource(appDatabase: sl()),
  );

  sl.registerLazySingleton<InvoiceRepository>(
    () => InvoiceRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<UpsertInvoiceDraft>(() => UpsertInvoiceDraft(sl()));
  sl.registerLazySingleton<GetAllInvoices>(() => GetAllInvoices(sl()));
  sl.registerLazySingleton<UpdateInvoiceServiceStatus>(
    () => UpdateInvoiceServiceStatus(sl()),
  );
  sl.registerLazySingleton<DeleteInvoice>(() => DeleteInvoice(sl()));

  sl.registerFactoryParam<InspectionBloc, String, void>(
    (invoiceId, _) => InspectionBloc(
      invoiceId: invoiceId,
      saveInspection: sl(),
      getInspectionByInvoiceId: sl(),
      pickInspectionImage: sl(),
      upsertInvoiceDraft: sl(),
    ),
  );

  sl.registerLazySingleton<InvoiceBloc>(
    () => InvoiceBloc(
      getAllInvoices: sl(),
      updateInvoiceServiceStatus: sl(),
      deleteInvoice: sl(),
    ),
  );
}
