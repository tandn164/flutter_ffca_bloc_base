import 'package:app_result/app_result.dart';
import 'package:test/test.dart';

void main() {
  test('Ok and Err fold', () {
    const ok = Ok<int>(1);
    const err = Err<int>(NetworkFailure('down'));
    expect(ok.fold(ok: (v) => v, err: (_) => 0), 1);
    expect(err.fold(ok: (_) => '', err: (f) => f.message), 'down');
    expect(ok.isOk, isTrue);
    expect(err.isErr, isTrue);
  });
}
