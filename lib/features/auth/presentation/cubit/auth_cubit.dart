import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_state_changes_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/resend_verification_email_usecase.dart';
import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/verify_email_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInUseCase _signInUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final AuthStateChangesUseCase _authStateChangesUseCase;
  final VerifyEmailUseCase _verifyEmailUseCase;
  final ResendVerificationEmailUseCase _resendVerificationEmailUseCase;
  late final StreamSubscription<UserEntity?> _authSubscription;

  String? pendingVerificationEmail;

  AuthCubit({
    required SignInUseCase signInUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required AuthStateChangesUseCase authStateChangesUseCase,
    required VerifyEmailUseCase verifyEmailUseCase,
    required ResendVerificationEmailUseCase resendVerificationEmailUseCase,
  })  : _signInUseCase = signInUseCase,
        _signInWithGoogleUseCase = signInWithGoogleUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _authStateChangesUseCase = authStateChangesUseCase,
        _verifyEmailUseCase = verifyEmailUseCase,
        _resendVerificationEmailUseCase = resendVerificationEmailUseCase,
        super(AuthInitial()) {
    _init();
  }

  void _init() {
    _authSubscription = _authStateChangesUseCase.call().listen((user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });
  }

  Future<void> checkSession() async {
    emit(AuthLoading());
    final result = await _getCurrentUserUseCase.call();
    result.fold(
      (failure) => emit(Unauthenticated()),
      (user) {
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      },
    );
  }

  Future<void> signIn(String email, String password) async {
    emit(AuthLoading());
    final result = await _signInUseCase.call(email, password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signUp(String email, String password, String name) async {
    emit(AuthLoading());
    final result = await _signUpUseCase.call(email, password, name);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        if (user.isVerified) {
          emit(Authenticated(user));
        } else {
          pendingVerificationEmail = user.email;
          emit(EmailVerificationPending(user.email));
        }
      },
    );
  }

  Future<void> verifyEmail(String email, String token) async {
    emit(AuthLoading());
    final result = await _verifyEmailUseCase.call(email, token);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> resendVerificationEmail(String email) async {
    await _resendVerificationEmailUseCase.call(email);
  }

  Future<void> signInWithGoogle() async {
    emit(AuthLoading());
    final result = await _signInWithGoogleUseCase.call();
    result.fold(
      (failure) {
        if (failure is GoogleSignInCancelledFailure) {
          emit(Unauthenticated());
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(AuthLoading());
    final result = await _signOutUseCase.call();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
