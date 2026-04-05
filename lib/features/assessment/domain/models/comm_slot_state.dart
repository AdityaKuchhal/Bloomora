/// A single question node in a communication fallback chain.
class CommQuestionNode {
  final String id;
  final String text;
  const CommQuestionNode({required this.id, required this.text});
}

/// State for one communication question slot (primary + optional fallback chain).
///
/// Fallback rule: if the parent scores 0 on a level AND there is a deeper level,
/// that level locks and the next level becomes active.
/// Slots with chain.length == 1 behave like regular questions (no fallback).
class CommSlotState {
  final int slotIndex;

  /// Ordered chain: index 0 = primary question, index 1 = first fallback, etc.
  final List<CommQuestionNode> chain;

  /// Score at each chain level (null = not yet answered).
  final List<int?> scores;

  CommSlotState._({
    required this.slotIndex,
    required this.chain,
    required this.scores,
  });

  factory CommSlotState.initial({
    required int slotIndex,
    required List<CommQuestionNode> chain,
  }) =>
      CommSlotState._(
        slotIndex: slotIndex,
        chain: chain,
        scores: List.filled(chain.length, null),
      );

  /// Index of the currently active (answerable) level.
  int get activeLevel {
    for (int i = 0; i < chain.length; i++) {
      final s = scores[i];
      // Null → not yet answered → this is the active level
      // > 0  → answered with 1 or 2 → no further fallback needed
      // Last level → always active regardless of score
      if (s == null || s > 0 || i == chain.length - 1) return i;
      // s == 0 and not last → locked, check next
    }
    return chain.length - 1;
  }

  /// Slot is complete when the active level has a score recorded.
  bool get isComplete => scores[activeLevel] != null;

  /// Indices of levels that are locked (scored 0, fallback triggered).
  List<int> get lockedLevelIndices {
    final out = <int>[];
    for (int i = 0; i < activeLevel; i++) {
      if (scores[i] == 0) out.add(i);
    }
    return out;
  }

  /// Average score across all answered levels in the chain.
  double get averageScore {
    final answered = scores.whereType<int>().toList();
    if (answered.isEmpty) return 0.0;
    return answered.reduce((a, b) => a + b) / answered.length;
  }

  CommSlotState withScore(int level, int score) {
    final ns = List<int?>.from(scores);
    ns[level] = score;
    // If scored > 0, collapse any deeper levels that may have been pre-set
    if (score > 0) {
      for (int i = level + 1; i < ns.length; i++) {
        ns[i] = null;
      }
    }
    return CommSlotState._(slotIndex: slotIndex, chain: chain, scores: ns);
  }
}