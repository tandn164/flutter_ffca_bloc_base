enum AuthStatus { initial, guest, user }

extension AuthStatusX on AuthStatus {
  bool get isGuest => this == AuthStatus.guest;
  bool get isUser => this == AuthStatus.user;
} 