class Club {
  final String id;
  final String name;
  final String description;
  final List<String> members;
  final bool recruiting;
  final String joinPassword;
//생성자
  Club({
    required this.id,
    required this.name,
    required this.description,
    required this.members,
    required this.recruiting,
    required this.joinPassword,
  });
}
