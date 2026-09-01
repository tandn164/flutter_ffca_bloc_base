import 'package:flutter/material.dart';

import 'validators.dart';

class FormScope extends InheritedWidget {
  const FormScope({super.key, required this.formKey, required super.child});

  final GlobalKey<FormState> formKey;

  bool validateAll() => formKey.currentState?.validate() ?? false;

  static FormScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FormScope>();
    if (scope == null) {
      throw FlutterError.fromParts([
        ErrorSummary(
            'FormScope.of() called with a context that has no FormScope ancestor.'),
        ErrorHint(
            'Wrap the caller in a Builder so the context is under FormScope.'),
      ]);
    }
    return scope;
  }

  @override
  bool updateShouldNotify(FormScope oldWidget) => formKey != oldWidget.formKey;
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.obscureText = false,
    this.validators = const [],
    this.keyboardType,
  });

  final TextEditingController controller;
  final String? label;
  final bool obscureText;
  final List<FieldValidator> validators;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: all(validators),
      decoration: InputDecoration(
        labelText: label,
      ),
    );
  }
}
