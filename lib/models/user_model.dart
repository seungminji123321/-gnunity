class AppUser {
  final String uid;
  final String email;
  final String? displayName;
//생성자
  AppUser({
    required this.uid,
    required this.email,
    this.displayName,
  });
}
