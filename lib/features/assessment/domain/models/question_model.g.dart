// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuestionModel _$QuestionModelFromJson(Map<String, dynamic> json) =>
    QuestionModel(
      id: json['id'] as String,
      domain: json['domain'] as String,
      ageGroup: json['ageGroup'] as String,
      questionNumber: (json['questionNumber'] as num).toInt(),
      questionText: json['questionText'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      additionalInfo: json['additionalInfo'] as String?,
      isRequired: json['isRequired'] as bool? ?? true,
      weight: (json['weight'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$QuestionModelToJson(QuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'domain': instance.domain,
      'ageGroup': instance.ageGroup,
      'questionNumber': instance.questionNumber,
      'questionText': instance.questionText,
      'options': instance.options,
      'imageUrl': instance.imageUrl,
      'videoUrl': instance.videoUrl,
      'additionalInfo': instance.additionalInfo,
      'isRequired': instance.isRequired,
      'weight': instance.weight,
    };
