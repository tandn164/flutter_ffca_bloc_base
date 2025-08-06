import 'package:formz/formz.dart';

import '../../../../../core/utils/regex.dart';
import '../../../../../core/utils/widget_util.dart';

enum PasswordValidationError { empty, invalid }

extension PasswordValidationErrorX on PasswordValidationError {
  String? get errorMessage {
    switch (this) {
      case PasswordValidationError.empty:
        return l10n.messageE3;
      case PasswordValidationError.invalid:
        return l10n.messageE6;
      default:
        return null;
    }
  }
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure() : super.pure('');
  const Password.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (!RegexUtils.validatePassword(value)) {
      return PasswordValidationError.invalid;
    }
    return null;
  }
}
