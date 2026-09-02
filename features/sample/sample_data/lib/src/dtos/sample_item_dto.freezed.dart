// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SampleItemDto {
  String get id;
  String get title;
  bool get done;

  /// Create a copy of SampleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SampleItemDtoCopyWith<SampleItemDto> get copyWith =>
      _$SampleItemDtoCopyWithImpl<SampleItemDto>(
          this as SampleItemDto, _$identity);

  /// Serializes this SampleItemDto to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SampleItemDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, done);

  @override
  String toString() {
    return 'SampleItemDto(id: $id, title: $title, done: $done)';
  }
}

/// @nodoc
abstract mixin class $SampleItemDtoCopyWith<$Res> {
  factory $SampleItemDtoCopyWith(
          SampleItemDto value, $Res Function(SampleItemDto) _then) =
      _$SampleItemDtoCopyWithImpl;
  @useResult
  $Res call({String id, String title, bool done});
}

/// @nodoc
class _$SampleItemDtoCopyWithImpl<$Res>
    implements $SampleItemDtoCopyWith<$Res> {
  _$SampleItemDtoCopyWithImpl(this._self, this._then);

  final SampleItemDto _self;
  final $Res Function(SampleItemDto) _then;

  /// Create a copy of SampleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? done = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _SampleItemDto extends SampleItemDto {
  const _SampleItemDto(
      {required this.id, required this.title, this.done = false})
      : super._();
  factory _SampleItemDto.fromJson(Map<String, dynamic> json) =>
      _$SampleItemDtoFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  @JsonKey()
  final bool done;

  /// Create a copy of SampleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SampleItemDtoCopyWith<_SampleItemDto> get copyWith =>
      __$SampleItemDtoCopyWithImpl<_SampleItemDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$SampleItemDtoToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SampleItemDto &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.done, done) || other.done == done));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title, done);

  @override
  String toString() {
    return 'SampleItemDto(id: $id, title: $title, done: $done)';
  }
}

/// @nodoc
abstract mixin class _$SampleItemDtoCopyWith<$Res>
    implements $SampleItemDtoCopyWith<$Res> {
  factory _$SampleItemDtoCopyWith(
          _SampleItemDto value, $Res Function(_SampleItemDto) _then) =
      __$SampleItemDtoCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String title, bool done});
}

/// @nodoc
class __$SampleItemDtoCopyWithImpl<$Res>
    implements _$SampleItemDtoCopyWith<$Res> {
  __$SampleItemDtoCopyWithImpl(this._self, this._then);

  final _SampleItemDto _self;
  final $Res Function(_SampleItemDto) _then;

  /// Create a copy of SampleItemDto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? done = null,
  }) {
    return _then(_SampleItemDto(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      done: null == done
          ? _self.done
          : done // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
