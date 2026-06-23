import 'package:composable_network/composable_network.dart';
import 'package:test/test.dart';

void main() {
  group('SafeResponseParser', () {
    const parser = SafeResponseParser();

    test('parseObject returns success for valid map', () {
      final result = parser.parseObject<int>(
        {'value': 42},
        decode: (json) => json['value'] as int,
      );

      expect(result, isA<ApiSuccess<int>>());
      expect((result as ApiSuccess<int>).value, 42);
    });

    test('parseObject returns decode error for invalid payload', () {
      final result = parser.parseObject<int>(
        'not-json',
        decode: (json) => json['value'] as int,
      );

      expect(result, isA<ApiError<int>>());
      expect(
        (result as ApiError<int>).failure.kind,
        ApiFailureKind.decodeError,
      );
    });

    test('parseEnvelope decodes nested data field', () {
      final result = parser.parseEnvelope<String>(
        {
          'data': {'name': 'test'},
          'meta': {'code': 200},
        },
        decodeData: (json) => json['name'] as String,
      );

      expect(result, isA<ApiSuccess<String>>());
      expect((result as ApiSuccess<String>).value, 'test');
    });
  });
}
