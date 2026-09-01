# App Result

Pure Dart success and failure primitives shared by domain and data packages.

## Usage

```dart
Future<Result<User>> loadUser() async {
  try {
    return Ok(await api.loadUser());
  } catch (error) {
    return Err(NetworkFailure(error.toString()));
  }
}

switch (await loadUser()) {
  case Ok(value: final user):
    print(user.name);
  case Err(failure: final failure):
    print(failure.message);
}
```

Use `Result<T>` at repository boundaries. Do not throw transport exceptions
through the domain or presentation layers.

## Testing

```bash
dart test shared/app_result
```
