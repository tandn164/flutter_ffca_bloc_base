import 'dart:convert';

import 'package:app_result/app_result.dart';

Result<T> safeDecode<T>(String body, T Function(Object json) decode) {
  try {
    final Object json = jsonDecode(body) as Object;
    return Ok(decode(json));
  } catch (_) {
    return const Err(DecodeFailure());
  }
}
