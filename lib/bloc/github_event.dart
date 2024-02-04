import 'package:equatable/equatable.dart';
import 'package:github_issues_app/model/issue.dart';

abstract class GitHubEvent extends Equatable {
  final List<String>? selectedLabels;

  const GitHubEvent(this.selectedLabels);

  @override
  List<Object?> get props => [selectedLabels];
}

class FetchIssues extends GitHubEvent {
  final int page;
  final List<Issue>? issues;
  final bool hasMore;

  const FetchIssues(this.page, {List<String>? selectedLabels, this.issues, required this.hasMore,
  }) : super(selectedLabels);

  @override
  List<Object?> get props => [page, issues, selectedLabels];
}

class UpdateFilters extends GitHubEvent {
  final List<String> selectedLabels;

  const UpdateFilters(this.selectedLabels) : super(selectedLabels);

  @override
  List<Object?> get props => [selectedLabels];
}
