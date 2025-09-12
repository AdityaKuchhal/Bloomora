import 'package:json_annotation/json_annotation.dart';

part 'parent_model.g.dart';

@JsonSerializable()
class ParentModel {
  final String id;
  final String name;
  final String email;
  final String phoneNumber;
  final String location;
  final String timezone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.location,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentModel.fromJson(Map<String, dynamic> json) =>
      _$ParentModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParentModelToJson(this);

  ParentModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? location,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      location: location ?? this.location,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
