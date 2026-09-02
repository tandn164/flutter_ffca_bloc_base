import 'package:app_connectivity/app_connectivity.dart';
import 'package:test/test.dart';

void main() {
  test('notifies only when the connectivity hint changes', () {
    final connectivity = MutableConnectivityHint();
    var notifications = 0;
    connectivity.addListener(() => notifications++);

    connectivity
      ..setOffline(true)
      ..setOffline(true)
      ..setOffline(false);

    expect(connectivity.isSureOffline, isFalse);
    expect(notifications, 2);
  });
}
