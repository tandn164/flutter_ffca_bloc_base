typedef FieldValidator = String? Function(String? value);

enum ValidationErrorCode { required, invalidEmail, tooShort, tooLong, custom }

class ValidationError {
  const ValidationError(this.code, {this.arguments = const {}});

  final ValidationErrorCode code;
  final Map<String, Object> arguments;
}

abstract class ValidationRule {
  const ValidationRule();
  ValidationError? validate(String? value);
}

class RequiredRule extends ValidationRule {
  const RequiredRule();

  @override
  ValidationError? validate(String? value) =>
      value == null || value.trim().isEmpty
          ? const ValidationError(ValidationErrorCode.required)
          : null;
}

class EmailRule extends ValidationRule {
  const EmailRule({this.allowEmpty = true});

  final bool allowEmpty;

  @override
  ValidationError? validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty && allowEmpty) return null;
    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(text);
    return valid
        ? null
        : const ValidationError(ValidationErrorCode.invalidEmail);
  }
}

class MinLengthRule extends ValidationRule {
  const MinLengthRule(this.length);
  final int length;

  @override
  ValidationError? validate(String? value) {
    if ((value ?? '').length >= length) return null;
    return ValidationError(
      ValidationErrorCode.tooShort,
      arguments: {'min': length},
    );
  }
}

ValidationError? validateRules(
  String? value,
  Iterable<ValidationRule> rules,
) {
  for (final rule in rules) {
    final error = rule.validate(value);
    if (error != null) return error;
  }
  return null;
}

FieldValidator localizedValidator({
  required List<ValidationRule> rules,
  required String Function(ValidationError error) messageFor,
}) {
  return (value) {
    final error = validateRules(value, rules);
    return error == null ? null : messageFor(error);
  };
}

FieldValidator requiredField(String message) {
  return (value) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  };
}

FieldValidator emailField(String message) {
  return (value) {
    if (value == null || value.trim().isEmpty) return null;
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
    return ok ? null : message;
  };
}

FieldValidator minLength(int min, String message) {
  return (value) {
    if (value == null) return message;
    return value.length >= min ? null : message;
  };
}

FieldValidator all(List<FieldValidator> rules) {
  return (value) {
    for (final rule in rules) {
      final error = rule(value);
      if (error != null) return error;
    }
    return null;
  };
}
