// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sample_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SampleItemDto _$SampleItemDtoFromJson(Map<String, dynamic> json) =>
    _SampleItemDto(
      id: json['id'] as String,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
    );

Map<String, dynamic> _$SampleItemDtoToJson(_SampleItemDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'done': instance.done,
    };
