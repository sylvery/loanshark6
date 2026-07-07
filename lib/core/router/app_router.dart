import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/customers/screens/add_customer_screen.dart';
import '../features/customers/screens/customer_detail_screen.dart';
import '../features/customers/screens/customer_list_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/loans/screens/add_loan_screen.dart';
import '../features/loans/screens/loan_detail_screen.dart';
import '../features/loans/screens/loan_list_screen.dart';
import '../features/payments/screens/payment_history_screen.dart';
import '../features/payments/screens/record_payment_screen.dart';
import '../features/reports/screens/reports_screen.dart';
import '../features/settings/screens/notification_preferences_screen.dart';
import '../features/settings/screens/lending_settings_screen.dart';
import '../features/shell/app_shell.dart';

class AuthListenable extends ChangeNotifier {
  AuthListenable() {
    _subscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      isSignedIn = user != null;
      notifyListeners();
    });
  }

  late final StreamSubscription<User?> _subscription;
  bool isSignedIn = FirebaseAuth.instance.currentUser != null;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter buildRouter(AuthListenable auth) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/settings/lending',
        builder: (context, state) => const LendingSettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/customers',
                builder: (context, state) => const CustomerListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/loans',
                builder: (context, state) => const LoanListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/customers/new',
        builder: (context, state) => const AddCustomerScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) =>
            CustomerDetailScreen(customerId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/loans/new',
        builder: (context, state) =>
            AddLoanScreen(customerId: state.uri.queryParameters['customerId']),
      ),
      GoRoute(
        path: '/loans/:id',
        builder: (context, state) =>
            LoanDetailScreen(loanId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/loans/:id/pay',
        builder: (context, state) =>
            RecordPaymentScreen(loanId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/loans/:id/history',
        builder: (context, state) =>
            PaymentHistoryScreen(loanId: state.pathParameters['id']!),
      ),
    ],
  );
}
