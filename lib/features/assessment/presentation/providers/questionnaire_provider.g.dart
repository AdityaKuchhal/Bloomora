// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'questionnaire_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$questionsHash() => r'ea4ca8baa012a2c981b192fb6a2a326f4c592f3d';

/// See also [questions].
@ProviderFor(questions)
final questionsProvider =
    AutoDisposeFutureProvider<List<QuestionModel>>.internal(
  questions,
  name: r'questionsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$questionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef QuestionsRef = AutoDisposeFutureProviderRef<List<QuestionModel>>;
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
