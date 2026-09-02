/// Compile-time values selected by the host build.
class AppEnv {
  const AppEnv._();

  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
}
