class Issue {
  final String title;
  final String body;
  final String authorName;
  final DateTime createdAt;
  final List<dynamic> labels;

  Issue({
    required this.title,
    required this.body,
    required this.authorName,
    required this.createdAt,
    required this.labels,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    return Issue(
      title: json['title'],
      body: json['body'],
      authorName: json['user']['login'],
      createdAt: DateTime.parse(json['created_at']),
      labels: (json['labels'] as List).map((label) => label['name']).toList(),
    );
  }
}
