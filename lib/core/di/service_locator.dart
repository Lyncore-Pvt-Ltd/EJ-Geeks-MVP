import 'package:get_it/get_it.dart';

import '../../features/dashboard/data/datasources/dashboard_local_data_source.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_daily_revenue.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';
import '../../features/dashboard/domain/usecases/get_monthly_revenue.dart';
import '../../features/dashboard/domain/usecases/get_pending_payment_dates.dart';
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
import '../../features/invoice/domain/usecases/generate_combined_invoice_pdf.dart';
import '../../features/invoice/domain/usecases/generate_invoice_pdfs.dart';
import '../../features/invoice/domain/usecases/get_all_invoices.dart';
import '../../features/invoice/domain/usecases/get_invoice_details_by_invoice_id.dart';
import '../../features/invoice/domain/usecases/get_most_recent_invoice_defaults.dart';
import '../../features/invoice/domain/usecases/save_invoice_details.dart';
import '../../features/invoice/domain/usecases/update_invoice_payment_status.dart';
import '../../features/invoice/domain/usecases/update_invoice_service_status.dart';
import '../../features/invoice/domain/usecases/update_pdf_content_signature.dart';
import '../../features/invoice/domain/usecases/upsert_invoice_draft.dart';
import '../../features/invoice/presentation/bloc/invoice_bloc.dart';
import '../../features/invoice/presentation/bloc/invoice_details_bloc.dart';
import '../../features/search/data/datasources/search_history_local_data_source.dart';
import '../../features/search/data/repositories/search_history_repository_impl.dart';
import '../../features/search/domain/repositories/search_history_repository.dart';
import '../../features/search/domain/usecases/add_recent_search.dart';
import '../../features/search/domain/usecases/clear_recent_searches.dart';
import '../../features/search/domain/usecases/get_recent_searches.dart';
import '../../features/search/presentation/bloc/search_bloc.dart';
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
  sl.registerLazySingleton<UpdateInvoicePaymentStatus>(
    () => UpdateInvoicePaymentStatus(sl()),
  );
  sl.registerLazySingleton<DeleteInvoice>(() => DeleteInvoice(sl()));
  sl.registerLazySingleton<SaveInvoiceDetails>(
    () => SaveInvoiceDetails(sl()),
  );
  sl.registerLazySingleton<GetInvoiceDetailsByInvoiceId>(
    () => GetInvoiceDetailsByInvoiceId(sl()),
  );
  sl.registerLazySingleton<GetMostRecentInvoiceDefaults>(
    () => GetMostRecentInvoiceDefaults(sl()),
  );
  sl.registerLazySingleton<UpdatePdfContentSignature>(
    () => UpdatePdfContentSignature(sl()),
  );
  sl.registerLazySingleton<GenerateInvoicePdfs>(
    () => GenerateInvoicePdfs(sl(), sl(), sl()),
  );
  sl.registerLazySingleton<GenerateCombinedInvoicePdf>(
    () => GenerateCombinedInvoicePdf(sl(), sl()),
  );

  sl.registerLazySingleton<DashboardLocalDataSource>(
    () => DashboardLocalDataSource(appDatabase: sl()),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<GetDashboardStats>(() => GetDashboardStats(sl()));
  sl.registerLazySingleton<GetDailyRevenue>(() => GetDailyRevenue(sl()));
  sl.registerLazySingleton<GetPendingPaymentDates>(
    () => GetPendingPaymentDates(sl()),
  );
  sl.registerLazySingleton<GetMonthlyRevenue>(() => GetMonthlyRevenue(sl()));

  sl.registerFactoryParam<InspectionBloc, String, DateTime>(
    (invoiceId, invoiceCreatedAt) => InspectionBloc(
      invoiceId: invoiceId,
      invoiceCreatedAt: invoiceCreatedAt,
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
      updateInvoicePaymentStatus: sl(),
      deleteInvoice: sl(),
    ),
  );

  sl.registerFactoryParam<InvoiceDetailsBloc, String, DateTime>(
    (invoiceId, invoiceCreatedAt) => InvoiceDetailsBloc(
      invoiceId: invoiceId,
      invoiceCreatedAt: invoiceCreatedAt,
      saveInvoiceDetails: sl(),
      getInvoiceDetailsByInvoiceId: sl(),
      getMostRecentInvoiceDefaults: sl(),
      getInspectionByInvoiceId: sl(),
      upsertInvoiceDraft: sl(),
      generateInvoicePdfs: sl(),
      updateInvoicePaymentStatus: sl(),
    ),
  );

  sl.registerLazySingleton<SearchHistoryLocalDataSource>(
    () => SearchHistoryLocalDataSource(),
  );

  sl.registerLazySingleton<SearchHistoryRepository>(
    () => SearchHistoryRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<GetRecentSearches>(() => GetRecentSearches(sl()));
  sl.registerLazySingleton<AddRecentSearch>(() => AddRecentSearch(sl()));
  sl.registerLazySingleton<ClearRecentSearches>(
    () => ClearRecentSearches(sl()),
  );

  sl.registerLazySingleton<SearchBloc>(
    () => SearchBloc(
      getRecentSearches: sl(),
      addRecentSearch: sl(),
      clearRecentSearches: sl(),
    ),
  );
}
