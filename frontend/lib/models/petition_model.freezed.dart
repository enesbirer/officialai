// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'petition_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PetitionModel _$PetitionModelFromJson(Map<String, dynamic> json) {
  return _PetitionModel.fromJson(json);
}

/// @nodoc
mixin _$PetitionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get categoryId => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  bool get isFavorite => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PetitionModelCopyWith<PetitionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PetitionModelCopyWith<$Res> {
  factory $PetitionModelCopyWith(
          PetitionModel value, $Res Function(PetitionModel) then) =
      _$PetitionModelCopyWithImpl<$Res, PetitionModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String categoryId,
      String title,
      String content,
      bool isFavorite,
      DateTime createdAt});
}

/// @nodoc
class _$PetitionModelCopyWithImpl<$Res, $Val extends PetitionModel>
    implements $PetitionModelCopyWith<$Res> {
  _$PetitionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? title = null,
    Object? content = null,
    Object? isFavorite = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PetitionModelImplCopyWith<$Res>
    implements $PetitionModelCopyWith<$Res> {
  factory _$$PetitionModelImplCopyWith(
          _$PetitionModelImpl value, $Res Function(_$PetitionModelImpl) then) =
      __$$PetitionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String categoryId,
      String title,
      String content,
      bool isFavorite,
      DateTime createdAt});
}

/// @nodoc
class __$$PetitionModelImplCopyWithImpl<$Res>
    extends _$PetitionModelCopyWithImpl<$Res, _$PetitionModelImpl>
    implements _$$PetitionModelImplCopyWith<$Res> {
  __$$PetitionModelImplCopyWithImpl(
      _$PetitionModelImpl _value, $Res Function(_$PetitionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? categoryId = null,
    Object? title = null,
    Object? content = null,
    Object? isFavorite = null,
    Object? createdAt = null,
  }) {
    return _then(_$PetitionModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isFavorite: null == isFavorite
          ? _value.isFavorite
          : isFavorite // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PetitionModelImpl implements _PetitionModel {
  const _$PetitionModelImpl(
      {required this.id,
      required this.userId,
      required this.categoryId,
      required this.title,
      required this.content,
      this.isFavorite = false,
      required this.createdAt});

  factory _$PetitionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PetitionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String categoryId;
  @override
  final String title;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isFavorite;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'PetitionModel(id: $id, userId: $userId, categoryId: $categoryId, title: $title, content: $content, isFavorite: $isFavorite, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PetitionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isFavorite, isFavorite) ||
                other.isFavorite == isFavorite) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, categoryId, title,
      content, isFavorite, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PetitionModelImplCopyWith<_$PetitionModelImpl> get copyWith =>
      __$$PetitionModelImplCopyWithImpl<_$PetitionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PetitionModelImplToJson(
      this,
    );
  }
}

abstract class _PetitionModel implements PetitionModel {
  const factory _PetitionModel(
      {required final String id,
      required final String userId,
      required final String categoryId,
      required final String title,
      required final String content,
      final bool isFavorite,
      required final DateTime createdAt}) = _$PetitionModelImpl;

  factory _PetitionModel.fromJson(Map<String, dynamic> json) =
      _$PetitionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get categoryId;
  @override
  String get title;
  @override
  String get content;
  @override
  bool get isFavorite;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$PetitionModelImplCopyWith<_$PetitionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
