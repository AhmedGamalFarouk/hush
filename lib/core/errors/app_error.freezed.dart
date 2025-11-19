// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$AppError {
  String get message => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) => throw _privateConstructorUsedError;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppErrorCopyWith<AppError> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppErrorCopyWith<$Res> {
  factory $AppErrorCopyWith(AppError value, $Res Function(AppError) then) =
      _$AppErrorCopyWithImpl<$Res, AppError>;
  @useResult
  $Res call({String message});
}

/// @nodoc
class _$AppErrorCopyWithImpl<$Res, $Val extends AppError>
    implements $AppErrorCopyWith<$Res> {
  _$AppErrorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _value.copyWith(
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NetworkErrorImplCopyWith(
    _$NetworkErrorImpl value,
    $Res Function(_$NetworkErrorImpl) then,
  ) = __$$NetworkErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NetworkErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NetworkErrorImpl>
    implements _$$NetworkErrorImplCopyWith<$Res> {
  __$$NetworkErrorImplCopyWithImpl(
    _$NetworkErrorImpl _value,
    $Res Function(_$NetworkErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$NetworkErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$NetworkErrorImpl implements NetworkError {
  const _$NetworkErrorImpl({this.message = 'Network error occurred'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.network(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      __$$NetworkErrorImplCopyWithImpl<_$NetworkErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return network(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return network?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return network(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return network?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (network != null) {
      return network(this);
    }
    return orElse();
  }
}

abstract class NetworkError implements AppError {
  const factory NetworkError({final String message}) = _$NetworkErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkErrorImplCopyWith<_$NetworkErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$AuthenticationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$AuthenticationErrorImplCopyWith(
    _$AuthenticationErrorImpl value,
    $Res Function(_$AuthenticationErrorImpl) then,
  ) = __$$AuthenticationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$AuthenticationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$AuthenticationErrorImpl>
    implements _$$AuthenticationErrorImplCopyWith<$Res> {
  __$$AuthenticationErrorImplCopyWithImpl(
    _$AuthenticationErrorImpl _value,
    $Res Function(_$AuthenticationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$AuthenticationErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$AuthenticationErrorImpl implements AuthenticationError {
  const _$AuthenticationErrorImpl({this.message = 'Authentication failed'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.authentication(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthenticationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthenticationErrorImplCopyWith<_$AuthenticationErrorImpl> get copyWith =>
      __$$AuthenticationErrorImplCopyWithImpl<_$AuthenticationErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return authentication(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return authentication?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return authentication(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return authentication?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (authentication != null) {
      return authentication(this);
    }
    return orElse();
  }
}

abstract class AuthenticationError implements AppError {
  const factory AuthenticationError({final String message}) =
      _$AuthenticationErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthenticationErrorImplCopyWith<_$AuthenticationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EncryptionErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$EncryptionErrorImplCopyWith(
    _$EncryptionErrorImpl value,
    $Res Function(_$EncryptionErrorImpl) then,
  ) = __$$EncryptionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$EncryptionErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$EncryptionErrorImpl>
    implements _$$EncryptionErrorImplCopyWith<$Res> {
  __$$EncryptionErrorImplCopyWithImpl(
    _$EncryptionErrorImpl _value,
    $Res Function(_$EncryptionErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$EncryptionErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$EncryptionErrorImpl implements EncryptionError {
  const _$EncryptionErrorImpl({this.message = 'Encryption operation failed'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.encryption(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EncryptionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EncryptionErrorImplCopyWith<_$EncryptionErrorImpl> get copyWith =>
      __$$EncryptionErrorImplCopyWithImpl<_$EncryptionErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return encryption(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return encryption?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (encryption != null) {
      return encryption(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return encryption(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return encryption?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (encryption != null) {
      return encryption(this);
    }
    return orElse();
  }
}

abstract class EncryptionError implements AppError {
  const factory EncryptionError({final String message}) = _$EncryptionErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EncryptionErrorImplCopyWith<_$EncryptionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DecryptionErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$DecryptionErrorImplCopyWith(
    _$DecryptionErrorImpl value,
    $Res Function(_$DecryptionErrorImpl) then,
  ) = __$$DecryptionErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$DecryptionErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$DecryptionErrorImpl>
    implements _$$DecryptionErrorImplCopyWith<$Res> {
  __$$DecryptionErrorImplCopyWithImpl(
    _$DecryptionErrorImpl _value,
    $Res Function(_$DecryptionErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$DecryptionErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$DecryptionErrorImpl implements DecryptionError {
  const _$DecryptionErrorImpl({this.message = 'Failed to decrypt message'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.decryption(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DecryptionErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DecryptionErrorImplCopyWith<_$DecryptionErrorImpl> get copyWith =>
      __$$DecryptionErrorImplCopyWithImpl<_$DecryptionErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return decryption(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return decryption?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (decryption != null) {
      return decryption(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return decryption(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return decryption?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (decryption != null) {
      return decryption(this);
    }
    return orElse();
  }
}

abstract class DecryptionError implements AppError {
  const factory DecryptionError({final String message}) = _$DecryptionErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DecryptionErrorImplCopyWith<_$DecryptionErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$InvalidKeyErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$InvalidKeyErrorImplCopyWith(
    _$InvalidKeyErrorImpl value,
    $Res Function(_$InvalidKeyErrorImpl) then,
  ) = __$$InvalidKeyErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$InvalidKeyErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$InvalidKeyErrorImpl>
    implements _$$InvalidKeyErrorImplCopyWith<$Res> {
  __$$InvalidKeyErrorImplCopyWithImpl(
    _$InvalidKeyErrorImpl _value,
    $Res Function(_$InvalidKeyErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$InvalidKeyErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$InvalidKeyErrorImpl implements InvalidKeyError {
  const _$InvalidKeyErrorImpl({this.message = 'Invalid encryption key'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.invalidKey(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$InvalidKeyErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$InvalidKeyErrorImplCopyWith<_$InvalidKeyErrorImpl> get copyWith =>
      __$$InvalidKeyErrorImplCopyWithImpl<_$InvalidKeyErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return invalidKey(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return invalidKey?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (invalidKey != null) {
      return invalidKey(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return invalidKey(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return invalidKey?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (invalidKey != null) {
      return invalidKey(this);
    }
    return orElse();
  }
}

abstract class InvalidKeyError implements AppError {
  const factory InvalidKeyError({final String message}) = _$InvalidKeyErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$InvalidKeyErrorImplCopyWith<_$InvalidKeyErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionExpiredErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$SessionExpiredErrorImplCopyWith(
    _$SessionExpiredErrorImpl value,
    $Res Function(_$SessionExpiredErrorImpl) then,
  ) = __$$SessionExpiredErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SessionExpiredErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$SessionExpiredErrorImpl>
    implements _$$SessionExpiredErrorImplCopyWith<$Res> {
  __$$SessionExpiredErrorImplCopyWithImpl(
    _$SessionExpiredErrorImpl _value,
    $Res Function(_$SessionExpiredErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$SessionExpiredErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SessionExpiredErrorImpl implements SessionExpiredError {
  const _$SessionExpiredErrorImpl({this.message = 'Session has expired'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.sessionExpired(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionExpiredErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionExpiredErrorImplCopyWith<_$SessionExpiredErrorImpl> get copyWith =>
      __$$SessionExpiredErrorImplCopyWithImpl<_$SessionExpiredErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return sessionExpired(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return sessionExpired?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return sessionExpired(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return sessionExpired?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionExpired != null) {
      return sessionExpired(this);
    }
    return orElse();
  }
}

abstract class SessionExpiredError implements AppError {
  const factory SessionExpiredError({final String message}) =
      _$SessionExpiredErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionExpiredErrorImplCopyWith<_$SessionExpiredErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$SessionFullErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$SessionFullErrorImplCopyWith(
    _$SessionFullErrorImpl value,
    $Res Function(_$SessionFullErrorImpl) then,
  ) = __$$SessionFullErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$SessionFullErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$SessionFullErrorImpl>
    implements _$$SessionFullErrorImplCopyWith<$Res> {
  __$$SessionFullErrorImplCopyWithImpl(
    _$SessionFullErrorImpl _value,
    $Res Function(_$SessionFullErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$SessionFullErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$SessionFullErrorImpl implements SessionFullError {
  const _$SessionFullErrorImpl({
    this.message = 'Session has reached maximum participants',
  });

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.sessionFull(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SessionFullErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SessionFullErrorImplCopyWith<_$SessionFullErrorImpl> get copyWith =>
      __$$SessionFullErrorImplCopyWithImpl<_$SessionFullErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return sessionFull(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return sessionFull?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (sessionFull != null) {
      return sessionFull(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return sessionFull(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return sessionFull?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (sessionFull != null) {
      return sessionFull(this);
    }
    return orElse();
  }
}

abstract class SessionFullError implements AppError {
  const factory SessionFullError({final String message}) =
      _$SessionFullErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SessionFullErrorImplCopyWith<_$SessionFullErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RateLimitedErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$RateLimitedErrorImplCopyWith(
    _$RateLimitedErrorImpl value,
    $Res Function(_$RateLimitedErrorImpl) then,
  ) = __$$RateLimitedErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$RateLimitedErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$RateLimitedErrorImpl>
    implements _$$RateLimitedErrorImplCopyWith<$Res> {
  __$$RateLimitedErrorImplCopyWithImpl(
    _$RateLimitedErrorImpl _value,
    $Res Function(_$RateLimitedErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$RateLimitedErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$RateLimitedErrorImpl implements RateLimitedError {
  const _$RateLimitedErrorImpl({
    this.message = 'Too many attempts. Please try again later',
  });

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.rateLimited(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RateLimitedErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RateLimitedErrorImplCopyWith<_$RateLimitedErrorImpl> get copyWith =>
      __$$RateLimitedErrorImplCopyWithImpl<_$RateLimitedErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return rateLimited(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return rateLimited?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return rateLimited(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return rateLimited?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (rateLimited != null) {
      return rateLimited(this);
    }
    return orElse();
  }
}

abstract class RateLimitedError implements AppError {
  const factory RateLimitedError({final String message}) =
      _$RateLimitedErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RateLimitedErrorImplCopyWith<_$RateLimitedErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$NotFoundErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$NotFoundErrorImplCopyWith(
    _$NotFoundErrorImpl value,
    $Res Function(_$NotFoundErrorImpl) then,
  ) = __$$NotFoundErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$NotFoundErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$NotFoundErrorImpl>
    implements _$$NotFoundErrorImplCopyWith<$Res> {
  __$$NotFoundErrorImplCopyWithImpl(
    _$NotFoundErrorImpl _value,
    $Res Function(_$NotFoundErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$NotFoundErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$NotFoundErrorImpl implements NotFoundError {
  const _$NotFoundErrorImpl({this.message = 'Resource not found'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.notFound(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotFoundErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      __$$NotFoundErrorImplCopyWithImpl<_$NotFoundErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return notFound(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return notFound?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return notFound(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return notFound?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (notFound != null) {
      return notFound(this);
    }
    return orElse();
  }
}

abstract class NotFoundError implements AppError {
  const factory NotFoundError({final String message}) = _$NotFoundErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotFoundErrorImplCopyWith<_$NotFoundErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValidationErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$ValidationErrorImplCopyWith(
    _$ValidationErrorImpl value,
    $Res Function(_$ValidationErrorImpl) then,
  ) = __$$ValidationErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$ValidationErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$ValidationErrorImpl>
    implements _$$ValidationErrorImplCopyWith<$Res> {
  __$$ValidationErrorImplCopyWithImpl(
    _$ValidationErrorImpl _value,
    $Res Function(_$ValidationErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$ValidationErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$ValidationErrorImpl implements ValidationError {
  const _$ValidationErrorImpl({required this.message});

  @override
  final String message;

  @override
  String toString() {
    return 'AppError.validation(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidationErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      __$$ValidationErrorImplCopyWithImpl<_$ValidationErrorImpl>(
        this,
        _$identity,
      );

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return validation(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return validation?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return validation(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return validation?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (validation != null) {
      return validation(this);
    }
    return orElse();
  }
}

abstract class ValidationError implements AppError {
  const factory ValidationError({required final String message}) =
      _$ValidationErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidationErrorImplCopyWith<_$ValidationErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UnknownErrorImplCopyWith<$Res>
    implements $AppErrorCopyWith<$Res> {
  factory _$$UnknownErrorImplCopyWith(
    _$UnknownErrorImpl value,
    $Res Function(_$UnknownErrorImpl) then,
  ) = __$$UnknownErrorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String message});
}

/// @nodoc
class __$$UnknownErrorImplCopyWithImpl<$Res>
    extends _$AppErrorCopyWithImpl<$Res, _$UnknownErrorImpl>
    implements _$$UnknownErrorImplCopyWith<$Res> {
  __$$UnknownErrorImplCopyWithImpl(
    _$UnknownErrorImpl _value,
    $Res Function(_$UnknownErrorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? message = null}) {
    return _then(
      _$UnknownErrorImpl(
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$UnknownErrorImpl implements UnknownError {
  const _$UnknownErrorImpl({this.message = 'An unexpected error occurred'});

  @override
  @JsonKey()
  final String message;

  @override
  String toString() {
    return 'AppError.unknown(message: $message)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UnknownErrorImpl &&
            (identical(other.message, message) || other.message == message));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message);

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      __$$UnknownErrorImplCopyWithImpl<_$UnknownErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String message) network,
    required TResult Function(String message) authentication,
    required TResult Function(String message) encryption,
    required TResult Function(String message) decryption,
    required TResult Function(String message) invalidKey,
    required TResult Function(String message) sessionExpired,
    required TResult Function(String message) sessionFull,
    required TResult Function(String message) rateLimited,
    required TResult Function(String message) notFound,
    required TResult Function(String message) validation,
    required TResult Function(String message) unknown,
  }) {
    return unknown(message);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(String message)? network,
    TResult? Function(String message)? authentication,
    TResult? Function(String message)? encryption,
    TResult? Function(String message)? decryption,
    TResult? Function(String message)? invalidKey,
    TResult? Function(String message)? sessionExpired,
    TResult? Function(String message)? sessionFull,
    TResult? Function(String message)? rateLimited,
    TResult? Function(String message)? notFound,
    TResult? Function(String message)? validation,
    TResult? Function(String message)? unknown,
  }) {
    return unknown?.call(message);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String message)? network,
    TResult Function(String message)? authentication,
    TResult Function(String message)? encryption,
    TResult Function(String message)? decryption,
    TResult Function(String message)? invalidKey,
    TResult Function(String message)? sessionExpired,
    TResult Function(String message)? sessionFull,
    TResult Function(String message)? rateLimited,
    TResult Function(String message)? notFound,
    TResult Function(String message)? validation,
    TResult Function(String message)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(message);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(NetworkError value) network,
    required TResult Function(AuthenticationError value) authentication,
    required TResult Function(EncryptionError value) encryption,
    required TResult Function(DecryptionError value) decryption,
    required TResult Function(InvalidKeyError value) invalidKey,
    required TResult Function(SessionExpiredError value) sessionExpired,
    required TResult Function(SessionFullError value) sessionFull,
    required TResult Function(RateLimitedError value) rateLimited,
    required TResult Function(NotFoundError value) notFound,
    required TResult Function(ValidationError value) validation,
    required TResult Function(UnknownError value) unknown,
  }) {
    return unknown(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(NetworkError value)? network,
    TResult? Function(AuthenticationError value)? authentication,
    TResult? Function(EncryptionError value)? encryption,
    TResult? Function(DecryptionError value)? decryption,
    TResult? Function(InvalidKeyError value)? invalidKey,
    TResult? Function(SessionExpiredError value)? sessionExpired,
    TResult? Function(SessionFullError value)? sessionFull,
    TResult? Function(RateLimitedError value)? rateLimited,
    TResult? Function(NotFoundError value)? notFound,
    TResult? Function(ValidationError value)? validation,
    TResult? Function(UnknownError value)? unknown,
  }) {
    return unknown?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(NetworkError value)? network,
    TResult Function(AuthenticationError value)? authentication,
    TResult Function(EncryptionError value)? encryption,
    TResult Function(DecryptionError value)? decryption,
    TResult Function(InvalidKeyError value)? invalidKey,
    TResult Function(SessionExpiredError value)? sessionExpired,
    TResult Function(SessionFullError value)? sessionFull,
    TResult Function(RateLimitedError value)? rateLimited,
    TResult Function(NotFoundError value)? notFound,
    TResult Function(ValidationError value)? validation,
    TResult Function(UnknownError value)? unknown,
    required TResult orElse(),
  }) {
    if (unknown != null) {
      return unknown(this);
    }
    return orElse();
  }
}

abstract class UnknownError implements AppError {
  const factory UnknownError({final String message}) = _$UnknownErrorImpl;

  @override
  String get message;

  /// Create a copy of AppError
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UnknownErrorImplCopyWith<_$UnknownErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
