import 'package:formz/formz.dart';

import '../../../../../core/utils/regex.dart';
import '../../../../../core/utils/widget_util.dart';

enum UsernameValidationError { empty, invalid }

extension UsernameValidationErrorX on UsernameValidationError {
  String? get errorMessage {
    switch (this) {
      case UsernameValidationError.empty:
        return l10n.messageE1;
      case UsernameValidationError.invalid:
        return l10n.messageE9;
      default:
        return null;
    }
  }
}

class Username extends FormzInput<String, UsernameValidationError> {
  const Username.pure() : super.pure('');
  const Username.dirty([super.value = '']) : super.dirty();

  @override
  UsernameValidationError? validator(String value) {
    if (value.isEmpty) return UsernameValidationError.empty;
    if (!RegexUtils.validateUsername(value)) return UsernameValidationError.invalid;
    return null;
  }
}
