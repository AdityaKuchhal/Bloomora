import 'package:json_annotation/json_annotation.dart';

part 'assessment_response_model.g.dart';

@JsonSerializable()
class AssessmentResponseModel {
  final String id;
  final String childId;
  final String questionId;
  final String selectedOption;
  final int score;
  final DateTime answeredAt;
  final String? notes;

  const AssessmentResponseModel({
    required this.id,
    required this.childId,
    required this.questionId,
    required this.selectedOption,
    required this.score,
    required this.answeredAt,
    this.notes,
  });

  factory AssessmentResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentResponseModelToJson(this);

  AssessmentResponseModel copyWith({
    String? id,
    String? childId,
    String? questionId,
    String? selectedOption,
    int? score,
    DateTime? answeredAt,
    String? notes,
  }) {
    return AssessmentResponseModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      questionId: questionId ?? this.questionId,
      selectedOption: selectedOption ?? this.selectedOption,
      score: score ?? this.score,
      answeredAt: answeredAt ?? this.answeredAt,
      notes: notes ?? this.notes,
    );
  }
}

@JsonSerializable()
class AssessmentResultModel {
  final String id;
  final String childId;
  final String ageGroup;
  final Map<String, int> domainScores;
  final Map<String, double> domainPercentages;
  final double overallScore;
  final double adhdRiskScore;
  final double asdRiskScore;
  final List<String> topPriorities;
  final List<String> recommendations;
  final DateTime completedAt;
  final DateTime createdAt;

  const AssessmentResultModel({
    required this.id,
    required this.childId,
    required this.ageGroup,
    required this.domainScores,
    required this.domainPercentages,
    required this.overallScore,
    required this.adhdRiskScore,
    required this.asdRiskScore,
    required this.topPriorities,
    required this.recommendations,
    required this.completedAt,
    required this.createdAt,
  });

  factory AssessmentResultModel.fromJson(Map<String, dynamic> json) =>
      _$AssessmentResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$AssessmentResultModelToJson(this);

  AssessmentResultModel copyWith({
    String? id,
    String? childId,
    String? ageGroup,
    Map<String, int>? domainScores,
    Map<String, double>? domainPercentages,
    double? overallScore,
    double? adhdRiskScore,
    double? asdRiskScore,
    List<String>? topPriorities,
    List<String>? recommendations,
    DateTime? completedAt,
    DateTime? createdAt,
  }) {
    return AssessmentResultModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      ageGroup: ageGroup ?? this.ageGroup,
      domainScores: domainScores ?? this.domainScores,
      domainPercentages: domainPercentages ?? this.domainPercentages,
      overallScore: overallScore ?? this.overallScore,
      adhdRiskScore: adhdRiskScore ?? this.adhdRiskScore,
      asdRiskScore: asdRiskScore ?? this.asdRiskScore,
      topPriorities: topPriorities ?? this.topPriorities,
      recommendations: recommendations ?? this.recommendations,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
