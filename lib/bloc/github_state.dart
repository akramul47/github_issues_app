import 'package:github_issues_app/model/issue.dart';

class GitHubState {
  final bool isLoading;
  final List<Issue> issues;
  final List<Issue> filteredIssues;
  final int currentPage;
  final List<String> availableLabels;
  final List<String> selectedLabels;
  final bool hasMore;
  final bool hasError;

  GitHubState({
    this.isLoading = false,
    this.issues = const [],
    this.filteredIssues = const [],
    this.currentPage = 1,
    this.availableLabels = const [],
    this.selectedLabels = const [],
    this.hasMore = true,
    this.hasError = false,
  });

  GitHubState copyWith({
    bool? isLoading,
    List<Issue>? issues,
    List<Issue>? filteredIssues,
    int? currentPage,
    List<String>? availableLabels,
    List<String>? selectedLabels,
    bool? hasMore,
    bool? hasError,
  }) {
    return GitHubState(
      isLoading: isLoading ?? this.isLoading,
      issues: issues ?? this.issues,
      filteredIssues: filteredIssues ?? this.filteredIssues,
      currentPage: currentPage ?? this.currentPage,
      availableLabels: availableLabels ?? this.availableLabels,
      selectedLabels: selectedLabels ?? this.selectedLabels,
      hasMore: hasMore ?? this.hasMore,
      hasError: hasError ?? this.hasError,
    );
  }
}
