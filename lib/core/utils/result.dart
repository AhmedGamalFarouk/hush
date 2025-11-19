/// Result type for error handling
/// Implements the Result pattern to avoid throwing exceptions across async boundaries
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T, E> with _$Result<T, E> {
  const Result._();

  const factory Result.success(T value) = Success<T, E>;
  const factory Result.failure(E error) = Failure<T, E>;

  bool get isSuccess => this is Success<T, E>;
  bool get isFailure => this is Failure<T, E>;

  T? get valueOrNull => when(success: (value) => value, failure: (_) => null);

  E? get errorOrNull => when(success: (_) => null, failure: (error) => error);

  T getOrElse(T Function() defaultValue) =>
      when(success: (value) => value, failure: (_) => defaultValue());

  Result<R, E> mapValue<R>(R Function(T) mapper) => when(
    success: (value) => Result.success(mapper(value)),
    failure: (error) => Result.failure(error),
  );

  Future<Result<R, E>> mapAsync<R>(Future<R> Function(T) mapper) async {
    return when(
      success: (value) async => Result.success(await mapper(value)),
      failure: (error) => Result.failure(error),
    );
  }
}
