import 'package:sample_data/src/dtos/sample_item_dto.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:test/test.dart';

void main() {
  test('JSON defaults, round trip and entity mapping', () {
    final dto = SampleItemDto.fromJson({'id': '1', 'title': 'Task'});
    expect(dto.done, isFalse);
    expect(SampleItemDto.fromJson(dto.toJson()), dto);
    expect(dto.toEntity(), const SampleItem(id: '1', title: 'Task'));
    expect(dto.copyWith(done: true).toEntity().done, isTrue);
  });
  test('invalid server field types still fail decoding', () {
    expect(() => SampleItemDto.fromJson({'id': 42, 'title': 'Task'}),
        throwsA(isA<TypeError>()));
  });
}
