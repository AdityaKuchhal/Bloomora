import 'package:json_annotation/json_annotation.dart';

part 'child_model.g.dart';

@JsonSerializable()
class ChildModel {
  final String id;
  final String parentId;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String ageGroup;
  final String? relationship;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.ageGroup,
    this.relationship,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) =>
      _$ChildModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChildModelToJson(this);

  ChildModel copyWith({
    String? id,
    String? parentId,
    String? name,
    DateTime? dateOfBirth,
    String? gender,
    String? ageGroup,
    String? relationship,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChildModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      relationship: relationship ?? this.relationship,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get ageInMonths {
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    return (age.inDays / 30.44).round();
  }

  String get ageGroupFromBirthDate {
    final months = ageInMonths;
    if (months >= 12 && months < 24) return '1-2';
    if (months >= 24 && months < 36) return '2-3';
    if (months >= 36 && months < 48) return '3-4';
    if (months >= 48 && months < 60) return '4-5';
    return '1-2';
  }
}