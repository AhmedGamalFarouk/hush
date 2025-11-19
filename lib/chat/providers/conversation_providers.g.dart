// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$messageStreamHash() => r'05a464731b8d267b55a3891edf58bd1ae76bf1e6';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for real-time message stream
///
/// Copied from [messageStream].
@ProviderFor(messageStream)
const messageStreamProvider = MessageStreamFamily();

/// Provider for real-time message stream
///
/// Copied from [messageStream].
class MessageStreamFamily extends Family<AsyncValue<DecryptedMessage>> {
  /// Provider for real-time message stream
  ///
  /// Copied from [messageStream].
  const MessageStreamFamily();

  /// Provider for real-time message stream
  ///
  /// Copied from [messageStream].
  MessageStreamProvider call(String conversationId) {
    return MessageStreamProvider(conversationId);
  }

  @override
  MessageStreamProvider getProviderOverride(
    covariant MessageStreamProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messageStreamProvider';
}

/// Provider for real-time message stream
///
/// Copied from [messageStream].
class MessageStreamProvider
    extends AutoDisposeStreamProvider<DecryptedMessage> {
  /// Provider for real-time message stream
  ///
  /// Copied from [messageStream].
  MessageStreamProvider(String conversationId)
    : this._internal(
        (ref) => messageStream(ref as MessageStreamRef, conversationId),
        from: messageStreamProvider,
        name: r'messageStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messageStreamHash,
        dependencies: MessageStreamFamily._dependencies,
        allTransitiveDependencies:
            MessageStreamFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  MessageStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  Override overrideWith(
    Stream<DecryptedMessage> Function(MessageStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessageStreamProvider._internal(
        (ref) => create(ref as MessageStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DecryptedMessage> createElement() {
    return _MessageStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessageStreamProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessageStreamRef on AutoDisposeStreamProviderRef<DecryptedMessage> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _MessageStreamProviderElement
    extends AutoDisposeStreamProviderElement<DecryptedMessage>
    with MessageStreamRef {
  _MessageStreamProviderElement(super.provider);

  @override
  String get conversationId => (origin as MessageStreamProvider).conversationId;
}

String _$conversationListHash() => r'005037d28ddd9c7b292b2f2fb8b2dbb7b0fbcbb2';

/// Provider for list of all conversations
///
/// Copied from [ConversationList].
@ProviderFor(ConversationList)
final conversationListProvider =
    AutoDisposeAsyncNotifierProvider<
      ConversationList,
      List<Conversation>
    >.internal(
      ConversationList.new,
      name: r'conversationListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$conversationListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ConversationList = AutoDisposeAsyncNotifier<List<Conversation>>;
String _$conversationDetailsHash() =>
    r'90c8d0458001ead0fc3b6074a240cf046a38f214';

abstract class _$ConversationDetails
    extends BuildlessAutoDisposeAsyncNotifier<ConversationWithKey> {
  late final String conversationId;

  FutureOr<ConversationWithKey> build(String conversationId);
}

/// Provider for a specific conversation with its key
///
/// Copied from [ConversationDetails].
@ProviderFor(ConversationDetails)
const conversationDetailsProvider = ConversationDetailsFamily();

/// Provider for a specific conversation with its key
///
/// Copied from [ConversationDetails].
class ConversationDetailsFamily
    extends Family<AsyncValue<ConversationWithKey>> {
  /// Provider for a specific conversation with its key
  ///
  /// Copied from [ConversationDetails].
  const ConversationDetailsFamily();

  /// Provider for a specific conversation with its key
  ///
  /// Copied from [ConversationDetails].
  ConversationDetailsProvider call(String conversationId) {
    return ConversationDetailsProvider(conversationId);
  }

  @override
  ConversationDetailsProvider getProviderOverride(
    covariant ConversationDetailsProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationDetailsProvider';
}

/// Provider for a specific conversation with its key
///
/// Copied from [ConversationDetails].
class ConversationDetailsProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ConversationDetails,
          ConversationWithKey
        > {
  /// Provider for a specific conversation with its key
  ///
  /// Copied from [ConversationDetails].
  ConversationDetailsProvider(String conversationId)
    : this._internal(
        () => ConversationDetails()..conversationId = conversationId,
        from: conversationDetailsProvider,
        name: r'conversationDetailsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationDetailsHash,
        dependencies: ConversationDetailsFamily._dependencies,
        allTransitiveDependencies:
            ConversationDetailsFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<ConversationWithKey> runNotifierBuild(
    covariant ConversationDetails notifier,
  ) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(ConversationDetails Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConversationDetailsProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ConversationDetails,
    ConversationWithKey
  >
  createElement() {
    return _ConversationDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationDetailsProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationDetailsRef
    on AutoDisposeAsyncNotifierProviderRef<ConversationWithKey> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ConversationDetailsProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ConversationDetails,
          ConversationWithKey
        >
    with ConversationDetailsRef {
  _ConversationDetailsProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ConversationDetailsProvider).conversationId;
}

String _$conversationMembersHash() =>
    r'd0e3452136efee2a444a2fed6d6dd7bb875885fc';

abstract class _$ConversationMembers
    extends BuildlessAutoDisposeAsyncNotifier<List<Profile>> {
  late final String conversationId;

  FutureOr<List<Profile>> build(String conversationId);
}

/// Provider for conversation members
///
/// Copied from [ConversationMembers].
@ProviderFor(ConversationMembers)
const conversationMembersProvider = ConversationMembersFamily();

/// Provider for conversation members
///
/// Copied from [ConversationMembers].
class ConversationMembersFamily extends Family<AsyncValue<List<Profile>>> {
  /// Provider for conversation members
  ///
  /// Copied from [ConversationMembers].
  const ConversationMembersFamily();

  /// Provider for conversation members
  ///
  /// Copied from [ConversationMembers].
  ConversationMembersProvider call(String conversationId) {
    return ConversationMembersProvider(conversationId);
  }

  @override
  ConversationMembersProvider getProviderOverride(
    covariant ConversationMembersProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationMembersProvider';
}

/// Provider for conversation members
///
/// Copied from [ConversationMembers].
class ConversationMembersProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ConversationMembers,
          List<Profile>
        > {
  /// Provider for conversation members
  ///
  /// Copied from [ConversationMembers].
  ConversationMembersProvider(String conversationId)
    : this._internal(
        () => ConversationMembers()..conversationId = conversationId,
        from: conversationMembersProvider,
        name: r'conversationMembersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationMembersHash,
        dependencies: ConversationMembersFamily._dependencies,
        allTransitiveDependencies:
            ConversationMembersFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationMembersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<List<Profile>> runNotifierBuild(
    covariant ConversationMembers notifier,
  ) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(ConversationMembers Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConversationMembersProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ConversationMembers, List<Profile>>
  createElement() {
    return _ConversationMembersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMembersProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMembersRef
    on AutoDisposeAsyncNotifierProviderRef<List<Profile>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ConversationMembersProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ConversationMembers,
          List<Profile>
        >
    with ConversationMembersRef {
  _ConversationMembersProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ConversationMembersProvider).conversationId;
}

String _$conversationMessagesHash() =>
    r'9ceb59c3365c5fe3a42c4543e07731856f46a434';

abstract class _$ConversationMessages
    extends BuildlessAutoDisposeAsyncNotifier<List<DecryptedMessage>> {
  late final String conversationId;

  FutureOr<List<DecryptedMessage>> build(String conversationId);
}

/// Provider for messages in a conversation
///
/// Copied from [ConversationMessages].
@ProviderFor(ConversationMessages)
const conversationMessagesProvider = ConversationMessagesFamily();

/// Provider for messages in a conversation
///
/// Copied from [ConversationMessages].
class ConversationMessagesFamily
    extends Family<AsyncValue<List<DecryptedMessage>>> {
  /// Provider for messages in a conversation
  ///
  /// Copied from [ConversationMessages].
  const ConversationMessagesFamily();

  /// Provider for messages in a conversation
  ///
  /// Copied from [ConversationMessages].
  ConversationMessagesProvider call(String conversationId) {
    return ConversationMessagesProvider(conversationId);
  }

  @override
  ConversationMessagesProvider getProviderOverride(
    covariant ConversationMessagesProvider provider,
  ) {
    return call(provider.conversationId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'conversationMessagesProvider';
}

/// Provider for messages in a conversation
///
/// Copied from [ConversationMessages].
class ConversationMessagesProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          ConversationMessages,
          List<DecryptedMessage>
        > {
  /// Provider for messages in a conversation
  ///
  /// Copied from [ConversationMessages].
  ConversationMessagesProvider(String conversationId)
    : this._internal(
        () => ConversationMessages()..conversationId = conversationId,
        from: conversationMessagesProvider,
        name: r'conversationMessagesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conversationMessagesHash,
        dependencies: ConversationMessagesFamily._dependencies,
        allTransitiveDependencies:
            ConversationMessagesFamily._allTransitiveDependencies,
        conversationId: conversationId,
      );

  ConversationMessagesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.conversationId,
  }) : super.internal();

  final String conversationId;

  @override
  FutureOr<List<DecryptedMessage>> runNotifierBuild(
    covariant ConversationMessages notifier,
  ) {
    return notifier.build(conversationId);
  }

  @override
  Override overrideWith(ConversationMessages Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConversationMessagesProvider._internal(
        () => create()..conversationId = conversationId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        conversationId: conversationId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<
    ConversationMessages,
    List<DecryptedMessage>
  >
  createElement() {
    return _ConversationMessagesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConversationMessagesProvider &&
        other.conversationId == conversationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, conversationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ConversationMessagesRef
    on AutoDisposeAsyncNotifierProviderRef<List<DecryptedMessage>> {
  /// The parameter `conversationId` of this provider.
  String get conversationId;
}

class _ConversationMessagesProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          ConversationMessages,
          List<DecryptedMessage>
        >
    with ConversationMessagesRef {
  _ConversationMessagesProviderElement(super.provider);

  @override
  String get conversationId =>
      (origin as ConversationMessagesProvider).conversationId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
