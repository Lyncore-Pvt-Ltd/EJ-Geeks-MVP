import 'package:get_it/get_it.dart';

import '../../features/inspection/data/datasources/inspection_local_data_source.dart';
import '../../features/inspection/data/repositories/inspection_repository_impl.dart';
import '../../features/inspection/domain/repositories/inspection_repository.dart';
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

  sl.registerFactoryParam<InspectionBloc, String, void>(
    (invoiceId, _) => InspectionBloc(invoiceId: invoiceId, repository: sl()),
  );
}
