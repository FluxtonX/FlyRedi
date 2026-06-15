class RegisterRequest {
  final String displayName;
  final String email;
  final String password;

  RegisterRequest({
    required this.displayName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'email': email,
      'password': password,
    };
  }
}
