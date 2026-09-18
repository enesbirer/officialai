// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'petition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PetitionModelImpl _$$PetitionModelImplFromJson(Map<String, dynamic> json) =>
    _$PetitionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$PetitionModelImplToJson(_$PetitionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'categoryId': instance.categoryId,
      'title': instance.title,
      'content': instance.content,
      'isFavorite': instance.isFavorite,
      'createdAt': instance.createdAt.toIso8601String(),
    };
