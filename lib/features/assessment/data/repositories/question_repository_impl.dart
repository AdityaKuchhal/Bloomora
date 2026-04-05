import '../../domain/models/question_model.dart';
import '../../domain/repositories/question_repository.dart';
import '../../../../core/api/api_client.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  static const _opts = ['No', 'Sometimes', 'Yes'];

  @override
  Future<List<QuestionModel>> getQuestionsForAgeGroup(String ageGroup) async {
    try {
      final response = await ApiClient.get(
          '/questions?age_group=${Uri.encodeComponent(ageGroup)}');
      final list = response['data'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
      }
      return _localQuestions(ageGroup);
    } on ApiException catch (e) {
      if (e.isNetworkError || e.isServerError) {
        return _localQuestions(ageGroup);
      }
      rethrow;
    }
  }

  @override
  Future<QuestionModel> getQuestionById(String questionId) async {
    final response = await ApiClient.get('/questions/$questionId');
    final data = response['data'];
    if (data == null) {
      throw ApiException(
          message: 'Question not found', code: 'NOT_FOUND', statusCode: 404);
    }
    return QuestionModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<QuestionModel>> getQuestionsForDomain(
      String domain, String ageGroup) async {
    try {
      final response = await ApiClient.get(
          '/questions?domain=${Uri.encodeComponent(domain)}&age_group=${Uri.encodeComponent(ageGroup)}');
      final list = response['data'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
      }
      return _localQuestions(ageGroup)
          .where((q) => q.domain == domain)
          .toList();
    } on ApiException catch (e) {
      if (e.isNetworkError || e.isServerError) {
        return _localQuestions(ageGroup)
            .where((q) => q.domain == domain)
            .toList();
      }
      rethrow;
    }
  }

  QuestionModel _q(
          String id, String ageGroup, String domain, int num, String text) =>
      QuestionModel(
        id: id,
        ageGroup: ageGroup,
        domain: domain,
        questionNumber: num,
        questionText: text,
        options: _opts,
      );

  List<QuestionModel> _localQuestions(String ageGroup) {
    switch (ageGroup) {
      case '1-2':
        return _ageGroup12();
      case '2-3':
        return _ageGroup23();
      case '3-4':
        return _ageGroup34();
      case '4-5':
        return _ageGroup45();
      default:
        return _ageGroup12();
    }
  }

  List<QuestionModel> _ageGroup12() => [
        // Attention & Play (5)
        _q('q1', '1-2', 'Attention & Play', 1,
            'Focuses on a single toy for 30 seconds'),
        _q('q2', '1-2', 'Attention & Play', 2,
            'Explores toys by touching or mouthing'),
        _q('q3', '1-2', 'Attention & Play', 3,
            'Maintains eye contact briefly during play'),
        _q('q4', '1-2', 'Attention & Play', 4,
            'Comfortable with turn taking'),
        _q('q5', '1-2', 'Attention & Play', 5,
            'Responds to their name during play'),
        // Cognitive (5)
        _q('q6', '1-2', 'Cognitive', 1, 'Recognizes familiar people'),
        _q('q7', '1-2', 'Cognitive', 2, 'Looks for a hidden toy'),
        _q('q8', '1-2', 'Cognitive', 3,
            'Matches simple objects (pictures, shapes)'),
        _q('q9', '1-2', 'Cognitive', 4, 'Recognizes favourite toys'),
        _q('q10', '1-2', 'Cognitive', 5, 'Imitates a simple action'),
        // Communication (7)
        _q('q11', '1-2', 'Communication', 1, 'Responds to their name'),
        _q('q12', '1-2', 'Communication', 2,
            'Makes sounds like "ba", "ma"'),
        _q('q13', '1-2', 'Communication', 3,
            'Uses gestures (point, wave)'),
        _q('q14', '1-2', 'Communication', 4, 'Says 1–3 simple words'),
        _q('q15', '1-2', 'Communication', 5,
            'Understands simple words like "no" or "come"'),
        _q('q16', '1-2', 'Communication', 6,
            'Follows simple instructions like "give me"'),
        _q('q17', '1-2', 'Communication', 7,
            'Uses picture cards to communicate'),
        // Daily Living (5)
        _q('q18', '1-2', 'Daily Living', 1, 'Holds bottle or sippy cup'),
        _q('q19', '1-2', 'Daily Living', 2,
            'Helps push arm through sleeve'),
        _q('q20', '1-2', 'Daily Living', 3,
            'Tries brushing teeth or washing hands with help'),
        _q('q21', '1-2', 'Daily Living', 4, 'Sits on potty with support'),
        _q('q22', '1-2', 'Daily Living', 5,
            'Gets upset with changes to their routine'),
        // Fine Motor (5)
        _q('q23', '1-2', 'Fine Motor', 1, 'Holds toys with both hands'),
        _q('q24', '1-2', 'Fine Motor', 2, 'Stacks 2–3 blocks'),
        _q('q25', '1-2', 'Fine Motor', 3, 'Turns pages of a book'),
        _q('q26', '1-2', 'Fine Motor', 4, 'Puts objects into a container'),
        _q('q27', '1-2', 'Fine Motor', 5, 'Scribbles with a crayon'),
        // Gross Motor (5)
        _q('q28', '1-2', 'Gross Motor', 1, 'Stands without support'),
        _q('q29', '1-2', 'Gross Motor', 2, 'Walks independently'),
        _q('q30', '1-2', 'Gross Motor', 3, 'Pushes toys while walking'),
        _q('q31', '1-2', 'Gross Motor', 4, 'Throws a ball forward'),
        _q('q32', '1-2', 'Gross Motor', 5, 'Climbs onto furniture'),
        // Sensory (7)
        _q('q33', '1-2', 'Sensory', 1,
            'Comfortable with loud music'),
        _q('q34', '1-2', 'Sensory', 2,
            'Comfortable with different textures'),
        _q('q35', '1-2', 'Sensory', 3,
            'Comfortable in crowded places'),
        _q('q36', '1-2', 'Sensory', 4, 'Comfortable with bright light'),
        _q('q37', '1-2', 'Sensory', 5,
            'Comfortable playing with water'),
        _q('q38', '1-2', 'Sensory', 6,
            'Smells or touches objects repeatedly'),
        _q('q39', '1-2', 'Sensory', 7,
            'Engages in repetitive movements (hand-flapping, rocking, spinning)'),
        // Social & Emotional (5)
        _q('q40', '1-2', 'Social & Emotional', 1,
            'Smiles at familiar people'),
        _q('q41', '1-2', 'Social & Emotional', 2,
            'Enjoys playing with parent'),
        _q('q42', '1-2', 'Social & Emotional', 3,
            'Shows toys to adults'),
        _q('q43', '1-2', 'Social & Emotional', 4,
            'Expresses or understands a range of emotions'),
        _q('q44', '1-2', 'Social & Emotional', 5,
            'Likes hugs, cuddles or pressure on body'),
      ];

  List<QuestionModel> _ageGroup23() => [
        // Attention & Play (6)
        _q('q45', '2-3', 'Attention & Play', 1,
            'Responds to "show me" or "where is" during play'),
        _q('q46', '2-3', 'Attention & Play', 2,
            'Shifts attention from one toy to another without meltdown'),
        _q('q47', '2-3', 'Attention & Play', 3,
            'Repeats simple play actions (e.g., feed a doll)'),
        _q('q48', '2-3', 'Attention & Play', 4,
            'Stays focused on one task or toy for more than a few minutes'),
        _q('q49', '2-3', 'Attention & Play', 5,
            'Comfortable with turn taking'),
        _q('q50', '2-3', 'Attention & Play', 6,
            'Sits for a short structured activity (2–3 min) with an adult'),
        // Cognitive (6)
        _q('q51', '2-3', 'Cognitive', 1, 'Recognizes colors and shapes'),
        _q('q52', '2-3', 'Cognitive', 2,
            'Sorts objects by color or shape'),
        _q('q53', '2-3', 'Cognitive', 3,
            'Recognizes common or personal objects'),
        _q('q54', '2-3', 'Cognitive', 4, 'Completes a simple puzzle'),
        _q('q55', '2-3', 'Cognitive', 5, 'Identifies body parts'),
        _q('q56', '2-3', 'Cognitive', 6, 'Recognizes alphabets and numbers'),
        // Communication (7)
        _q('q57', '2-3', 'Communication', 1, 'Says 10–20 words'),
        _q('q58', '2-3', 'Communication', 2,
            'Points to objects when named'),
        _q('q59', '2-3', 'Communication', 3,
            'Asks for things using words'),
        _q('q60', '2-3', 'Communication', 4,
            'Follows 1-step instructions like "give me"'),
        _q('q61', '2-3', 'Communication', 5, 'Copies simple words'),
        _q('q62', '2-3', 'Communication', 6,
            'Names familiar objects (ball, car)'),
        _q('q63', '2-3', 'Communication', 7,
            'Answers simple questions in yes/no or by gesture'),
        // Daily Living (6)
        _q('q64', '2-3', 'Daily Living', 1, 'Drinks from an open cup'),
        _q('q65', '2-3', 'Daily Living', 2,
            'Uses a spoon with little spilling'),
        _q('q66', '2-3', 'Daily Living', 3, 'Removes simple clothing'),
        _q('q67', '2-3', 'Daily Living', 4,
            'Tries brushing teeth or washing hands with help'),
        _q('q68', '2-3', 'Daily Living', 5, 'Helps tidy up toys'),
        _q('q69', '2-3', 'Daily Living', 6,
            'Indicates need to use the toilet'),
        // Fine Motor (6)
        _q('q70', '2-3', 'Fine Motor', 1, 'Stacks 5–6 blocks'),
        _q('q71', '2-3', 'Fine Motor', 2, 'Turns knobs or lids'),
        _q('q72', '2-3', 'Fine Motor', 3, 'Draws simple lines'),
        _q('q73', '2-3', 'Fine Motor', 4,
            'Snips paper with child scissors (with adult help)'),
        _q('q74', '2-3', 'Fine Motor', 5,
            'Uses pincer grasp to pick up small objects'),
        _q('q75', '2-3', 'Fine Motor', 6,
            'Pulls off socks or loose shoes'),
        // Gross Motor (6)
        _q('q76', '2-3', 'Gross Motor', 1, 'Runs a short distance'),
        _q('q77', '2-3', 'Gross Motor', 2, 'Kicks a ball'),
        _q('q78', '2-3', 'Gross Motor', 3, 'Jumps with both feet'),
        _q('q79', '2-3', 'Gross Motor', 4,
            'Walks up stairs with support'),
        _q('q80', '2-3', 'Gross Motor', 5,
            'Balances on one foot for 1–2 seconds with support'),
        _q('q81', '2-3', 'Gross Motor', 6,
            'Throws a ball overhand with some aim'),
        // Sensory (7)
        _q('q82', '2-3', 'Sensory', 1,
            'Comfortable with loud noise (vacuum, blender)'),
        _q('q83', '2-3', 'Sensory', 2,
            'Comfortable with different textures (sand, grass)'),
        _q('q84', '2-3', 'Sensory', 3,
            'Comfortable in crowded places'),
        _q('q85', '2-3', 'Sensory', 4, 'Comfortable with bright light'),
        _q('q86', '2-3', 'Sensory', 5,
            'Comfortable playing with water'),
        _q('q87', '2-3', 'Sensory', 6,
            'Smells or touches objects repeatedly'),
        _q('q88', '2-3', 'Sensory', 7,
            'Engages in repetitive movements (hand-flapping, rocking, spinning)'),
        // Social & Emotional (6)
        _q('q89', '2-3', 'Social & Emotional', 1,
            'Plays alongside other children (parallel play)'),
        _q('q90', '2-3', 'Social & Emotional', 2,
            'Shows excitement when seeing familiar peers'),
        _q('q91', '2-3', 'Social & Emotional', 3,
            'Shows affection to family'),
        _q('q92', '2-3', 'Social & Emotional', 4,
            'Expresses or understands a range of emotions'),
        _q('q93', '2-3', 'Social & Emotional', 5,
            'Gets upset with changes to their routine'),
        _q('q94', '2-3', 'Social & Emotional', 6,
            'Likes hugs, cuddles or pressure on body'),
      ];

  List<QuestionModel> _ageGroup34() => [
        // Attention & Play (6)
        _q('q95', '3-4', 'Attention & Play', 1,
            'Plays independently for 3–5 minutes'),
        _q('q96', '3-4', 'Attention & Play', 2,
            'Follows simple game rules'),
        _q('q97', '3-4', 'Attention & Play', 3,
            'Engages in pretend play (cooking, driving, shopping)'),
        _q('q98', '3-4', 'Attention & Play', 4,
            'Completes a short tabletop activity without leaving the table'),
        _q('q99', '3-4', 'Attention & Play', 5,
            'Comfortable with turn taking'),
        _q('q100', '3-4', 'Attention & Play', 6,
            'Transitions between activities without meltdown'),
        // Cognitive (6)
        _q('q101', '3-4', 'Cognitive', 1, 'Completes a 4–6 piece puzzle'),
        _q('q102', '3-4', 'Cognitive', 2, 'Counts objects up to 10'),
        _q('q103', '3-4', 'Cognitive', 3,
            'Matches pictures to real objects'),
        _q('q104', '3-4', 'Cognitive', 4,
            'Identifies and continues a simple pattern (red-blue-red)'),
        _q('q105', '3-4', 'Cognitive', 5,
            'Names and recognizes at least 5 colours'),
        _q('q106', '3-4', 'Cognitive', 6,
            'Understands concepts of "more" and "less"'),
        // Communication (6)
        _q('q107', '3-4', 'Communication', 1,
            'Speaks in short phrases (2–3 words)'),
        _q('q108', '3-4', 'Communication', 2,
            'Answers simple questions in words'),
        _q('q109', '3-4', 'Communication', 3,
            'Follows 2-step instructions'),
        _q('q110', '3-4', 'Communication', 4,
            'Uses words to ask for help'),
        _q('q111', '3-4', 'Communication', 5,
            'Names or points to common objects and colours'),
        _q('q112', '3-4', 'Communication', 6,
            'Understands simple stories'),
        // Daily Living (6)
        _q('q113', '3-4', 'Daily Living', 1, 'Helps tidy up toys'),
        _q('q114', '3-4', 'Daily Living', 2, 'Puts arms into sleeves'),
        _q('q115', '3-4', 'Daily Living', 3, 'Tries putting on shoes'),
        _q('q116', '3-4', 'Daily Living', 4,
            'Washes hands independently'),
        _q('q117', '3-4', 'Daily Living', 5,
            'Comfortable with toilet training'),
        _q('q118', '3-4', 'Daily Living', 6,
            'Gets upset with changes to their routine'),
        // Fine Motor (6)
        _q('q119', '3-4', 'Fine Motor', 1, 'Draws circles'),
        _q('q120', '3-4', 'Fine Motor', 2, 'Builds tall block towers'),
        _q('q121', '3-4', 'Fine Motor', 3, 'Strings large beads'),
        _q('q122', '3-4', 'Fine Motor', 4,
            'Uses kid safety scissors with adult help'),
        _q('q123', '3-4', 'Fine Motor', 5,
            'Traces letters or numbers'),
        _q('q124', '3-4', 'Fine Motor', 6,
            'Opens simple containers'),
        // Gross Motor (6)
        _q('q125', '3-4', 'Gross Motor', 1, 'Jumps forward'),
        _q('q126', '3-4', 'Gross Motor', 2,
            'Stands on one foot briefly'),
        _q('q127', '3-4', 'Gross Motor', 3, 'Catches a large ball'),
        _q('q128', '3-4', 'Gross Motor', 4, 'Rides a tricycle'),
        _q('q129', '3-4', 'Gross Motor', 5,
            'Walks downstairs alternating feet'),
        _q('q130', '3-4', 'Gross Motor', 6,
            'Runs and changes direction without falling'),
        // Sensory (7)
        _q('q131', '3-4', 'Sensory', 1,
            'Comfortable with loud noise (vacuum, blender)'),
        _q('q132', '3-4', 'Sensory', 2,
            'Comfortable with different textures (sand, grass)'),
        _q('q133', '3-4', 'Sensory', 3,
            'Comfortable in crowded places'),
        _q('q134', '3-4', 'Sensory', 4, 'Comfortable with bright light'),
        _q('q135', '3-4', 'Sensory', 5,
            'Comfortable playing with water'),
        _q('q136', '3-4', 'Sensory', 6,
            'Smells or touches objects repeatedly'),
        _q('q137', '3-4', 'Sensory', 7,
            'Engages in repetitive movements (hand-flapping, rocking, spinning)'),
        // Social & Emotional (6)
        _q('q138', '3-4', 'Social & Emotional', 1,
            'Shows interest in playing with other children'),
        _q('q139', '3-4', 'Social & Emotional', 2,
            'Shares toys or materials with peers'),
        _q('q140', '3-4', 'Social & Emotional', 3,
            'Follows basic social rules (greet, say thank you)'),
        _q('q141', '3-4', 'Social & Emotional', 4,
            'Expresses or understands a range of emotions'),
        _q('q142', '3-4', 'Social & Emotional', 5,
            'Shows basic empathy (comforts a crying child or adult)'),
        _q('q143', '3-4', 'Social & Emotional', 6,
            'Engages in simple pretend play with another child'),
      ];

  List<QuestionModel> _ageGroup45() => [
        // Attention & Play (6)
        _q('q144', '4-5', 'Attention & Play', 1,
            'Focuses on an activity for 5–10 minutes'),
        _q('q145', '4-5', 'Attention & Play', 2,
            'Plays games with simple rules (snakes & ladders, matching)'),
        _q('q146', '4-5', 'Attention & Play', 3,
            'Completes simple tasks independently'),
        _q('q147', '4-5', 'Attention & Play', 4,
            'Engages in pretend play (toy cooking, driving)'),
        _q('q148', '4-5', 'Attention & Play', 5,
            'Sustains attention during a short group instruction (3–5 min)'),
        _q('q149', '4-5', 'Attention & Play', 6,
            'Waits for their turn without major disruption'),
        // Cognitive (6)
        _q('q150', '4-5', 'Cognitive', 1, 'Counts to 50'),
        _q('q151', '4-5', 'Cognitive', 2,
            'Understands concepts of "first", "next", "last"'),
        _q('q152', '4-5', 'Cognitive', 3,
            'Understands big/small, long/short, heavy/light'),
        _q('q153', '4-5', 'Cognitive', 4,
            'Completes a 6–10 piece puzzle'),
        _q('q154', '4-5', 'Cognitive', 5,
            'Understands 3-letter words (cat, mat, hat)'),
        _q('q155', '4-5', 'Cognitive', 6,
            'Categorizes objects by type (animals, food, vehicles)'),
        // Communication (6)
        _q('q156', '4-5', 'Communication', 1, 'Speaks in full sentences'),
        _q('q157', '4-5', 'Communication', 2,
            'Follows 3-step instructions'),
        _q('q158', '4-5', 'Communication', 3,
            'Expresses feelings using words (happy, sad, angry, scared)'),
        _q('q159', '4-5', 'Communication', 4,
            'Asks "why" or "how" questions to understand things'),
        _q('q160', '4-5', 'Communication', 5,
            'Understands and uses concept words (big/small, first/last)'),
        _q('q161', '4-5', 'Communication', 6,
            'Tells a short story about a recent event in sequence'),
        // Daily Living (6)
        _q('q162', '4-5', 'Daily Living', 1,
            'Dresses independently including shoes (velcro or slip-on)'),
        _q('q163', '4-5', 'Daily Living', 2,
            'Uses the toilet independently (daytime)'),
        _q('q164', '4-5', 'Daily Living', 3,
            'Brushes teeth and washes hands independently'),
        _q('q165', '4-5', 'Daily Living', 4, 'Helps tidy up toys'),
        _q('q166', '4-5', 'Daily Living', 5,
            'Eats with spoon and fork independently'),
        _q('q167', '4-5', 'Daily Living', 6,
            'Gets upset with changes to their routine'),
        // Fine Motor (6)
        _q('q168', '4-5', 'Fine Motor', 1,
            'Draws basic shapes (circle, square, triangle)'),
        _q('q169', '4-5', 'Fine Motor', 2,
            'Cuts along a straight line with kids safety scissors'),
        _q('q170', '4-5', 'Fine Motor', 3,
            'Buttons large buttons independently'),
        _q('q171', '4-5', 'Fine Motor', 4,
            'Copies a simple pattern with blocks or beads'),
        _q('q172', '4-5', 'Fine Motor', 5,
            'Builds complex block structures'),
        _q('q173', '4-5', 'Fine Motor', 6,
            'Writes some letters without tracing'),
        // Gross Motor (6)
        _q('q174', '4-5', 'Gross Motor', 1,
            'Hops on one foot at least 3 times in a row'),
        _q('q175', '4-5', 'Gross Motor', 2, 'Skips or gallops'),
        _q('q176', '4-5', 'Gross Motor', 3,
            'Catches a smaller ball with hands only (no body)'),
        _q('q177', '4-5', 'Gross Motor', 4,
            'Balances for a minimum of 5 seconds'),
        _q('q178', '4-5', 'Gross Motor', 5,
            'Participates in simple running games'),
        _q('q179', '4-5', 'Gross Motor', 6,
            'Does any sport independently'),
        // Sensory (7)
        _q('q180', '4-5', 'Sensory', 1,
            'Comfortable with loud noise (vacuum, blender)'),
        _q('q181', '4-5', 'Sensory', 2,
            'Comfortable with different textures (sand, grass)'),
        _q('q182', '4-5', 'Sensory', 3,
            'Comfortable in crowded places'),
        _q('q183', '4-5', 'Sensory', 4, 'Comfortable with bright light'),
        _q('q184', '4-5', 'Sensory', 5,
            'Comfortable playing with water'),
        _q('q185', '4-5', 'Sensory', 6,
            'Smells or touches objects repeatedly'),
        _q('q186', '4-5', 'Sensory', 7,
            'Engages in repetitive movements (hand-flapping, rocking, spinning)'),
        // Social & Emotional (6)
        _q('q187', '4-5', 'Social & Emotional', 1,
            'Plays cooperatively with children'),
        _q('q188', '4-5', 'Social & Emotional', 2,
            'Can comfort a peer who is upset'),
        _q('q189', '4-5', 'Social & Emotional', 3,
            'Participates in group activities or circle time'),
        _q('q190', '4-5', 'Social & Emotional', 4,
            'Expresses or understands a range of emotions'),
        _q('q191', '4-5', 'Social & Emotional', 5,
            'Understands simple rules of fairness (taking turns, no hitting)'),
        _q('q192', '4-5', 'Social & Emotional', 6,
            'Meets and greets with others comfortably'),
      ];
}