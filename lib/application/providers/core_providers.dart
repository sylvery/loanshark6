import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/notifications/notification_service.dart';
import '../../data/local/local_db.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/repositories/loan_repository.dart';
import '../../data/repositories/payment_repository.dart';
import '../../data/repositories/sync_queue_repository.dart';
import '../../data/remote/firestore_sync.dart';
import '../../domain/ports/customer_repository.dart';
import '../../domain/ports/loan_repository.dart';
import '../../domain/ports/payment_repository.dart';
import '../../domain/ports/sync_queue_repository.dart';
import '../../domain/services/interest_calculator.dart';
import '../../domain/services/loan_computation_service.dart';
import '../../domain/services/schedule_generator.dart';
import '../../domain/services/sync_policy.dart';

final localDbProvider = Provider<LocalDb>((ref) {
  throw UnsupportedError(
    'localDbProvider must be overridden with an opened LocalDb instance.',
  );
});

final customerRepositoryProvider = Provider<CustomerRepository>(
  (ref) => CustomerRepositoryIsar(ref.watch(localDbProvider)),
);

final loanRepositoryProvider = Provider<LoanRepository>(
  (ref) => LoanRepositoryIsar(ref.watch(localDbProvider)),
);

final paymentRepositoryProvider = Provider<PaymentRepository>(
  (ref) => PaymentRepositoryIsar(ref.watch(localDbProvider)),
);

final deviceIdProvider = Provider<String>((ref) {
  throw UnsupportedError(
    'deviceIdProvider must be overridden with a generated device id.',
  );
});

final syncQueueRepositoryProvider = Provider<SyncQueueRepository>(
  (ref) => SyncQueueRepositoryIsar(ref.watch(localDbProvider)),
);

final interestCalculatorProvider =
    Provider<InterestCalculator>((ref) => const InterestCalculator());

final scheduleGeneratorProvider = Provider<ScheduleGenerator>(
  (ref) => ScheduleGenerator(ref.watch(interestCalculatorProvider)),
);

final loanComputationProvider = Provider<LoanComputationService>(
  (ref) => LoanComputationService(ref.watch(scheduleGeneratorProvider)),
);

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(FlutterLocalNotificationsPlugin()),
);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

final firestoreSyncProvider = Provider<FirestoreSyncService>(
  (ref) => FirestoreSyncService(
    ref.watch(firestoreProvider),
    ref.watch(customerRepositoryProvider),
    ref.watch(loanRepositoryProvider),
    ref.watch(paymentRepositoryProvider),
    ref.watch(syncQueueRepositoryProvider),
    const SyncPolicy(),
  ),
);

final authUserProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.authStateChanges(),
);

final ownerIdProvider = Provider<String?>(
  (ref) => ref.watch(authUserProvider).value?.uid,
);

final connectivityProvider = StreamProvider<bool>((ref) {
  final controller = Connectivity();
  return controller.onConnectivityChanged
      .map((list) => !list.contains(ConnectivityResult.none));
});
