import '../../domain/models/question_model.dart';
import '../../domain/repositories/question_repository.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_constants.dart';

class QuestionRepositoryImpl implements QuestionRepository {
  @override
  Future<List<QuestionModel>> getQuestionsForAgeGroup(String ageGroup) async {
    try {
      final response =
          await ApiClient.get('/questions?age_group=${Uri.encodeComponent(ageGroup)}');

      final list = response['data'] as List<dynamic>? ?? [];
      if (list.isNotEmpty) {
        return list
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
      }
      // API returned empty — fall back to local seed questions
      return _localQuestions(ageGroup);
    } on ApiException catch (e) {
      if (e.isNetworkError || e.isServerError) {
        // Offline or server down — use local seed
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

  // Local seed questions — used when offline or backend returns nothing.
  // These are age-group aware research-backed questions.
  List<QuestionModel> _localQuestions(String ageGroup) {
    final questions = <QuestionModel>[];
    int id = 1;

    for (final domain in AppConstants.domains) {
      final texts = _questionTexts[domain]?[ageGroup] ??
          _questionTexts[domain]?['1-2'] ??
          [];
      for (int i = 0; i < texts.length; i++) {
        questions.add(QuestionModel(
          id: '${ageGroup}_${domain}_$id',
          domain: domain,
          ageGroup: ageGroup,
          questionNumber: i + 1,
          questionText: texts[i],
          options: const ['Always', 'Often', 'Sometimes', 'Rarely', 'Never'],
          additionalInfo: i == 0
              ? AppConstants.domainDescriptions[domain]
              : null,
          isRequired: true,
          weight: 1,
        ));
        id++;
      }
    }
    return questions;
  }

  static const _questionTexts = <String, Map<String, List<String>>>{
    'Fine Motor Skills': {
      '1-2': [
        'Can your child pick up small objects like a Cheerio using their thumb and forefinger?',
        'Does your child try to use a spoon or fork when eating?',
        'Can your child stack 2–3 blocks without them falling?',
        'Does your child show interest in scribbling or drawing?',
        'Can your child turn pages of a board book one at a time?',
      ],
      '2-3': [
        'Can your child string large beads onto a lace?',
        'Does your child use a spoon or fork with reasonable success?',
        'Can your child build a tower of 6 or more blocks?',
        'Does your child try to copy a vertical line you draw?',
        'Can your child unscrew simple jar lids or turn door handles?',
      ],
      '3-4': [
        'Can your child copy a circle when you draw one?',
        'Does your child use scissors to cut along a straight line?',
        'Can your child draw a person with at least 2 body parts?',
        'Does your child hold a pencil or crayon with fingers (not a fist)?',
        'Can your child button and unbutton large buttons?',
      ],
      '4-5': [
        'Can your child draw a recognisable person with head, body, arms and legs?',
        'Does your child cut along curved lines with scissors?',
        'Can your child write some letters of their name?',
        'Does your child colour within lines reasonably well?',
        'Can your child tie a simple knot or bow?',
      ],
    },
    'Gross Motor Skills': {
      '1-2': [
        'Can your child walk without holding onto anything?',
        'Does your child attempt to climb on low furniture or play equipment?',
        'Can your child kick a ball forward?',
        'Does your child enjoy running and chasing games?',
        'Can your child walk up and down stairs holding your hand?',
      ],
      '2-3': [
        'Can your child jump with both feet off the ground?',
        'Does your child run without frequently falling?',
        'Can your child kick a ball and aim in a direction?',
        'Does your child enjoy climbing ladders or jungle gyms?',
        'Can your child pedal a tricycle?',
      ],
      '3-4': [
        'Can your child hop on one foot at least twice?',
        'Does your child catch a large ball most of the time?',
        'Can your child ride a tricycle or balance bike confidently?',
        'Does your child climb stairs alternating feet without holding the rail?',
        'Can your child do a forward roll or somersault?',
      ],
      '4-5': [
        'Can your child skip with alternating feet?',
        'Does your child catch a small ball with hands only?',
        'Can your child balance on one foot for 5+ seconds?',
        'Does your child ride a bike with or without training wheels?',
        'Can your child perform simple gymnastic movements (jump, roll, spin)?',
      ],
    },
    'Communication': {
      '1-2': [
        'Does your child say at least 10 recognisable single words?',
        'Can your child follow simple one-step instructions (e.g. "Give me the cup")?',
        'Does your child point to objects or pictures when named?',
        'Does your child use gestures like waving bye-bye or pointing?',
        'Does your child try to imitate new words you say?',
      ],
      '2-3': [
        'Does your child combine two words (e.g. "more milk", "daddy go")?',
        'Can your child follow two-step instructions?',
        'Does your child refer to themselves by name?',
        'Can strangers understand at least half of what your child says?',
        'Does your child ask simple questions (e.g. "What that?")?',
      ],
      '3-4': [
        'Can your child use sentences of 3–4 words regularly?',
        'Does your child tell simple stories or describe recent events?',
        'Can your child say their first and last name?',
        'Does your child ask "why" questions frequently?',
        'Can most strangers understand your child\'s speech?',
      ],
      '4-5': [
        'Does your child use sentences of 5 or more words?',
        'Can your child tell a short story with a beginning, middle and end?',
        'Does your child use past and future tenses correctly most of the time?',
        'Can your child carry on a back-and-forth conversation?',
        'Does your child understand and use basic grammar rules?',
      ],
    },
    'Social-Emotional': {
      '1-2': [
        'Does your child show affection to familiar people (hugs, kisses)?',
        'Does your child play games like peek-a-boo or pat-a-cake?',
        'Does your child notice and react when other children are nearby?',
        'Does your child show separation anxiety when you leave?',
        'Does your child seek comfort from you when upset or hurt?',
      ],
      '2-3': [
        'Does your child play alongside other children (parallel play)?',
        'Does your child show defiance or say "no" as a way to assert independence?',
        'Does your child show empathy when someone is upset?',
        'Does your child engage in simple pretend play (e.g. feeding a doll)?',
        'Does your child express a range of emotions (happy, sad, angry)?',
      ],
      '3-4': [
        'Does your child take turns in games most of the time?',
        'Does your child play cooperatively with other children?',
        'Can your child separate from you without major distress at familiar places?',
        'Does your child show preference for certain friends?',
        'Can your child identify how others might be feeling?',
      ],
      '4-5': [
        'Does your child make and keep friendships with peers?',
        'Can your child negotiate and compromise during play?',
        'Does your child understand the difference between pretend and real?',
        'Can your child manage disappointment without a major meltdown most of the time?',
        'Does your child show pride in their own achievements?',
      ],
    },
    'Cognitive': {
      '1-2': [
        'Does your child recognise familiar people and objects?',
        'Does your child show interest in cause and effect (e.g. dropping things)?',
        'Can your child find a toy that was hidden while they watched?',
        'Does your child point to body parts when asked?',
        'Does your child show curiosity by exploring objects in different ways?',
      ],
      '2-3': [
        'Can your child sort objects by shape or colour?',
        'Does your child understand the concept of "one" vs "many"?',
        'Can your child complete a 3–4 piece puzzle?',
        'Does your child pretend that one object is something else in play?',
        'Can your child match identical pictures or objects?',
      ],
      '3-4': [
        'Can your child count to 10 by rote?',
        'Does your child understand size concepts like big, medium, small?',
        'Can your child complete a 6–8 piece puzzle?',
        'Does your child understand time concepts like today, tomorrow, yesterday?',
        'Can your child name at least 4 colours correctly?',
      ],
      '4-5': [
        'Can your child count objects up to 10 with one-to-one correspondence?',
        'Does your child recognise and write some letters or numbers?',
        'Can your child retell a story in the correct order?',
        'Does your child understand and apply rules in simple games?',
        'Can your child compare quantities (more, less, same)?',
      ],
    },
    'Adaptive Skills': {
      '1-2': [
        'Does your child try to feed themselves with a spoon?',
        'Can your child drink from an open cup with some spilling?',
        'Does your child help with dressing by pushing arms through sleeves?',
        'Does your child try to help put toys away?',
        'Does your child indicate when they have a wet or soiled nappy?',
      ],
      '2-3': [
        'Can your child use a spoon and fork with reasonable success?',
        'Does your child wash and dry hands with some help?',
        'Can your child pull pants up and down for toilet use?',
        'Does your child show interest in using the toilet?',
        'Can your child remove simple clothing like socks or shoes?',
      ],
      '3-4': [
        'Can your child dress and undress with minimal help?',
        'Does your child brush teeth with some adult supervision?',
        'Can your child use the toilet independently (day-time)?',
        'Does your child wash hands before meals without being reminded often?',
        'Can your child pour from a small jug into a cup?',
      ],
      '4-5': [
        'Can your child dress and undress completely independently?',
        'Does your child brush teeth and wash face without reminders?',
        'Can your child prepare a simple snack (e.g. spreading butter)?',
        'Does your child manage toileting fully independently?',
        'Can your child follow a simple daily routine with minimal prompting?',
      ],
    },
    'Sensory Processing': {
      '1-2': [
        'Does your child react very strongly (crying, covering ears) to everyday loud noises?',
        'Does your child accept a variety of food textures without distress?',
        'Does your child seek out movement activities (rocking, spinning)?',
        'Does your child tolerate being touched (hugged, hair brushed) without major upset?',
        'Does your child explore objects by mouthing them more than expected?',
      ],
      '2-3': [
        'Does your child avoid certain textures of food to an extreme degree?',
        'Does your child seem unaware of pain or temperature that others notice?',
        'Does your child become very upset by specific clothing textures or seams?',
        'Does your child seek intense sensory input (crashing, spinning) frequently?',
        'Does your child have difficulty in busy or noisy environments?',
      ],
      '3-4': [
        'Does your child have difficulty sitting still for a 5-minute activity?',
        'Does your child have strong negative reactions to certain smells?',
        'Does your child avoid playground equipment like swings or slides?',
        'Does your child frequently touch objects or people excessively?',
        'Does your child become overwhelmed in busy or bright environments?',
      ],
      '4-5': [
        'Does your child complain about lights being too bright?',
        'Does your child have very strong food preferences based on texture or smell?',
        'Does your child have difficulty sitting still during meals or class time?',
        'Does your child seem clumsy or unaware of their body in space?',
        'Does your child need movement breaks more than peers to stay focused?',
      ],
    },
  };
}