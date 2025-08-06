class RegexUtils {
  static bool validatePassword(String text) {
    RegExp regex = RegExp(r"""^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-=[\]{};':"\\|,.<>/?]).{8,}$""");
    return regex.hasMatch(text);
  }

  static bool validateEmail(String text) {
    RegExp regex = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return regex.hasMatch(text);
  }

  static bool validateUrl(String text) {
    RegExp regex = RegExp(r"""^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_+.~#?&/=]*)$""");
    return regex.hasMatch(text);
  }

  static bool validateUsername(String text) {
    RegExp regex = RegExp(r"""^[a-zA-Z0-9_.-]+$""");
    return regex.hasMatch(text);
  }
}
