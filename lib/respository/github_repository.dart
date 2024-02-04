import 'dart:convert';
import 'package:github_issues_app/model/issue.dart';
import 'package:http/http.dart' as http;

class GitHubRepository {
  static const String baseUrl =
      'https://api.github.com/repos/flutter/flutter/issues';
  static const int issuesPerPage = 10;

  Future<List<Issue>> getIssues(int page) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl?page=$page&per_page=$issuesPerPage'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Issue.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load issues');
      }
    } catch (e) {
      throw Exception('Failed to load issues: $e');
    }
  }
}
