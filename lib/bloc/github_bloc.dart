import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:github_issues_app/model/issue.dart';
import 'package:github_issues_app/respository/github_repository.dart';
import 'github_event.dart';
import 'github_state.dart';

class GitHubBloc extends Bloc<GitHubEvent, GitHubState> {
  final GitHubRepository repository;

  GitHubBloc(this.repository) : super(GitHubState());

  @override
  Stream<GitHubState> mapEventToState(GitHubEvent event) async* {
    if (event is FetchIssues) {
      yield* _mapFetchIssuesToState(event.page);
    } else if (event is UpdateFilters) {
      yield state.copyWith(selectedLabels: event.selectedLabels);
      yield* _mapFetchIssuesToState(1); // Fetch issues with updated filters
    }
  }

  Stream<GitHubState> _mapFetchIssuesToState(int page) async* {
    try {
      final issues = await repository.getIssues(page);
      final availableLabels = _extractAvailableLabels(issues);

      yield state.copyWith(
        isLoading: false,
        issues: state.issues + issues, // Append new issues to the existing list
        filteredIssues:
            _filterIssues(state.issues + issues), // Update filtered issues
        currentPage: page,
        availableLabels: availableLabels,
        hasMore: issues
            .isNotEmpty, // Set hasMore to false if no more issues are fetched
      );
    } catch (e) {
      yield state.copyWith(isLoading: false, hasError: true);
    }
  }






  List<String> _extractAvailableLabels(List<Issue> issues) {
    return issues
        .map((issue) => issue.labels)
        .expand((labels) => labels.map((label) => label.toString()))
        .toSet()
        .toList();
  }

  List<Issue> _filterIssues(List<Issue> issues) {
    final selectedLabels = state.selectedLabels;
    if (selectedLabels.isEmpty) {
      return issues; // No filters applied, return all issues
    } else {
      return issues
          .where((issue) =>
              issue.labels.any((label) => selectedLabels.contains(label)))
          .toList();
    }
  }
}
