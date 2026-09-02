import 'package:flutter/widgets.dart';

import 'app.dart';
import 'di.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await sl.reset();
  await register();
  runApp(const App());
}
