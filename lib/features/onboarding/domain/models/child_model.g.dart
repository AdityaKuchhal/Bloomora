// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'child_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChildModel _$ChildModelFromJson(Map<String, dynamic> json) => ChildModel(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      birthTime: json['birthTime'] as String?,
      gender: json['gender'] as String,
      ageGroup: json['ageGroup'] as String,
      existingDiagnoses: (json['existingDiagnoses'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      concerns:
          (json['concerns'] as List<dynamic>).map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ChildModelToJson(ChildModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parentId': instance.parentId,
      'name': instance.name,
      'dateOfBirth': instance.dateOfBirth.toIso8601String(),
      'birthTime': instance.birthTime,
      'gender': instance.gender,
      'ageGroup': instance.ageGroup,
      'existingDiagnoses': instance.existingDiagnoses,
      'concerns': instance.concerns,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
