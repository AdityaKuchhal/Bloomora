class AppConstants {
  // App Information
  static const String appName = 'Bloomora';
  static const String appVersion = '1.0.0';

  // API Configuration — single source of truth for all environments
  // Override via AppConfig.baseUrl at runtime (loaded from .env)
  static const String baseUrl = 'https://bloomora-api.up.railway.app/api/v1';
  static const String apiVersion = 'v1';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String childDataKey = 'child_data';
  static const String assessmentDataKey = 'assessment_data';
  static const String preferencesKey = 'user_preferences';

  // Assessment Configuration
  static const int questionsPerDomain = 5;
  static const int totalDomains = 7;
  static const int totalQuestions = questionsPerDomain * totalDomains;

  // Age Groups
  static const List<String> ageGroups = ['1-2', '2-3', '3-4', '4-5'];

  // Developmental Domains
  static const List<String> domains = [
    'Fine Motor Skills',
    'Gross Motor Skills',
    'Communication',
    'Social-Emotional',
    'Cognitive',
    'Adaptive Skills',
    'Sensory Processing'
  ];

  // Domain Descriptions
  static const Map<String, String> domainDescriptions = {
    'Fine Motor Skills':
        'Hand-eye coordination, finger dexterity, and precise movements',
    'Gross Motor Skills':
        'Large muscle movements, balance, and physical coordination',
    'Communication':
        'Understanding and expressing language, speech development',
    'Social-Emotional':
        'Interacting with others, managing emotions, and behavior',
    'Cognitive': 'Learning, problem-solving, memory, and attention skills',
    'Adaptive Skills': 'Daily living activities and self-care abilities',
    'Sensory Processing': 'Processing and responding to sensory information'
  };

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
}
