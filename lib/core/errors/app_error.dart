/// Application error types
/// User-friendly error messages that never expose crypto internals
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_error.freezed.dart';

@freezed
class AppError with _$AppError {
  const AppError._();

  const factory AppError.network({
    @Default('Network error occurred') String message,
  }) = NetworkError;

  const factory AppError.authentication({
    @Default('Authentication failed') String message,
  }) = AuthenticationError;

  const factory AppError.encryption({
    @Default('Encryption operation failed') String message,
  }) = EncryptionError;

  const factory AppError.decryption({
    @Default('Failed to decrypt message') String message,
  }) = DecryptionError;

  const factory AppError.invalidKey({
    @Default('Invalid encryption key') String message,
  }) = InvalidKeyError;

  const factory AppError.sessionExpired({
    @Default('Session has expired') String message,
  }) = SessionExpiredError;

  const factory AppError.sessionFull({
    @Default('Session has reached maximum participants') String message,
  }) = SessionFullError;

  const factory AppError.rateLimited({
    @Default('Too many attempts. Please try again later') String message,
  }) = RateLimitedError;

  const factory AppError.notFound({
    @Default('Resource not found') String message,
  }) = NotFoundError;

  const factory AppError.validation({required String message}) =
      ValidationError;

  const factory AppError.unknown({
    @Default('An unexpected error occurred') String message,
  }) = UnknownError;

  @override
  String get message => when(
    network: (m) => m,
    authentication: (m) => m,
    encryption: (m) => m,
    decryption: (m) => m,
    invalidKey: (m) => m,
    sessionExpired: (m) => m,
    sessionFull: (m) => m,
    rateLimited: (m) => m,
    notFound: (m) => m,
    validation: (m) => m,
    unknown: (m) => m,
  );
}
