class Club {
  final String id;
  final String name;
  final String description;
  final bool recruiting;
  final String joinPassword;

  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.recruiting,
    required this.joinPassword,
  });

  factory Club.fromMap(Map<String, dynamic> data, String documentId) {
    return Club(
      id: documentId,
      name: data['name'] ?? '이름 없음',
      description: data['description'] ?? '소개 없음',
      recruiting: data['recruiting'] ?? false,
      joinPassword: data['joinPassword'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'recruiting': recruiting,
      'joinPassword': joinPassword,
    };
  }
}