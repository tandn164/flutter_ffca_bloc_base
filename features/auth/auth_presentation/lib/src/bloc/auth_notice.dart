import 'package:equatable/equatable.dart';

enum AuthNoticeKind { success, error }

class AuthNotice extends Equatable {
  const AuthNotice({
    required this.message,
    required this.kind,
    required this.id,
  });

  final String message;
  final AuthNoticeKind kind;
  final int id;

  @override
  List<Object?> get props => [message, kind, id];
}
