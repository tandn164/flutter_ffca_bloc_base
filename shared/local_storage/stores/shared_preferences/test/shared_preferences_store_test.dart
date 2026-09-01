import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage_shared_preferences/local_storage_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('persists strings through SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final store = SharedPreferencesKeyValueStore(preferences);

    await store.writeString('key', 'value');

    expect(await store.readString('key'), 'value');
  });
}
