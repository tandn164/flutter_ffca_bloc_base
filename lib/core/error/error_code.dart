import '../utils/widget_util.dart';

enum ErrorCode {
  E1("E1"),
  E2("E2"),
  E3("E3"),
  E4("E4"),
  E5("E5"),
  E6("E6"),
  E7("E7"),
  E8("E8"),
  E9("E9");

  String get errorMessage {
    switch (this) {
      case E1:
        return l10n.messageE1;
      case E2:
        return l10n.messageE1;
      case E3:
        return l10n.messageE3;
      case E4:
        return l10n.messageE4;
      case E5:
        return l10n.messageE5;
      case E6:
        return l10n.messageE6;
      case E7:
        return l10n.messageE7;
      case E8:
        return l10n.messageE8;
      case E9:
        return l10n.messageE9;
      default:
        return l10n.unknownError;
    }
  }

  const ErrorCode(this.value);

  final String value;

  factory ErrorCode.fromValue(String value) {
    return values.firstWhere((e) => e.value == value);
  }
}