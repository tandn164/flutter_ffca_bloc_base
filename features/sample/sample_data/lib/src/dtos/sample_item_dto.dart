import 'package:sample_domain/sample_domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sample_item_dto.freezed.dart';
part 'sample_item_dto.g.dart';

@freezed
abstract class SampleItemDto with _$SampleItemDto {
  const SampleItemDto._();
  const factory SampleItemDto({
    required String id,
    required String title,
    @Default(false) bool done,
  }) = _SampleItemDto;

  factory SampleItemDto.fromJson(Map<String, dynamic> json) =>
      _$SampleItemDtoFromJson(json);

  SampleItem toEntity() => SampleItem(id: id, title: title, done: done);

  static List<SampleItemDto> listFromJson(Object json) {
    final map = json as Map<String, dynamic>;
    return [
      for (final raw in map['items'] as List<dynamic>)
        SampleItemDto.fromJson(raw as Map<String, dynamic>),
    ];
  }
}
