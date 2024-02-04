import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_issues_app/bloc/github_bloc.dart';
import 'package:github_issues_app/bloc/github_event.dart';
import 'package:github_issues_app/bloc/github_state.dart';
import 'package:github_issues_app/ui/widgets/filter_dropdown.dart';
import 'package:connectivity/connectivity.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  late GitHubBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<GitHubBloc>(context);

    _scrollController.addListener(_onScroll);

    // Fetching the first page on app start
    _checkInternetAndFetchIssues();
  }

  void _checkInternetAndFetchIssues() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        // No internet connection
        Future.delayed(Duration.zero, () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('No internet connection'),
          ));
        });
      } else {
        // Internet connection available, fetching the first page
        _bloc.add(const FetchIssues(1, hasMore: true));
      }
    } catch (e) {
      _bloc.add(const FetchIssues(1, hasMore: true));
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_bloc.state.isLoading &&
        _bloc.state.hasMore) {
      _checkInternetAndFetchIssues();
    }
  }

  void _onFilterChanged(List<String> selectedLabels) {
    _bloc.add(UpdateFilters(selectedLabels));

    // Fetch issues only when there are selected labels
    if (selectedLabels.isNotEmpty) {
      _checkInternetAndFetchIssues();
    } else {
      // If no labels are selected, reset the issues list (show all issues)
      _bloc.add(const FetchIssues(1, hasMore: true));
    }
  }

  Widget _buildFilterDropdown(
    List<String> labels,
    List<String> selectedLabels,
  ) {
    return FilterDropdown(
      labels: labels,
      selectedLabels: selectedLabels,
      onFilterChanged: _onFilterChanged,
    );
  }

  Widget _buildIssuesList(GitHubState state) {
    if (state.isLoading && state.issues.isEmpty) {
      return const CupertinoActivityIndicator();
    } else if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load issues'),
            ElevatedButton(
              onPressed: () {
                // Retry fetching issues on button click
                _checkInternetAndFetchIssues();
              },
              child: const Text('Retry'),
            ),
            if (state.isLoading) // Show CupertinoActivityIndicator if loading
              const SizedBox(height: 16),
            if (state.isLoading) const CupertinoActivityIndicator(),
          ],
        ),
      );
    } else {
      // Display issues list
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.filteredIssues.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < state.filteredIssues.length) {
            final issue = state.filteredIssues[index];

            return Column(
              children: [
                ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        issue.body.substring(0, 50),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildLabels(issue.labels),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Date: ${_formatDateTime(issue.createdAt)}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Author: ${issue.authorName}',
                            style: const TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: Colors.grey,
                  height: 20,
                  thickness: 2,
                  indent: 20,
                  endIndent: 20,
                ),
              ],
            );
          } else if (state.hasMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CupertinoActivityIndicator(),
              ),
            );
          } else {
            return Container();
          }
        },
      );
    }
  }

  Widget _buildLabels(List<dynamic> labels) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: labels
          .map(
            (label) => Chip(
              label: Text(label.toString()),
              backgroundColor: Colors.blue,
            ),
          )
          .toList(),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('GitHub Flutter Issues'),
      ),
      body: SafeArea(
        child: BlocBuilder<GitHubBloc, GitHubState>(
          builder: (context, state) {
            // Display labels at the top of the page
            if (state.availableLabels.isNotEmpty) {
              return Column(
                children: [
                  _buildFilterDropdown(
                    state.availableLabels,
                    state.selectedLabels,
                  ),
                  Expanded(
                    child: _buildIssuesList(state),
                  ),
                ],
              );
            }

            // Display loading or error state
            if (state.isLoading && state.issues.isEmpty) {
              return const CupertinoActivityIndicator();
            } else if (state.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Failed to load issues'),
                    ElevatedButton(
                      onPressed: () {
                        // Retry fetching issues on button click
                        _checkInternetAndFetchIssues();
                      },
                      child: const Text('Retry'),
                    ),
                    if (state
                        .isLoading)
                      const SizedBox(height: 16),
                    if (state.isLoading) const CupertinoActivityIndicator(),
                  ],
                ),
              );
            }

            // Display issues list
            return _buildIssuesList(state);
          },
        ),
      ),
    );
  }
}
