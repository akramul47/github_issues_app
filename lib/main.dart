import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:github_issues_app/bloc/github_bloc.dart';
import 'package:github_issues_app/repository/github_repository.dart';
import 'package:github_issues_app/ui/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GitHub Flutter Issues',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => GitHubBloc(GitHubRepository()),
        child: const MyHomePage(),
      ),
    );
  }
}
