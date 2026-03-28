// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionsHash() => r'aaaeb4be6a11a71200396895775610635468d30e';

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

/// See also [questions].
@ProviderFor(questions)
const questionsProvider = QuestionsFamily();

/// See also [questions].
class QuestionsFamily extends Family<AsyncValue<List<QuestionModel>>> {
  /// See also [questions].
  const QuestionsFamily();

  /// See also [questions].
  QuestionsProvider call(
    String ageGroup,
  ) {
    return QuestionsProvider(
      ageGroup,
    );
  }

  @override
  QuestionsProvider getProviderOverride(
    covariant QuestionsProvider provider,
  ) {
    return call(
      provider.ageGroup,
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
  String? get name => r'questionsProvider';
}

/// See also [questions].
class QuestionsProvider extends AutoDisposeFutureProvider<List<QuestionModel>> {
  /// See also [questions].
  QuestionsProvider(
    String ageGroup,
  ) : this._internal(
          (ref) => questions(
            ref as QuestionsRef,
            ageGroup,
          ),
          from: questionsProvider,
          name: r'questionsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$questionsHash,
          dependencies: QuestionsFamily._dependencies,
          allTransitiveDependencies: QuestionsFamily._allTransitiveDependencies,
          ageGroup: ageGroup,
        );

  QuestionsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ageGroup,
  }) : super.internal();

  final String ageGroup;

  @override
  Override overrideWith(
    FutureOr<List<QuestionModel>> Function(QuestionsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: QuestionsProvider._internal(
        (ref) => create(ref as QuestionsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ageGroup: ageGroup,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<QuestionModel>> createElement() {
    return _QuestionsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QuestionsProvider && other.ageGroup == ageGroup;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ageGroup.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin QuestionsRef on AutoDisposeFutureProviderRef<List<QuestionModel>> {
  /// The parameter `ageGroup` of this provider.
  String get ageGroup;
}

class _QuestionsProviderElement
    extends AutoDisposeFutureProviderElement<List<QuestionModel>>
    with QuestionsRef {
  _QuestionsProviderElement(super.provider);

  @override
  String get ageGroup => (origin as QuestionsProvider).ageGroup;
}

String _$questionnaireNotifierHash() =>
    r'06a2449e228e180f676fbd9af4e8dd3943fd109e';

/// See also [QuestionnaireNotifier].
@ProviderFor(QuestionnaireNotifier)
final questionnaireNotifierProvider = AutoDisposeNotifierProvider<
    QuestionnaireNotifier, QuestionnaireState>.internal(
  QuestionnaireNotifier.new,
  name: r'questionnaireNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$questionnaireNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$QuestionnaireNotifier = AutoDisposeNotifier<QuestionnaireState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
