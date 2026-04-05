import '../domain/models/question_model.dart';
import '../domain/models/comm_slot_state.dart';

/// Static question bank sourced from Questionnaire.csv.
/// 5 questions per domain per age group (8 domains × 5 = 40 questions per age group).
/// Communication domain uses fallback chains where applicable.
class QuestionBank {
  QuestionBank._();

  /// Canonical domain order (matches tab order in UI).
  static const List<String> domainOrder = [
    'Attention & Play',
    'Cognitive',
    'Daily Living',
    'Fine Motor',
    'Gross Motor',
    'Sensory',
    'Social & Emotional',
    'Communication',
  ];

  static const List<String> _opts = ['No', 'Sometimes', 'Yes'];

  static QuestionModel _q(
    String id,
    String ag,
    String domain,
    int num,
    String text,
  ) =>
      QuestionModel(
        id: id,
        ageGroup: ag,
        domain: domain,
        questionNumber: num,
        questionText: text,
        options: _opts,
      );

  static CommQuestionNode _c(String id, String text) =>
      CommQuestionNode(id: id, text: text);

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Returns 5 representative questions for a non-communication domain.
  static List<QuestionModel> regularQuestions(String ageGroup, String domain) =>
      _regular[ageGroup]?[domain] ?? [];

  /// Returns 5 initial CommSlotState objects for the Communication domain.
  static List<CommSlotState> initialCommSlots(String ageGroup) {
    final chains = _commChains[ageGroup] ?? _commChains['1-2']!;
    return List.generate(
      chains.length,
      (i) => CommSlotState.initial(slotIndex: i, chain: chains[i]),
    );
  }

  // ─── Regular Questions ─────────────────────────────────────────────────────

  static final Map<String, Map<String, List<QuestionModel>>> _regular = {
    '1-2': _r12,
    '2-3': _r23,
    '3-4': _r34,
    '4-5': _r45,
  };

  // ── Age 1–2 ──────────────────────────────────────────────────────────────

  static final Map<String, List<QuestionModel>> _r12 = {
    'Attention & Play': [
      _q('ap12_1', '1-2', 'Attention & Play', 1,
          'Focuses on a single toy for 30 seconds'),
      _q('ap12_2', '1-2', 'Attention & Play', 2,
          'Explores toys by touching or mouthing'),
      _q('ap12_3', '1-2', 'Attention & Play', 3,
          'Maintains eye contact briefly during play'),
      _q('ap12_4', '1-2', 'Attention & Play', 4,
          'Comfortable with turn taking'),
      _q('ap12_5', '1-2', 'Attention & Play', 5,
          'Responds to their name during play'),
    ],
    'Cognitive': [
      _q('cog12_1', '1-2', 'Cognitive', 1, 'Recognizes familiar people'),
      _q('cog12_2', '1-2', 'Cognitive', 2, 'Looks for a hidden toy'),
      _q('cog12_3', '1-2', 'Cognitive', 3,
          'Matches simple objects (pictures, shapes)'),
      _q('cog12_4', '1-2', 'Cognitive', 4, 'Recognizes favourite toys'),
      _q('cog12_5', '1-2', 'Cognitive', 5, 'Imitates a simple action'),
    ],
    'Daily Living': [
      _q('dl12_1', '1-2', 'Daily Living', 1,
          'Holds a bottle or sippy cup'),
      _q('dl12_2', '1-2', 'Daily Living', 2,
          'Helps push arm through sleeve'),
      _q('dl12_3', '1-2', 'Daily Living', 3,
          'Tries brushing teeth or washing hands with help'),
      _q('dl12_4', '1-2', 'Daily Living', 4,
          'Sits on potty with support'),
      _q('dl12_5', '1-2', 'Daily Living', 5,
          'Gets upset with changes to their routine'),
    ],
    'Fine Motor': [
      _q('fm12_1', '1-2', 'Fine Motor', 1, 'Holds toys with both hands'),
      _q('fm12_2', '1-2', 'Fine Motor', 2, 'Stacks 2–3 blocks'),
      _q('fm12_3', '1-2', 'Fine Motor', 3, 'Turns pages of a book'),
      _q('fm12_4', '1-2', 'Fine Motor', 4, 'Puts objects into a container'),
      _q('fm12_5', '1-2', 'Fine Motor', 5, 'Scribbles with a crayon'),
    ],
    'Gross Motor': [
      _q('gm12_1', '1-2', 'Gross Motor', 1, 'Stands without support'),
      _q('gm12_2', '1-2', 'Gross Motor', 2, 'Walks independently'),
      _q('gm12_3', '1-2', 'Gross Motor', 3, 'Pushes toys while walking'),
      _q('gm12_4', '1-2', 'Gross Motor', 4, 'Throws a ball forward'),
      _q('gm12_5', '1-2', 'Gross Motor', 5, 'Climbs onto furniture'),
    ],
    'Sensory': [
      _q('sen12_1', '1-2', 'Sensory', 1, 'Comfortable with loud music'),
      _q('sen12_2', '1-2', 'Sensory', 2,
          'Comfortable with different textures'),
      _q('sen12_3', '1-2', 'Sensory', 3,
          'Comfortable in crowded places'),
      _q('sen12_4', '1-2', 'Sensory', 4,
          'Comfortable with bright light'),
      _q('sen12_5', '1-2', 'Sensory', 5,
          'Comfortable playing with water'),
    ],
    'Social & Emotional': [
      _q('se12_1', '1-2', 'Social & Emotional', 1,
          'Smiles at familiar people'),
      _q('se12_2', '1-2', 'Social & Emotional', 2,
          'Enjoys playing with parent'),
      _q('se12_3', '1-2', 'Social & Emotional', 3,
          'Shows toys to adults'),
      _q('se12_4', '1-2', 'Social & Emotional', 4,
          'Expresses or understands a range of emotions'),
      _q('se12_5', '1-2', 'Social & Emotional', 5,
          'Likes hugs, cuddles or pressure on body'),
    ],
  };

  // ── Age 2–3 ──────────────────────────────────────────────────────────────

  static final Map<String, List<QuestionModel>> _r23 = {
    'Attention & Play': [
      _q('ap23_1', '2-3', 'Attention & Play', 1,
          'Responds to "show me" or "where is" during play'),
      _q('ap23_2', '2-3', 'Attention & Play', 2,
          'Shifts attention from one toy to another without meltdown'),
      _q('ap23_3', '2-3', 'Attention & Play', 3,
          'Repeats simple play actions (e.g., feed a doll)'),
      _q('ap23_4', '2-3', 'Attention & Play', 4,
          'Stays focused on one task for more than a few minutes'),
      _q('ap23_5', '2-3', 'Attention & Play', 5,
          'Sits for a short structured activity (2–3 min) with an adult'),
    ],
    'Cognitive': [
      _q('cog23_1', '2-3', 'Cognitive', 1,
          'Recognizes colours and shapes'),
      _q('cog23_2', '2-3', 'Cognitive', 2,
          'Sorts objects by colour or shape'),
      _q('cog23_3', '2-3', 'Cognitive', 3, 'Completes a simple puzzle'),
      _q('cog23_4', '2-3', 'Cognitive', 4, 'Identifies body parts'),
      _q('cog23_5', '2-3', 'Cognitive', 5,
          'Recognizes common objects or personal belongings'),
    ],
    'Daily Living': [
      _q('dl23_1', '2-3', 'Daily Living', 1, 'Drinks from an open cup'),
      _q('dl23_2', '2-3', 'Daily Living', 2,
          'Uses a spoon with little spilling'),
      _q('dl23_3', '2-3', 'Daily Living', 3, 'Removes simple clothing'),
      _q('dl23_4', '2-3', 'Daily Living', 4,
          'Tries brushing teeth or washing hands with help'),
      _q('dl23_5', '2-3', 'Daily Living', 5,
          'Indicates need to use the toilet'),
    ],
    'Fine Motor': [
      _q('fm23_1', '2-3', 'Fine Motor', 1, 'Stacks 5–6 blocks'),
      _q('fm23_2', '2-3', 'Fine Motor', 2, 'Draws simple lines'),
      _q('fm23_3', '2-3', 'Fine Motor', 3,
          'Snips paper with child scissors (with adult help)'),
      _q('fm23_4', '2-3', 'Fine Motor', 4,
          'Uses pincer grasp to pick up small objects'),
      _q('fm23_5', '2-3', 'Fine Motor', 5,
          'Pulls off socks or loose shoes'),
    ],
    'Gross Motor': [
      _q('gm23_1', '2-3', 'Gross Motor', 1, 'Runs a short distance'),
      _q('gm23_2', '2-3', 'Gross Motor', 2, 'Kicks a ball'),
      _q('gm23_3', '2-3', 'Gross Motor', 3, 'Jumps with both feet'),
      _q('gm23_4', '2-3', 'Gross Motor', 4, 'Walks up stairs with support'),
      _q('gm23_5', '2-3', 'Gross Motor', 5,
          'Throws a ball overhand with some aim'),
    ],
    'Sensory': [
      _q('sen23_1', '2-3', 'Sensory', 1,
          'Comfortable with loud noise (vacuum, blender)'),
      _q('sen23_2', '2-3', 'Sensory', 2,
          'Comfortable with different textures (sand, grass)'),
      _q('sen23_3', '2-3', 'Sensory', 3,
          'Comfortable in crowded places'),
      _q('sen23_4', '2-3', 'Sensory', 4,
          'Comfortable with bright light'),
      _q('sen23_5', '2-3', 'Sensory', 5,
          'Comfortable playing with water'),
    ],
    'Social & Emotional': [
      _q('se23_1', '2-3', 'Social & Emotional', 1,
          'Plays alongside other children (parallel play)'),
      _q('se23_2', '2-3', 'Social & Emotional', 2,
          'Shows excitement when seeing familiar peers'),
      _q('se23_3', '2-3', 'Social & Emotional', 3,
          'Shows affection to family'),
      _q('se23_4', '2-3', 'Social & Emotional', 4,
          'Expresses or understands a range of emotions'),
      _q('se23_5', '2-3', 'Social & Emotional', 5,
          'Likes hugs, cuddles or pressure on body'),
    ],
  };

  // ── Age 3–4 ──────────────────────────────────────────────────────────────

  static final Map<String, List<QuestionModel>> _r34 = {
    'Attention & Play': [
      _q('ap34_1', '3-4', 'Attention & Play', 1,
          'Plays independently for 3–5 minutes'),
      _q('ap34_2', '3-4', 'Attention & Play', 2,
          'Follows simple game rules'),
      _q('ap34_3', '3-4', 'Attention & Play', 3,
          'Engages in pretend play (cooking, driving, shopping)'),
      _q('ap34_4', '3-4', 'Attention & Play', 4,
          'Transitions between activities without meltdown'),
      _q('ap34_5', '3-4', 'Attention & Play', 5,
          'Comfortable with turn taking'),
    ],
    'Cognitive': [
      _q('cog34_1', '3-4', 'Cognitive', 1,
          'Completes a 4–6 piece puzzle'),
      _q('cog34_2', '3-4', 'Cognitive', 2, 'Counts objects up to 10'),
      _q('cog34_3', '3-4', 'Cognitive', 3,
          'Names and recognizes at least 5 colours'),
      _q('cog34_4', '3-4', 'Cognitive', 4,
          'Understands concepts of "more" and "less"'),
      _q('cog34_5', '3-4', 'Cognitive', 5,
          'Matches pictures to real objects'),
    ],
    'Daily Living': [
      _q('dl34_1', '3-4', 'Daily Living', 1, 'Puts arms into sleeves'),
      _q('dl34_2', '3-4', 'Daily Living', 2, 'Tries putting on shoes'),
      _q('dl34_3', '3-4', 'Daily Living', 3,
          'Washes hands independently'),
      _q('dl34_4', '3-4', 'Daily Living', 4,
          'Comfortable with toilet training'),
      _q('dl34_5', '3-4', 'Daily Living', 5,
          'Gets upset with changes to their routine'),
    ],
    'Fine Motor': [
      _q('fm34_1', '3-4', 'Fine Motor', 1, 'Draws circles'),
      _q('fm34_2', '3-4', 'Fine Motor', 2, 'Builds tall block towers'),
      _q('fm34_3', '3-4', 'Fine Motor', 3, 'Strings large beads'),
      _q('fm34_4', '3-4', 'Fine Motor', 4,
          'Uses kid safety scissors with adult help'),
      _q('fm34_5', '3-4', 'Fine Motor', 5, 'Traces letters or numbers'),
    ],
    'Gross Motor': [
      _q('gm34_1', '3-4', 'Gross Motor', 1, 'Jumps forward'),
      _q('gm34_2', '3-4', 'Gross Motor', 2, 'Stands on one foot briefly'),
      _q('gm34_3', '3-4', 'Gross Motor', 3, 'Catches a large ball'),
      _q('gm34_4', '3-4', 'Gross Motor', 4,
          'Walks downstairs alternating feet'),
      _q('gm34_5', '3-4', 'Gross Motor', 5,
          'Runs and changes direction without falling'),
    ],
    'Sensory': [
      _q('sen34_1', '3-4', 'Sensory', 1,
          'Comfortable with loud noise (vacuum, blender)'),
      _q('sen34_2', '3-4', 'Sensory', 2,
          'Comfortable with different textures (sand, grass)'),
      _q('sen34_3', '3-4', 'Sensory', 3,
          'Comfortable in crowded places'),
      _q('sen34_4', '3-4', 'Sensory', 4,
          'Comfortable with bright light'),
      _q('sen34_5', '3-4', 'Sensory', 5,
          'Comfortable playing with water'),
    ],
    'Social & Emotional': [
      _q('se34_1', '3-4', 'Social & Emotional', 1,
          'Shows interest in playing with other children'),
      _q('se34_2', '3-4', 'Social & Emotional', 2,
          'Shares toys or materials with peers'),
      _q('se34_3', '3-4', 'Social & Emotional', 3,
          'Follows basic social rules (greet, say thank you)'),
      _q('se34_4', '3-4', 'Social & Emotional', 4,
          'Expresses or understands a range of emotions'),
      _q('se34_5', '3-4', 'Social & Emotional', 5,
          'Shows basic empathy (comforts a crying child or adult)'),
    ],
  };

  // ── Age 4–5 ──────────────────────────────────────────────────────────────

  static final Map<String, List<QuestionModel>> _r45 = {
    'Attention & Play': [
      _q('ap45_1', '4-5', 'Attention & Play', 1,
          'Focuses on an activity for 5–10 minutes'),
      _q('ap45_2', '4-5', 'Attention & Play', 2,
          'Plays games with simple rules (snakes & ladders, matching)'),
      _q('ap45_3', '4-5', 'Attention & Play', 3,
          'Completes simple tasks independently'),
      _q('ap45_4', '4-5', 'Attention & Play', 4,
          'Sustains attention during a short group instruction (3–5 min)'),
      _q('ap45_5', '4-5', 'Attention & Play', 5,
          'Waits for their turn without major disruption'),
    ],
    'Cognitive': [
      _q('cog45_1', '4-5', 'Cognitive', 1, 'Counts to 50'),
      _q('cog45_2', '4-5', 'Cognitive', 2,
          'Understands concepts of "first", "next", "last"'),
      _q('cog45_3', '4-5', 'Cognitive', 3,
          'Understands big/small, long/short, heavy/light'),
      _q('cog45_4', '4-5', 'Cognitive', 4,
          'Completes a 6–10 piece puzzle'),
      _q('cog45_5', '4-5', 'Cognitive', 5,
          'Categorizes objects by type (animals, food, vehicles)'),
    ],
    'Daily Living': [
      _q('dl45_1', '4-5', 'Daily Living', 1,
          'Dresses independently including shoes (velcro or slip-on)'),
      _q('dl45_2', '4-5', 'Daily Living', 2,
          'Uses the toilet independently (daytime)'),
      _q('dl45_3', '4-5', 'Daily Living', 3,
          'Brushes teeth and washes hands independently'),
      _q('dl45_4', '4-5', 'Daily Living', 4,
          'Eats with spoon and fork independently'),
      _q('dl45_5', '4-5', 'Daily Living', 5,
          'Gets upset with changes to their routine'),
    ],
    'Fine Motor': [
      _q('fm45_1', '4-5', 'Fine Motor', 1,
          'Draws basic shapes (circle, square, triangle)'),
      _q('fm45_2', '4-5', 'Fine Motor', 2,
          'Cuts along a straight line with kids safety scissors'),
      _q('fm45_3', '4-5', 'Fine Motor', 3,
          'Buttons large buttons independently'),
      _q('fm45_4', '4-5', 'Fine Motor', 4,
          'Copies a simple pattern with blocks or beads'),
      _q('fm45_5', '4-5', 'Fine Motor', 5,
          'Writes some letters without tracing'),
    ],
    'Gross Motor': [
      _q('gm45_1', '4-5', 'Gross Motor', 1,
          'Hops on one foot at least 3 times in a row'),
      _q('gm45_2', '4-5', 'Gross Motor', 2, 'Skips or gallops'),
      _q('gm45_3', '4-5', 'Gross Motor', 3,
          'Catches a smaller ball with hands only (no body)'),
      _q('gm45_4', '4-5', 'Gross Motor', 4,
          'Balances for a minimum of 5 seconds'),
      _q('gm45_5', '4-5', 'Gross Motor', 5,
          'Participates in simple running games'),
    ],
    'Sensory': [
      _q('sen45_1', '4-5', 'Sensory', 1,
          'Comfortable with loud noise (vacuum, blender)'),
      _q('sen45_2', '4-5', 'Sensory', 2,
          'Comfortable with different textures (sand, grass)'),
      _q('sen45_3', '4-5', 'Sensory', 3,
          'Comfortable in crowded places'),
      _q('sen45_4', '4-5', 'Sensory', 4,
          'Comfortable with bright light'),
      _q('sen45_5', '4-5', 'Sensory', 5,
          'Comfortable playing with water'),
    ],
    'Social & Emotional': [
      _q('se45_1', '4-5', 'Social & Emotional', 1,
          'Plays cooperatively with children'),
      _q('se45_2', '4-5', 'Social & Emotional', 2,
          'Can comfort a peer who is upset'),
      _q('se45_3', '4-5', 'Social & Emotional', 3,
          'Participates in group activities or circle time'),
      _q('se45_4', '4-5', 'Social & Emotional', 4,
          'Expresses or understands a range of emotions'),
      _q('se45_5', '4-5', 'Social & Emotional', 5,
          'Understands simple rules of fairness (taking turns, no hitting)'),
    ],
  };

  // ─── Communication Fallback Chains ─────────────────────────────────────────

  static final Map<String, List<List<CommQuestionNode>>> _commChains = {
    // ── 1-2: base level, no fallbacks ──────────────────────────────────────
    '1-2': [
      [_c('comm12_0', 'Responds to their name')],
      [_c('comm12_1', 'Makes sounds like "ba", "ma"')],
      [_c('comm12_2', 'Uses gestures (point, wave)')],
      [_c('comm12_3', 'Says 1–3 simple words')],
      [_c('comm12_4', 'Understands simple words like "no" or "come"')],
    ],

    // ── 2-3: some slots have 1 fallback level ──────────────────────────────
    '2-3': [
      // Slot 0: primary → fallback
      [
        _c('comm23_0_0', 'Says 10–20 words'),
        _c('comm23_0_1', 'Says 1–3 simple words'),
      ],
      // Slot 1: primary → fallback
      [
        _c('comm23_1_0', 'Asks for things using words'),
        _c('comm23_1_1', 'Uses gestures (point, wave)'),
      ],
      // Slot 2: primary → fallback
      [
        _c('comm23_2_0', 'Follows 1-step instructions like "give me"'),
        _c('comm23_2_1', 'Understands simple words like "no" or "come"'),
      ],
      // Slot 3: no fallback
      [_c('comm23_3', 'Points to objects when named')],
      // Slot 4: no fallback
      [_c('comm23_4', 'Names familiar objects (ball, car)')],
    ],

    // ── 3-4: some slots have up to 2 fallback levels ───────────────────────
    '3-4': [
      // Slot 0: 2 fallback levels
      [
        _c('comm34_0_0', 'Speaks in short phrases (2–3 words)'),
        _c('comm34_0_1', 'Says 10–20 words'),
        _c('comm34_0_2', 'Says 1–3 simple words'),
      ],
      // Slot 1: 2 fallback levels
      [
        _c('comm34_1_0', 'Answers simple questions in words'),
        _c('comm34_1_1', 'Answers yes/no or by gesture'),
        _c('comm34_1_2', 'Understands simple words like "no" or "come"'),
      ],
      // Slot 2: 1 fallback level
      [
        _c('comm34_2_0', 'Follows 2-step instructions'),
        _c('comm34_2_1', 'Follows 1-step instructions like "give me"'),
      ],
      // Slot 3: 1 fallback level
      [
        _c('comm34_3_0', 'Uses words to ask for help'),
        _c('comm34_3_1', 'Asks for things using words or gestures'),
      ],
      // Slot 4: no fallback
      [_c('comm34_4', 'Names or points to common objects and colours')],
    ],

    // ── 4-5: some slots have up to 2 fallback levels ───────────────────────
    '4-5': [
      // Slot 0: 2 fallback levels
      [
        _c('comm45_0_0', 'Speaks in full sentences'),
        _c('comm45_0_1', 'Speaks in short phrases (2–3 words)'),
        _c('comm45_0_2', 'Says 10–20 words'),
      ],
      // Slot 1: 1 fallback level
      [
        _c('comm45_1_0', 'Follows 3-step instructions'),
        _c('comm45_1_1', 'Follows 1-step instructions like "give me"'),
      ],
      // Slot 2: no fallback
      [
        _c('comm45_2',
            'Expresses feelings using words (happy, sad, angry, scared)'),
      ],
      // Slot 3: no fallback
      [_c('comm45_3', 'Asks "why" or "how" questions to understand things')],
      // Slot 4: no fallback
      [
        _c('comm45_4',
            'Tells a short story about a recent event in sequence'),
      ],
    ],
  };
}