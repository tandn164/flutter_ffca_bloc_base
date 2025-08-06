import 'package:formz/formz.dart';

import '../../../../../core/utils/regex.dart';
import '../../../../../core/utils/widget_util.dart';

enum EmailValidationError { empty, invalid }

extension EmailValidationErrorX on EmailValidationError {
  String? get errorMessage {
    switch (this) {
      case EmailValidationError.empty:
        return l10n.messageE2;
      case EmailValidationError.invalid:
        return l10n.messageE9;
      default:
        return null;
    }
  }
}

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure() : super.pure('');
  const Email.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!RegexUtils.validateEmail(value)) return EmailValidationError.invalid;
    return null;
  }
}
