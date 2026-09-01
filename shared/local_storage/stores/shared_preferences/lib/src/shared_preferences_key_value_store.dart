import 'package:local_storage/local_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesKeyValueStore implements KeyValueStore {
  const SharedPreferencesKeyValueStore(this.preferences);

  final SharedPreferences preferences;

  @override
  Future<String?> readString(String key) async => preferences.getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    await preferences.setString(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await preferences.remove(key);
  }
}
