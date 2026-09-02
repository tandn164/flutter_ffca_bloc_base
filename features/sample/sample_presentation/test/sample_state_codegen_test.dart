import 'package:flutter_test/flutter_test.dart';
import 'package:sample_domain/sample_domain.dart';
import 'package:sample_presentation/sample_presentation.dart';

void main() {
  test('copyWith distinguishes omitted notice from explicit null', () {
    const notice =
        SampleNotice(message: 'Saved', kind: SampleNoticeKind.success, id: 1);
    const state = SampleData([], notice: notice);
    expect(state.copyWith(loadingMore: true).notice, notice);
    expect(state.copyWith(notice: null).notice, isNull);
  });
  test('generated states compare list values and prevent list mutation', () {
    const item = SampleItem(id: '1', title: 'Task');
    expect(SampleData([item]), const SampleData([item]));
    expect(() => SampleData([item]).items.clear(), throwsUnsupportedError);
  });
}
