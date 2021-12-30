import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/pages/list_todo.dart';
import 'package:todo_list/store.dart';

void main() {
  runApp(BlocProvider(
    create: (_) => TodoCubit(),
    child: TodoApp(),
  ));
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ListTodoPage(tabId: 0)
    );
  }
}