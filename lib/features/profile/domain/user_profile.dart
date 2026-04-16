class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.name,
    required this.language,
    required this.goal,
    required this.plan,
    this.photoUrl,
  });

  final String uid;
  final String email;
  final String name;
  final String language;
  final String goal;
  final String plan;
  final String? photoUrl;

  UserProfile copyWith({
    String? name,
    String? language,
    String? goal,
    String? plan,
    String? photoUrl,
  }) {
    return UserProfile(
      uid: uid,
      email: email,
      name: name ?? this.name,
      language: language ?? this.language,
      goal: goal ?? this.goal,
      plan: plan ?? this.plan,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
