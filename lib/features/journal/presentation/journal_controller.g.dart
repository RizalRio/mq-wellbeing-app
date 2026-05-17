// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$journalPromptsHash() => r'b99e3ae10800db2124f58cc9c1362bf9b6e46a26';

/// See also [JournalPrompts].
@ProviderFor(JournalPrompts)
final journalPromptsProvider =
    AutoDisposeAsyncNotifierProvider<
      JournalPrompts,
      List<JournalPrompt>
    >.internal(
      JournalPrompts.new,
      name: r'journalPromptsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$journalPromptsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$JournalPrompts = AutoDisposeAsyncNotifier<List<JournalPrompt>>;
String _$submitJournalControllerHash() =>
    r'3da7a2357333e70883a714430982245b52215b71';

/// See also [SubmitJournalController].
@ProviderFor(SubmitJournalController)
final submitJournalControllerProvider =
    AutoDisposeNotifierProvider<
      SubmitJournalController,
      AsyncValue<void>
    >.internal(
      SubmitJournalController.new,
      name: r'submitJournalControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$submitJournalControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SubmitJournalController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
