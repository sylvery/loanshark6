import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../application/providers/core_providers.dart';

class AuthState {
  const AuthState({this.loading = false, this.error});

  final bool loading;
  final String? error;

  AuthState copyWith({bool? loading, String? error}) => AuthState(
        loading: loading ?? this.loading,
        error: error,
      );
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._ref) : super(const AuthState());

  final Ref _ref;

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AuthState();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  Future<void> register(String email, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = const AuthState();
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final google = GoogleSignIn();
      final account = await google.signIn();
      if (account == null) {
        state = state.copyWith(loading: false);
        return;
      }
      final auth = await account.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
    state = const AuthState();
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref),
);
