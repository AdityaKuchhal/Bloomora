import 'package:json_annotation/json_annotation.dart';

part 'question_model.g.dart';

@JsonSerializable()
class QuestionModel {
  final String id;
  final String domain;
  final String ageGroup;
  final int questionNumber;
  final String questionText;
  final List<String> options;
  final String? imageUrl;
  final String? videoUrl;
  final String? additionalInfo;
  final bool isRequired;
  final int weight;

  const QuestionModel({
    required this.id,
    required this.domain,
    required this.ageGroup,
    required this.questionNumber,
    required this.questionText,
    required this.options,
    this.imageUrl,
    this.videoUrl,
    this.additionalInfo,
    this.isRequired = true,
    this.weight = 1,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionModelToJson(this);

  QuestionModel copyWith({
    String? id,
    String? domain,
    String? ageGroup,
    int? questionNumber,
    String? questionText,
    List<String>? options,
    String? imageUrl,
    String? videoUrl,
    String? additionalInfo,
    bool? isRequired,
    int? weight,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      ageGroup: ageGroup ?? this.ageGroup,
      questionNumber: questionNumber ?? this.questionNumber,
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      isRequired: isRequired ?? this.isRequired,
      weight: weight ?? this.weight,
    );
  }
}
