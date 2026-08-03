// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'concierge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conciergeServiceHash() => r'ca48adb11f6d3622c33ee389cf5b34b5c6e5c06d';

/// See also [conciergeService].
@ProviderFor(conciergeService)
final conciergeServiceProvider = AutoDisposeProvider<ConciergeService>.internal(
  conciergeService,
  name: r'conciergeServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$conciergeServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ConciergeServiceRef = AutoDisposeProviderRef<ConciergeService>;
String _$createConciergeRequestHash() =>
    r'b2b85ecf9379a29bdc41b5602b3fc40aa2c77f1c';

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

/// See also [createConciergeRequest].
@ProviderFor(createConciergeRequest)
const createConciergeRequestProvider = CreateConciergeRequestFamily();

/// See also [createConciergeRequest].
class CreateConciergeRequestFamily
    extends Family<AsyncValue<ConciergeRequest>> {
  /// See also [createConciergeRequest].
  const CreateConciergeRequestFamily();

  /// See also [createConciergeRequest].
  CreateConciergeRequestProvider call({
    required String category,
    required String serviceName,
    required String description,
    bool isUrgent = false,
    Map<String, dynamic>? additionalDetails,
  }) {
    return CreateConciergeRequestProvider(
      category: category,
      serviceName: serviceName,
      description: description,
      isUrgent: isUrgent,
      additionalDetails: additionalDetails,
    );
  }

  @override
  CreateConciergeRequestProvider getProviderOverride(
    covariant CreateConciergeRequestProvider provider,
  ) {
    return call(
      category: provider.category,
      serviceName: provider.serviceName,
      description: provider.description,
      isUrgent: provider.isUrgent,
      additionalDetails: provider.additionalDetails,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'createConciergeRequestProvider';
}

/// See also [createConciergeRequest].
class CreateConciergeRequestProvider
    extends AutoDisposeFutureProvider<ConciergeRequest> {
  /// See also [createConciergeRequest].
  CreateConciergeRequestProvider({
    required String category,
    required String serviceName,
    required String description,
    bool isUrgent = false,
    Map<String, dynamic>? additionalDetails,
  }) : this._internal(
          (ref) => createConciergeRequest(
            ref as CreateConciergeRequestRef,
            category: category,
            serviceName: serviceName,
            description: description,
            isUrgent: isUrgent,
            additionalDetails: additionalDetails,
          ),
          from: createConciergeRequestProvider,
          name: r'createConciergeRequestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$createConciergeRequestHash,
          dependencies: CreateConciergeRequestFamily._dependencies,
          allTransitiveDependencies:
              CreateConciergeRequestFamily._allTransitiveDependencies,
          category: category,
          serviceName: serviceName,
          description: description,
          isUrgent: isUrgent,
          additionalDetails: additionalDetails,
        );

  CreateConciergeRequestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.category,
    required this.serviceName,
    required this.description,
    required this.isUrgent,
    required this.additionalDetails,
  }) : super.internal();

  final String category;
  final String serviceName;
  final String description;
  final bool isUrgent;
  final Map<String, dynamic>? additionalDetails;

  @override
  Override overrideWith(
    FutureOr<ConciergeRequest> Function(CreateConciergeRequestRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CreateConciergeRequestProvider._internal(
        (ref) => create(ref as CreateConciergeRequestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        category: category,
        serviceName: serviceName,
        description: description,
        isUrgent: isUrgent,
        additionalDetails: additionalDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ConciergeRequest> createElement() {
    return _CreateConciergeRequestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CreateConciergeRequestProvider &&
        other.category == category &&
        other.serviceName == serviceName &&
        other.description == description &&
        other.isUrgent == isUrgent &&
        other.additionalDetails == additionalDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);
    hash = _SystemHash.combine(hash, serviceName.hashCode);
    hash = _SystemHash.combine(hash, description.hashCode);
    hash = _SystemHash.combine(hash, isUrgent.hashCode);
    hash = _SystemHash.combine(hash, additionalDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CreateConciergeRequestRef
    on AutoDisposeFutureProviderRef<ConciergeRequest> {
  /// The parameter `category` of this provider.
  String get category;

  /// The parameter `serviceName` of this provider.
  String get serviceName;

  /// The parameter `description` of this provider.
  String get description;

  /// The parameter `isUrgent` of this provider.
  bool get isUrgent;

  /// The parameter `additionalDetails` of this provider.
  Map<String, dynamic>? get additionalDetails;
}

class _CreateConciergeRequestProviderElement
    extends AutoDisposeFutureProviderElement<ConciergeRequest>
    with CreateConciergeRequestRef {
  _CreateConciergeRequestProviderElement(super.provider);

  @override
  String get category => (origin as CreateConciergeRequestProvider).category;
  @override
  String get serviceName =>
      (origin as CreateConciergeRequestProvider).serviceName;
  @override
  String get description =>
      (origin as CreateConciergeRequestProvider).description;
  @override
  bool get isUrgent => (origin as CreateConciergeRequestProvider).isUrgent;
  @override
  Map<String, dynamic>? get additionalDetails =>
      (origin as CreateConciergeRequestProvider).additionalDetails;
}

String _$userConciergeRequestsHash() =>
    r'e0279c1835434e9478cae139655dd57564e9a946';

/// See also [userConciergeRequests].
@ProviderFor(userConciergeRequests)
final userConciergeRequestsProvider =
    AutoDisposeFutureProvider<List<ConciergeRequest>>.internal(
  userConciergeRequests,
  name: r'userConciergeRequestsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userConciergeRequestsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserConciergeRequestsRef
    = AutoDisposeFutureProviderRef<List<ConciergeRequest>>;
String _$cancelConciergeRequestHash() =>
    r'b4603f88831c6d6a9dba9c7b7fdf689d1cd5db5a';

/// See also [cancelConciergeRequest].
@ProviderFor(cancelConciergeRequest)
const cancelConciergeRequestProvider = CancelConciergeRequestFamily();

/// See also [cancelConciergeRequest].
class CancelConciergeRequestFamily extends Family<AsyncValue<void>> {
  /// See also [cancelConciergeRequest].
  const CancelConciergeRequestFamily();

  /// See also [cancelConciergeRequest].
  CancelConciergeRequestProvider call(
    String requestId,
  ) {
    return CancelConciergeRequestProvider(
      requestId,
    );
  }

  @override
  CancelConciergeRequestProvider getProviderOverride(
    covariant CancelConciergeRequestProvider provider,
  ) {
    return call(
      provider.requestId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cancelConciergeRequestProvider';
}

/// See also [cancelConciergeRequest].
class CancelConciergeRequestProvider extends AutoDisposeFutureProvider<void> {
  /// See also [cancelConciergeRequest].
  CancelConciergeRequestProvider(
    String requestId,
  ) : this._internal(
          (ref) => cancelConciergeRequest(
            ref as CancelConciergeRequestRef,
            requestId,
          ),
          from: cancelConciergeRequestProvider,
          name: r'cancelConciergeRequestProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$cancelConciergeRequestHash,
          dependencies: CancelConciergeRequestFamily._dependencies,
          allTransitiveDependencies:
              CancelConciergeRequestFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  CancelConciergeRequestProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
  }) : super.internal();

  final String requestId;

  @override
  Override overrideWith(
    FutureOr<void> Function(CancelConciergeRequestRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CancelConciergeRequestProvider._internal(
        (ref) => create(ref as CancelConciergeRequestRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _CancelConciergeRequestProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CancelConciergeRequestProvider &&
        other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CancelConciergeRequestRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _CancelConciergeRequestProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with CancelConciergeRequestRef {
  _CancelConciergeRequestProviderElement(super.provider);

  @override
  String get requestId => (origin as CancelConciergeRequestProvider).requestId;
}

String _$allConciergeRequestsHash() =>
    r'd95f71aea08f9a425afd122f255d0fa156d68916';

/// See also [allConciergeRequests].
@ProviderFor(allConciergeRequests)
const allConciergeRequestsProvider = AllConciergeRequestsFamily();

/// See also [allConciergeRequests].
class AllConciergeRequestsFamily
    extends Family<AsyncValue<List<ConciergeRequest>>> {
  /// See also [allConciergeRequests].
  const AllConciergeRequestsFamily();

  /// See also [allConciergeRequests].
  AllConciergeRequestsProvider call({
    RequestStatus? statusFilter,
    bool? urgentOnly,
    String? categoryFilter,
  }) {
    return AllConciergeRequestsProvider(
      statusFilter: statusFilter,
      urgentOnly: urgentOnly,
      categoryFilter: categoryFilter,
    );
  }

  @override
  AllConciergeRequestsProvider getProviderOverride(
    covariant AllConciergeRequestsProvider provider,
  ) {
    return call(
      statusFilter: provider.statusFilter,
      urgentOnly: provider.urgentOnly,
      categoryFilter: provider.categoryFilter,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allConciergeRequestsProvider';
}

/// See also [allConciergeRequests].
class AllConciergeRequestsProvider
    extends AutoDisposeFutureProvider<List<ConciergeRequest>> {
  /// See also [allConciergeRequests].
  AllConciergeRequestsProvider({
    RequestStatus? statusFilter,
    bool? urgentOnly,
    String? categoryFilter,
  }) : this._internal(
          (ref) => allConciergeRequests(
            ref as AllConciergeRequestsRef,
            statusFilter: statusFilter,
            urgentOnly: urgentOnly,
            categoryFilter: categoryFilter,
          ),
          from: allConciergeRequestsProvider,
          name: r'allConciergeRequestsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allConciergeRequestsHash,
          dependencies: AllConciergeRequestsFamily._dependencies,
          allTransitiveDependencies:
              AllConciergeRequestsFamily._allTransitiveDependencies,
          statusFilter: statusFilter,
          urgentOnly: urgentOnly,
          categoryFilter: categoryFilter,
        );

  AllConciergeRequestsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.statusFilter,
    required this.urgentOnly,
    required this.categoryFilter,
  }) : super.internal();

  final RequestStatus? statusFilter;
  final bool? urgentOnly;
  final String? categoryFilter;

  @override
  Override overrideWith(
    FutureOr<List<ConciergeRequest>> Function(AllConciergeRequestsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AllConciergeRequestsProvider._internal(
        (ref) => create(ref as AllConciergeRequestsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        statusFilter: statusFilter,
        urgentOnly: urgentOnly,
        categoryFilter: categoryFilter,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ConciergeRequest>> createElement() {
    return _AllConciergeRequestsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AllConciergeRequestsProvider &&
        other.statusFilter == statusFilter &&
        other.urgentOnly == urgentOnly &&
        other.categoryFilter == categoryFilter;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, statusFilter.hashCode);
    hash = _SystemHash.combine(hash, urgentOnly.hashCode);
    hash = _SystemHash.combine(hash, categoryFilter.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AllConciergeRequestsRef
    on AutoDisposeFutureProviderRef<List<ConciergeRequest>> {
  /// The parameter `statusFilter` of this provider.
  RequestStatus? get statusFilter;

  /// The parameter `urgentOnly` of this provider.
  bool? get urgentOnly;

  /// The parameter `categoryFilter` of this provider.
  String? get categoryFilter;
}

class _AllConciergeRequestsProviderElement
    extends AutoDisposeFutureProviderElement<List<ConciergeRequest>>
    with AllConciergeRequestsRef {
  _AllConciergeRequestsProviderElement(super.provider);

  @override
  RequestStatus? get statusFilter =>
      (origin as AllConciergeRequestsProvider).statusFilter;
  @override
  bool? get urgentOnly => (origin as AllConciergeRequestsProvider).urgentOnly;
  @override
  String? get categoryFilter =>
      (origin as AllConciergeRequestsProvider).categoryFilter;
}

String _$updateConciergeRequestStatusHash() =>
    r'b5364c16acf3ce87d63abcd7488cfb3485c9dfec';

/// See also [updateConciergeRequestStatus].
@ProviderFor(updateConciergeRequestStatus)
const updateConciergeRequestStatusProvider =
    UpdateConciergeRequestStatusFamily();

/// See also [updateConciergeRequestStatus].
class UpdateConciergeRequestStatusFamily extends Family<AsyncValue<void>> {
  /// See also [updateConciergeRequestStatus].
  const UpdateConciergeRequestStatusFamily();

  /// See also [updateConciergeRequestStatus].
  UpdateConciergeRequestStatusProvider call(
    String requestId,
    RequestStatus newStatus,
  ) {
    return UpdateConciergeRequestStatusProvider(
      requestId,
      newStatus,
    );
  }

  @override
  UpdateConciergeRequestStatusProvider getProviderOverride(
    covariant UpdateConciergeRequestStatusProvider provider,
  ) {
    return call(
      provider.requestId,
      provider.newStatus,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateConciergeRequestStatusProvider';
}

/// See also [updateConciergeRequestStatus].
class UpdateConciergeRequestStatusProvider
    extends AutoDisposeFutureProvider<void> {
  /// See also [updateConciergeRequestStatus].
  UpdateConciergeRequestStatusProvider(
    String requestId,
    RequestStatus newStatus,
  ) : this._internal(
          (ref) => updateConciergeRequestStatus(
            ref as UpdateConciergeRequestStatusRef,
            requestId,
            newStatus,
          ),
          from: updateConciergeRequestStatusProvider,
          name: r'updateConciergeRequestStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateConciergeRequestStatusHash,
          dependencies: UpdateConciergeRequestStatusFamily._dependencies,
          allTransitiveDependencies:
              UpdateConciergeRequestStatusFamily._allTransitiveDependencies,
          requestId: requestId,
          newStatus: newStatus,
        );

  UpdateConciergeRequestStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
    required this.newStatus,
  }) : super.internal();

  final String requestId;
  final RequestStatus newStatus;

  @override
  Override overrideWith(
    FutureOr<void> Function(UpdateConciergeRequestStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateConciergeRequestStatusProvider._internal(
        (ref) => create(ref as UpdateConciergeRequestStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
        newStatus: newStatus,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UpdateConciergeRequestStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateConciergeRequestStatusProvider &&
        other.requestId == requestId &&
        other.newStatus == newStatus;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);
    hash = _SystemHash.combine(hash, newStatus.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpdateConciergeRequestStatusRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `requestId` of this provider.
  String get requestId;

  /// The parameter `newStatus` of this provider.
  RequestStatus get newStatus;
}

class _UpdateConciergeRequestStatusProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with UpdateConciergeRequestStatusRef {
  _UpdateConciergeRequestStatusProviderElement(super.provider);

  @override
  String get requestId =>
      (origin as UpdateConciergeRequestStatusProvider).requestId;
  @override
  RequestStatus get newStatus =>
      (origin as UpdateConciergeRequestStatusProvider).newStatus;
}

String _$updateConciergeRequestDetailsHash() =>
    r'dd06cbe1d9da2f993227669329e4413e4765ad6c';

/// See also [updateConciergeRequestDetails].
@ProviderFor(updateConciergeRequestDetails)
const updateConciergeRequestDetailsProvider =
    UpdateConciergeRequestDetailsFamily();

/// See also [updateConciergeRequestDetails].
class UpdateConciergeRequestDetailsFamily extends Family<AsyncValue<void>> {
  /// See also [updateConciergeRequestDetails].
  const UpdateConciergeRequestDetailsFamily();

  /// See also [updateConciergeRequestDetails].
  UpdateConciergeRequestDetailsProvider call(
    String requestId, {
    String? description,
    bool? isUrgent,
    Map<String, dynamic>? additionalDetails,
  }) {
    return UpdateConciergeRequestDetailsProvider(
      requestId,
      description: description,
      isUrgent: isUrgent,
      additionalDetails: additionalDetails,
    );
  }

  @override
  UpdateConciergeRequestDetailsProvider getProviderOverride(
    covariant UpdateConciergeRequestDetailsProvider provider,
  ) {
    return call(
      provider.requestId,
      description: provider.description,
      isUrgent: provider.isUrgent,
      additionalDetails: provider.additionalDetails,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'updateConciergeRequestDetailsProvider';
}

/// See also [updateConciergeRequestDetails].
class UpdateConciergeRequestDetailsProvider
    extends AutoDisposeFutureProvider<void> {
  /// See also [updateConciergeRequestDetails].
  UpdateConciergeRequestDetailsProvider(
    String requestId, {
    String? description,
    bool? isUrgent,
    Map<String, dynamic>? additionalDetails,
  }) : this._internal(
          (ref) => updateConciergeRequestDetails(
            ref as UpdateConciergeRequestDetailsRef,
            requestId,
            description: description,
            isUrgent: isUrgent,
            additionalDetails: additionalDetails,
          ),
          from: updateConciergeRequestDetailsProvider,
          name: r'updateConciergeRequestDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$updateConciergeRequestDetailsHash,
          dependencies: UpdateConciergeRequestDetailsFamily._dependencies,
          allTransitiveDependencies:
              UpdateConciergeRequestDetailsFamily._allTransitiveDependencies,
          requestId: requestId,
          description: description,
          isUrgent: isUrgent,
          additionalDetails: additionalDetails,
        );

  UpdateConciergeRequestDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
    required this.description,
    required this.isUrgent,
    required this.additionalDetails,
  }) : super.internal();

  final String requestId;
  final String? description;
  final bool? isUrgent;
  final Map<String, dynamic>? additionalDetails;

  @override
  Override overrideWith(
    FutureOr<void> Function(UpdateConciergeRequestDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UpdateConciergeRequestDetailsProvider._internal(
        (ref) => create(ref as UpdateConciergeRequestDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
        description: description,
        isUrgent: isUrgent,
        additionalDetails: additionalDetails,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _UpdateConciergeRequestDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UpdateConciergeRequestDetailsProvider &&
        other.requestId == requestId &&
        other.description == description &&
        other.isUrgent == isUrgent &&
        other.additionalDetails == additionalDetails;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);
    hash = _SystemHash.combine(hash, description.hashCode);
    hash = _SystemHash.combine(hash, isUrgent.hashCode);
    hash = _SystemHash.combine(hash, additionalDetails.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin UpdateConciergeRequestDetailsRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `requestId` of this provider.
  String get requestId;

  /// The parameter `description` of this provider.
  String? get description;

  /// The parameter `isUrgent` of this provider.
  bool? get isUrgent;

  /// The parameter `additionalDetails` of this provider.
  Map<String, dynamic>? get additionalDetails;
}

class _UpdateConciergeRequestDetailsProviderElement
    extends AutoDisposeFutureProviderElement<void>
    with UpdateConciergeRequestDetailsRef {
  _UpdateConciergeRequestDetailsProviderElement(super.provider);

  @override
  String get requestId =>
      (origin as UpdateConciergeRequestDetailsProvider).requestId;
  @override
  String? get description =>
      (origin as UpdateConciergeRequestDetailsProvider).description;
  @override
  bool? get isUrgent =>
      (origin as UpdateConciergeRequestDetailsProvider).isUrgent;
  @override
  Map<String, dynamic>? get additionalDetails =>
      (origin as UpdateConciergeRequestDetailsProvider).additionalDetails;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
