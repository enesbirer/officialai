import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'petition_model.freezed.dart';
part 'petition_model.g.dart';

@freezed
class PetitionModel with _$PetitionModel {
  const factory PetitionModel({
    required String id,
    required String userId,
    required String categoryId,
    required String title,
    required String content,
    @Default(false) bool isFavorite,
    required DateTime createdAt,
  }) = _PetitionModel;

  factory PetitionModel.fromJson(Map<String, dynamic> json) => _$PetitionModelFromJson(json);
}
