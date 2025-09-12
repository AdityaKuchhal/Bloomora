// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssessmentResponseModel _$AssessmentResponseModelFromJson(
        Map<String, dynamic> json) =>
    AssessmentResponseModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      questionId: json['questionId'] as String,
      selectedOption: json['selectedOption'] as String,
      score: (json['score'] as num).toInt(),
      answeredAt: DateTime.parse(json['answeredAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AssessmentResponseModelToJson(
        AssessmentResponseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'questionId': instance.questionId,
      'selectedOption': instance.selectedOption,
      'score': instance.score,
      'answeredAt': instance.answeredAt.toIso8601String(),
      'notes': instance.notes,
    };

AssessmentResultModel _$AssessmentResultModelFromJson(
        Map<String, dynamic> json) =>
    AssessmentResultModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      ageGroup: json['ageGroup'] as String,
      domainScores: Map<String, int>.from(json['domainScores'] as Map),
      domainPercentages:
          (json['domainPercentages'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ),
      overallScore: (json['overallScore'] as num).toDouble(),
      adhdRiskScore: (json['adhdRiskScore'] as num).toDouble(),
      asdRiskScore: (json['asdRiskScore'] as num).toDouble(),
      topPriorities: (json['topPriorities'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AssessmentResultModelToJson(
        AssessmentResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'childId': instance.childId,
      'ageGroup': instance.ageGroup,
      'domainScores': instance.domainScores,
      'domainPercentages': instance.domainPercentages,
      'overallScore': instance.overallScore,
      'adhdRiskScore': instance.adhdRiskScore,
      'asdRiskScore': instance.asdRiskScore,
      'topPriorities': instance.topPriorities,
      'recommendations': instance.recommendations,
      'completedAt': instance.completedAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };
