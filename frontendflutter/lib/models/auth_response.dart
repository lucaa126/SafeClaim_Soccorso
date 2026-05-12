/// Risposta di validazione token dal backend
class AuthStatusResponse {
  final String message;
  final String provider;
  final UserInfo user;
  final List<String> roles;

  const AuthStatusResponse({
    required this.message,
    required this.provider,
    required this.user,
    required this.roles,
  });

  factory AuthStatusResponse.fromJson(Map<String, dynamic> json) {
    return AuthStatusResponse(
      message: json['message'] as String? ?? '',
      provider: json['provider'] as String? ?? 'keycloak',
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}

/// Informazioni utente dal token
class UserInfo {
  final String sub;
  final String? email;
  final String? preferredUsername;

  const UserInfo({
    required this.sub,
    this.email,
    this.preferredUsername,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      sub: json['sub'] as String? ?? '',
      email: json['email'] as String?,
      preferredUsername: json['preferred_username'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'sub': sub,
        'email': email,
        'preferred_username': preferredUsername,
      };
}

/// Risposta di validazione token
class ValidateTokenResponse {
  final String message;
  final Map<String, dynamic> user;
  final List<String> roles;

  const ValidateTokenResponse({
    required this.message,
    required this.user,
    required this.roles,
  });

  factory ValidateTokenResponse.fromJson(Map<String, dynamic> json) {
    return ValidateTokenResponse(
      message: json['message'] as String? ?? '',
      user: json['user'] as Map<String, dynamic>? ?? {},
      roles: List<String>.from(json['roles'] as List? ?? []),
    );
  }
}
