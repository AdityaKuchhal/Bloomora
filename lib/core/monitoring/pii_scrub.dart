/// Shared "never send" key denylist used by both ErrorReporter (Sentry) and
/// AnalyticsService (PostHog) as a second line of defense — the first line
/// is the type system itself (closed, typed event constructors; Sentry
/// events are free-form by nature, so this denylist is the only line of
/// defense there).
///
/// Pulled from the "never send" rows in the TRD/Security & Access docs:
/// child name, DOB, assessment question/answer text, diagnosis text,
/// email, auth token/Authorization header, OpenAI/AI prompt, database
/// payload. Matching is case-insensitive and ignores underscores/hyphens,
/// so `childName`, `child_name`, and `CHILD-NAME` are all caught by one
/// entry.
const List<String> deniedPropertyKeyFragments = [
  'childname',
  'child',
  'dob',
  'dateofbirth',
  'birthdate',
  'assessmentanswer',
  'answertext',
  'questiontext',
  'diagnosis',
  'email',
  'authtoken',
  'accesstoken',
  'refreshtoken',
  'authorization',
  'token',
  'prompt',
  'databasepayload',
  'dbpayload',
  'rawpayload',
  'password',
];

String _normalizeKey(String key) =>
    key.toLowerCase().replaceAll(RegExp(r'[_\-\s]'), '');

/// Whether [key] matches (or contains) any denylisted fragment.
bool isDeniedPropertyKey(String key) {
  final normalized = _normalizeKey(key);
  return deniedPropertyKeyFragments.any(normalized.contains);
}

/// Removes every denylisted key from [properties], recursively into any
/// nested Map values. Never mutates the input — returns a new map.
Map<String, Object?> scrubDeniedKeys(Map<String, Object?> properties) {
  final result = <String, Object?>{};
  for (final entry in properties.entries) {
    if (isDeniedPropertyKey(entry.key)) continue;
    final value = entry.value;
    result[entry.key] =
        value is Map<String, Object?> ? scrubDeniedKeys(value) : value;
  }
  return result;
}
