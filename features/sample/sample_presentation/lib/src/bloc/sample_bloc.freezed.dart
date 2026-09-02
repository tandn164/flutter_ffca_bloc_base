// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sample_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SampleState {
  SampleNotice? get notice;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SampleStateCopyWith<SampleState> get copyWith =>
      _$SampleStateCopyWithImpl<SampleState>(this as SampleState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SampleState &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, notice);

  @override
  String toString() {
    return 'SampleState(notice: $notice)';
  }
}

/// @nodoc
abstract mixin class $SampleStateCopyWith<$Res> {
  factory $SampleStateCopyWith(
          SampleState value, $Res Function(SampleState) _then) =
      _$SampleStateCopyWithImpl;
  @useResult
  $Res call({SampleNotice? notice});
}

/// @nodoc
class _$SampleStateCopyWithImpl<$Res> implements $SampleStateCopyWith<$Res> {
  _$SampleStateCopyWithImpl(this._self, this._then);

  final SampleState _self;
  final $Res Function(SampleState) _then;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notice = freezed,
  }) {
    return _then(_self.copyWith(
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as SampleNotice?,
    ));
  }
}

/// @nodoc

class SampleLoading implements SampleState {
  const SampleLoading({this.notice});

  @override
  final SampleNotice? notice;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SampleLoadingCopyWith<SampleLoading> get copyWith =>
      _$SampleLoadingCopyWithImpl<SampleLoading>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SampleLoading &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, notice);

  @override
  String toString() {
    return 'SampleState.loading(notice: $notice)';
  }
}

/// @nodoc
abstract mixin class $SampleLoadingCopyWith<$Res>
    implements $SampleStateCopyWith<$Res> {
  factory $SampleLoadingCopyWith(
          SampleLoading value, $Res Function(SampleLoading) _then) =
      _$SampleLoadingCopyWithImpl;
  @override
  @useResult
  $Res call({SampleNotice? notice});
}

/// @nodoc
class _$SampleLoadingCopyWithImpl<$Res>
    implements $SampleLoadingCopyWith<$Res> {
  _$SampleLoadingCopyWithImpl(this._self, this._then);

  final SampleLoading _self;
  final $Res Function(SampleLoading) _then;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notice = freezed,
  }) {
    return _then(SampleLoading(
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as SampleNotice?,
    ));
  }
}

/// @nodoc

class SampleData implements SampleState {
  const SampleData(final List<SampleItem> items,
      {this.hasMore = false,
      this.loadingMore = false,
      this.page = 1,
      this.generation = 0,
      this.notice})
      : _items = items;

  final List<SampleItem> _items;
  List<SampleItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @JsonKey()
  final bool hasMore;
  @JsonKey()
  final bool loadingMore;
  @JsonKey()
  final int page;
  @JsonKey()
  final int generation;
  @override
  final SampleNotice? notice;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SampleDataCopyWith<SampleData> get copyWith =>
      _$SampleDataCopyWithImpl<SampleData>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SampleData &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.loadingMore, loadingMore) ||
                other.loadingMore == loadingMore) &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.generation, generation) ||
                other.generation == generation) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_items),
      hasMore,
      loadingMore,
      page,
      generation,
      notice);

  @override
  String toString() {
    return 'SampleState.data(items: $items, hasMore: $hasMore, loadingMore: $loadingMore, page: $page, generation: $generation, notice: $notice)';
  }
}

/// @nodoc
abstract mixin class $SampleDataCopyWith<$Res>
    implements $SampleStateCopyWith<$Res> {
  factory $SampleDataCopyWith(
          SampleData value, $Res Function(SampleData) _then) =
      _$SampleDataCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<SampleItem> items,
      bool hasMore,
      bool loadingMore,
      int page,
      int generation,
      SampleNotice? notice});
}

/// @nodoc
class _$SampleDataCopyWithImpl<$Res> implements $SampleDataCopyWith<$Res> {
  _$SampleDataCopyWithImpl(this._self, this._then);

  final SampleData _self;
  final $Res Function(SampleData) _then;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? items = null,
    Object? hasMore = null,
    Object? loadingMore = null,
    Object? page = null,
    Object? generation = null,
    Object? notice = freezed,
  }) {
    return _then(SampleData(
      null == items
          ? _self._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<SampleItem>,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      loadingMore: null == loadingMore
          ? _self.loadingMore
          : loadingMore // ignore: cast_nullable_to_non_nullable
              as bool,
      page: null == page
          ? _self.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      generation: null == generation
          ? _self.generation
          : generation // ignore: cast_nullable_to_non_nullable
              as int,
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as SampleNotice?,
    ));
  }
}

/// @nodoc

class SampleError implements SampleState {
  const SampleError(this.message, {this.notice});

  final String message;
  @override
  final SampleNotice? notice;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SampleErrorCopyWith<SampleError> get copyWith =>
      _$SampleErrorCopyWithImpl<SampleError>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SampleError &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.notice, notice) || other.notice == notice));
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, notice);

  @override
  String toString() {
    return 'SampleState.error(message: $message, notice: $notice)';
  }
}

/// @nodoc
abstract mixin class $SampleErrorCopyWith<$Res>
    implements $SampleStateCopyWith<$Res> {
  factory $SampleErrorCopyWith(
          SampleError value, $Res Function(SampleError) _then) =
      _$SampleErrorCopyWithImpl;
  @override
  @useResult
  $Res call({String message, SampleNotice? notice});
}

/// @nodoc
class _$SampleErrorCopyWithImpl<$Res> implements $SampleErrorCopyWith<$Res> {
  _$SampleErrorCopyWithImpl(this._self, this._then);

  final SampleError _self;
  final $Res Function(SampleError) _then;

  /// Create a copy of SampleState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? message = null,
    Object? notice = freezed,
  }) {
    return _then(SampleError(
      null == message
          ? _self.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      notice: freezed == notice
          ? _self.notice
          : notice // ignore: cast_nullable_to_non_nullable
              as SampleNotice?,
    ));
  }
}

// dart format on
