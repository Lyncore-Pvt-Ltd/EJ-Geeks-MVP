import 'package:auto_flow/features/auth/domain/entities/auth_session.dart';
import 'package:auto_flow/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_flow/core/di/service_locator.dart';
import 'package:auto_flow/core/error/failures.dart';
import 'package:auto_flow/features/dashboard/domain/entities/daily_revenue.dart';
import 'package:auto_flow/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:auto_flow/features/dashboard/domain/entities/monthly_revenue.dart';
import 'package:auto_flow/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:auto_flow/features/inspection/domain/entities/inspection_record.dart';
import 'package:auto_flow/features/inspection/domain/repositories/inspection_image_repository.dart';
import 'package:auto_flow/features/inspection/domain/repositories/inspection_repository.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_defaults.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_details.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_details_bundle.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_line_item.dart';
import 'package:auto_flow/features/invoice/domain/entities/invoice_summary.dart';
import 'package:auto_flow/features/invoice/domain/entities/payment_status.dart';
import 'package:auto_flow/features/invoice/domain/entities/service_status.dart';
import 'package:auto_flow/features/invoice/domain/repositories/invoice_repository.dart';
import 'package:auto_flow/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:auto_flow/features/search/domain/repositories/search_history_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Invoice list rows with long names so card text has to wrap/ellipsize.
final kFakeInvoices = <InvoiceSummary>[
  InvoiceSummary(
    id: '3f2b9c1e-0000-4000-8000-000000000001',
    serviceStatus: ServiceStatus.ongoingService,
    paymentStatus: PaymentStatus.pending,
    ownerName: 'Alexandra Montgomery-Fitzwilliam',
    make: 'Mercedes-Benz',
    model: 'Sprinter 316 CDI Long Wheelbase',
    rego: 'ABC-123',
    year: '2019',
    phoneNumber: '0412 345 678',
    createdAt: DateTime(2026, 10, 30),
    updatedAt: DateTime(2026, 10, 30),
    totalAmount: 1234567.89,
  ),
  InvoiceSummary(
    id: '3f2b9c1e-0000-4000-8000-000000000002',
    serviceStatus: ServiceStatus.completed,
    paymentStatus: PaymentStatus.paid,
    ownerName: 'Sam Lee',
    make: 'Toyota',
    model: 'Corolla',
    rego: 'XYZ-987',
    year: '2022',
    phoneNumber: '0400 000 000',
    createdAt: DateTime(2026, 10, 1),
    updatedAt: DateTime(2026, 10, 2),
    totalAmount: 420,
  ),
  InvoiceSummary(
    id: '3f2b9c1e-0000-4000-8000-000000000003',
    serviceStatus: ServiceStatus.ongoingService,
    paymentStatus: PaymentStatus.pending,
    createdAt: DateTime(2026, 9, 12),
    updatedAt: DateTime(2026, 9, 12),
  ),
];

class FakeInvoiceRepository implements InvoiceRepository {
  FakeInvoiceRepository({List<InvoiceSummary>? invoices})
    : invoices = invoices ?? kFakeInvoices;

  final List<InvoiceSummary> invoices;

  @override
  Future<Either<Failure, List<InvoiceSummary>>> getAllInvoices() async =>
      Right(invoices);

  @override
  Future<Either<Failure, InvoiceDetailsBundle>> getInvoiceDetailsByInvoiceId(
    String invoiceId,
  ) async => Right(
    InvoiceDetailsBundle(
      details: InvoiceDetails(invoiceId: invoiceId),
      items: const [],
    ),
  );

  @override
  Future<Either<Failure, InvoiceDefaults>>
  getMostRecentInvoiceDefaults() async => const Right(InvoiceDefaults());

  @override
  Future<Either<Failure, void>> upsertInvoiceDraft(String invoiceId) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateServiceStatus(
    String invoiceId,
    ServiceStatus status,
  ) async => const Right(null);

  @override
  Future<Either<Failure, void>> updatePaymentStatus(
    String invoiceId,
    PaymentStatus status,
  ) async => const Right(null);

  @override
  Future<Either<Failure, void>> deleteInvoice(
    String invoiceId, {
    bool deleteFiles = false,
  }) async => const Right(null);

  @override
  Future<Either<Failure, void>> saveInvoiceDetails(
    InvoiceDetails details,
    List<InvoiceLineItem> items,
  ) async => const Right(null);

  @override
  Future<Either<Failure, void>> updatePdfContentSignature(
    String invoiceId,
    String? signature,
  ) async => const Right(null);
}

class FakeInspectionRepository implements InspectionRepository {
  @override
  Future<Either<Failure, void>> saveInspection(InspectionRecord record) async =>
      const Right(null);

  @override
  Future<Either<Failure, InspectionRecord?>> getInspection(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, InspectionRecord?>> getInspectionByInvoiceId(
    String invoiceId,
  ) async => const Right(null);
}

class FakeInspectionImageRepository implements InspectionImageRepository {
  @override
  Future<Either<Failure, String?>> pickAndStoreImage({
    required ImageSource source,
    required String invoiceId,
    required DateTime invoiceCreatedAt,
    String? section,
  }) async => const Right(null);
}

class FakeDashboardRepository implements DashboardRepository {
  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async =>
      const Right(
        DashboardStats(
          invoiceCount: 1284,
          pendingCount: 317,
          paidCount: 967,
          invoiceTrendPercent: 12.5,
          pendingTrendPercent: -8.25,
          paidTrendPercent: 104.75,
          totalRevenue: 1234567.89,
          revenueChangePercent: 23.4,
          pendingAmount: 98765.43,
          paidAmount: 1135802.46,
        ),
      );

  @override
  Future<Either<Failure, List<DailyRevenue>>> getDailyRevenue() async {
    final now = DateTime.now();
    return Right([
      for (var d = 1; d <= 31; d++)
        DailyRevenue(
          date: DateTime(now.year, now.month, d),
          revenue: (d * 137 % 900).toDouble(),
        ),
    ]);
  }

  @override
  Future<Either<Failure, List<DateTime>>> getPendingPaymentDates() async {
    final now = DateTime.now();
    return Right([
      for (final d in [2, 5, 9, 14, 21, 28]) DateTime(now.year, now.month, d),
    ]);
  }

  @override
  Future<Either<Failure, List<MonthlyRevenue>>> getMonthlyRevenue() async =>
      const Right([
        MonthlyRevenue(month: 'May', revenue: 12000),
        MonthlyRevenue(month: 'Jun', revenue: 18500),
        MonthlyRevenue(month: 'Jul', revenue: 9800),
        MonthlyRevenue(month: 'Aug', revenue: 22100),
        MonthlyRevenue(month: 'Sep', revenue: 30500),
        MonthlyRevenue(month: 'Oct', revenue: 27400),
      ]);
}

class FakeSearchHistoryRepository implements SearchHistoryRepository {
  @override
  Future<Either<Failure, List<String>>> getRecentSearches() async =>
      const Right([]);

  @override
  Future<Either<Failure, void>> addRecentSearch(String term) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> clearRecentSearches() async =>
      const Right(null);
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.session});

  final AuthSession? session;

  @override
  Future<Either<Failure, AuthSession>> login({
    required String email,
    required String password,
    required bool remember,
  }) async => Right(session ?? kTestBranchManager);

  @override
  Future<Either<Failure, AuthSession?>> getCurrentSession() async =>
      Right(session);

  @override
  Future<Either<Failure, void>> logout() async => const Right(null);

  @override
  Stream<void> get sessionExpired => const Stream.empty();
}

const kTestBranchManager = AuthSession(
  user: AuthUser(id: 'u2', email: 'bm@test.lk', fullName: 'Branch Manager'),
  roles: [
    UserRole(
      roleId: 'r2',
      roleName: 'Branch Manager',
      branchId: 'b1',
      permissions: {'invoice:create', 'invoice:read', 'pdf:generate'},
    ),
  ],
);

const kTestSuperAdmin = AuthSession(
  user: AuthUser(id: 'u1', email: 'admin@test.lk', fullName: 'System Admin'),
  roles: [
    UserRole(
      roleId: 'r1',
      roleName: 'Super Admin',
      permissions: {'invoice:create', 'invoice:read', 'roles:read'},
    ),
  ],
);

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository({this.completed = false});

  final bool completed;

  @override
  Future<Either<Failure, void>> completeOnboarding() async => const Right(null);

  @override
  Future<Either<Failure, bool>> isOnboardingCompleted() async =>
      Right(completed);
}

/// Wires the real service locator (usecases + blocs) on top of in-memory
/// fake repositories, so widgets that call `sl<T>()` never touch SQLite,
/// the file system or platform plugins. Call from `setUp`/`setUpAll`.
Future<void> setUpTestServiceLocator({
  InvoiceRepository? invoiceRepository,
  bool onboardingCompleted = false,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});
  dotenv.loadFromString(envString: 'API_BASE_URL=http://test.local/api');
  // DashboardProvider syncs the Android home-screen widget after each load.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('home_widget'),
        (_) async => true,
      );

  await sl.reset();
  setupServiceLocator();
  sl.allowReassignment = true;
  sl.registerLazySingleton<InvoiceRepository>(
    () => invoiceRepository ?? FakeInvoiceRepository(),
  );
  sl.registerLazySingleton<InspectionRepository>(FakeInspectionRepository.new);
  sl.registerLazySingleton<InspectionImageRepository>(
    FakeInspectionImageRepository.new,
  );
  sl.registerLazySingleton<DashboardRepository>(FakeDashboardRepository.new);
  sl.registerLazySingleton<SearchHistoryRepository>(
    FakeSearchHistoryRepository.new,
  );
  sl.registerLazySingleton<OnboardingRepository>(
    () => FakeOnboardingRepository(completed: onboardingCompleted),
  );
  sl.registerLazySingleton<AuthRepository>(FakeAuthRepository.new);
  sl.allowReassignment = false;
}
